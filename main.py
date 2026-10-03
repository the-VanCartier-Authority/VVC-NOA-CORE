import os
import json
import requests
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, status

app = FastAPI(title="VVC-NOA Core Backend", version="1.0.3")

NVIDIA_API_KEY = os.getenv("NVIDIA_API_KEY", "")
APP_API_KEY = os.getenv("APP_API_KEY", "vvc-secret-key-2026")
NVIDIA_CHAT_ENDPOINT = "https://integrate.api.nvidia.com/v1/chat/completions"

@app.websocket("/ws/generate")
async def websocket_generate(websocket: WebSocket):
    # 1. Validar autenticación
    api_key = websocket.query_params.get("api_key")
    if api_key != APP_API_KEY:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    await websocket.accept()

    try:
        while True:
            # 2. Recibir el prompt del cliente Flutter
            data_raw = await websocket.receive_text()
            data = json.loads(data_raw)
            prompt = data.get("prompt", "")

            if not prompt:
                continue

            headers = {
                "Authorization": f"Bearer {NVIDIA_API_KEY}",
                "Content-Type": "application/json",
                "Accept": "text/event-stream"
            }

            payload = {
                "model": "nvidia/nemotron-3.5-lightning-30b-a3b",
                "messages": [{"role": "user", "content": prompt}],
                "temperature": 0.2,
                "max_tokens": 1024,
                "stream": True
            }

            # 3. Petición en streaming a NVIDIA NIM
            response = requests.post(
                NVIDIA_CHAT_ENDPOINT,
                headers=headers,
                json=payload,
                stream=True,
                timeout=(10, 60)
            )

            # 4. Transmitir línea por línea (tokens) al cliente móvil
            for line in response.iter_lines():
                if line:
                    decoded_line = line.decode('utf-8')
                    if decoded_line.startswith("data: "):
                        content = decoded_line[6:]
                        if content == "[DONE]":
                            break
                        try:
                            json_chunk = json.loads(content)
                            delta = json_chunk["choices"][0]["delta"].get("content", "")
                            if delta:
                                await websocket.send_json({"type": "token", "content": delta})
                        except json.JSONDecodeError:
                            continue

            # Notificar fin de mensaje
            await websocket.send_json({"type": "end"})

    except WebSocketDisconnect:
        print("Cliente WebSocket desconectado")
    except Exception as e:
        await websocket.send_json({"type": "error", "content": str(e)})
        await websocket.close()
