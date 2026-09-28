"""
VVC-NOA :: Core Backend Orchestrator
FastAPI + AsyncIO + NVIDIA NIM Integration
"""

import os
import json
import asyncio
from typing import AsyncGenerator, Dict, Any
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
import requests

# Configuración Inicial
app = FastAPI(
    title="VVC-NOA Core Backend",
    version="1.0.0",
    description="Motor de orquestación e inferencia de alta eficiencia"
)

# CORS para permitir conexiones desde Flutter (Web, Desktop, Mobile)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

NVIDIA_API_KEY = os.getenv("NVIDIA_API_KEY", "")
NVIDIA_CHAT_ENDPOINT = "https://integrate.api.nvidia.com/v1/chat/completions"
DEFAULT_MODEL = "nvidia/nemotron-3.5-lightning-30b-a3b"


# Modelos de Datos (Pydantic)
class PromptRequest(BaseModel):
    prompt: str = Field(..., description="Instrucción de usuario o payload")
    model: str = Field(default=DEFAULT_MODEL, description="ID del modelo NIM")
    system_prompt: str = Field(
        default="Eres el motor de desarrollo de VVC-NOA. Genera respuestas concisas y código optimizado.",
        description="Instrucción de sistema"
    )
    temperature: float = Field(default=0.2, ge=0.0, le=1.0)
    max_tokens: int = Field(default=2048, ge=1, le=4096)


# Funciones de Soporte
def _build_nvidia_payload(req: PromptRequest, stream: bool = False) -> Dict[str, Any]:
    return {
        "model": req.model,
        "messages": [
            {"role": "system", "content": req.system_prompt},
            {"role": "user", "content": req.prompt}
        ],
        "temperature": req.temperature,
        "max_tokens": req.max_tokens,
        "stream": stream
    }


# Endpoints REST
@app.get("/health")
async def health_check():
    """Verificación de estado del servicio."""
    return {"status": "ok", "system": "VVC-NOA-CORE", "nim_configured": bool(NVIDIA_API_KEY)}


@app.post("/api/v1/generate")
async def generate_code(request: PromptRequest):
    """Endpoint REST unitemporal para inferencia directa."""
    if not NVIDIA_API_KEY:
        raise HTTPException(status_code=500, detail="NVIDIA_API_KEY no configurada en el servidor.")

    headers = {
        "Authorization": f"Bearer {NVIDIA_API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = _build_nvidia_payload(request, stream=False)

    try:
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None, 
            lambda: requests.post(NVIDIA_CHAT_ENDPOINT, headers=headers, json=payload, timeout=60)
        )
        
        if response.status_code == 200:
            data = response.json()
            content = data["choices"][0]["message"]["content"]
            return {"status": "success", "model": request.model, "output": content}
        else:
            raise HTTPException(status_code=response.status_code, detail=response.text)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# Stream vía WebSockets (Baja Latencia para Flutter)
@app.websocket("/ws/generate")
async def websocket_generate(websocket: WebSocket):
    """Canal bidireccional WebSocket para streaming fluido de respuestas."""
    await websocket.accept()
    try:
        while True:
            raw_data = await websocket.receive_text()
            data = json.loads(raw_data)
            req = PromptRequest(**data)

            if not NVIDIA_API_KEY:
                await websocket.send_text(json.dumps({"error": "NVIDIA_API_KEY no configurada."}))
                continue

            headers = {
                "Authorization": f"Bearer {NVIDIA_API_KEY}",
                "Content-Type": "application/json"
            }
            payload = _build_nvidia_payload(req, stream=False)

            # Invocación no bloqueante
            loop = asyncio.get_event_loop()
            response = await loop.run_in_executor(
                None, 
                lambda: requests.post(NVIDIA_CHAT_ENDPOINT, headers=headers, json=payload, timeout=60)
            )

            if response.status_code == 200:
                res_json = response.json()
                output = res_json["choices"][0]["message"]["content"]
                await websocket.send_text(json.dumps({"type": "complete", "content": output}))
            else:
                await websocket.send_text(json.dumps({"type": "error", "message": response.text}))

    except WebSocketDisconnect:
        pass
    except Exception as e:
        await websocket.close(code=1011, reason=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
