"""
VVC-NOA :: Operating Guidelines for NVIDIA NIM Models
The Van Cartier Authority
"""

# Modelo oficial de respuesta garantizada
MODEL_ID = "nvidia/nemotron-3.5-lightning-30b-a3b"
NVIDIA_CHAT_ENDPOINT = "https://integrate.api.nvidia.com/v1/chat/completions"

SYSTEM_PROMPT = """
Eres el motor de desarrollo y arquitectura de software de VVC-NOA (The Van Cartier Authority).
Tus respuestas deben ser únicamente código limpio, altamente optimizado y modular en Python o Flutter.
Principios obligatorios:
1. Cero explicación redundante o filosofar.
2. Priorizar soluciones locales, de baja latencia y alta eficiencia.
3. Formatear la salida estrictamente en bloques de código utilizables.
"""

def get_payload(user_prompt: str) -> dict:
    """Construye el payload compatible con OpenAI / NVIDIA NIM."""
    return {
        "model": MODEL_ID,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt}
        ],
        "temperature": 0.2,
        "max_tokens": 2048,
        "stream": False
    }
