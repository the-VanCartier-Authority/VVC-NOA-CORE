import os
import json
import asyncio
from typing import Dict, Any
from fastapi import FastAPI, HTTPException, Security, Depends
from fastapi.security import APIKeyHeader
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import requests

app = FastAPI(
    title="VVC-NOA Core Backend",
    version="1.0.2"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

NVIDIA_API_KEY = os.getenv("NVIDIA_API_KEY", "")
APP_API_KEY = os.getenv("APP_API_KEY", "vvc-secret-key-2026") # Define tu clave segura aquí
NVIDIA_CHAT_ENDPOINT = "https://integrate.api.nvidia.com/v1/chat/completions"

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)

async def verify_api_key(api_key: str = Security(api_key_header)):
    if not api_key or api_key != APP_API_KEY:
        raise HTTPException(
            status_code=403, 
            detail="Acceso no autorizado. API Key inválida o faltante."
        )
    return api_key

class PromptRequest(BaseModel):
    prompt: str = Field(...)

@app.get("/health")
async def health_check():
    return {"status": "ok", "system": "VVC-NOA-CORE"}

@app.post("/api/v1/generate")
async def generate_code(
    request: PromptRequest, 
    authenticated: str = Depends(verify_api_key)
):
    if not NVIDIA_API_KEY:
        raise HTTPException(status_code=500, detail="NVIDIA_API_KEY no configurada.")

    headers = {
        "Authorization": f"Bearer {NVIDIA_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "nvidia/nemotron-3.5-lightning-30b-a3b",
        "messages": [{"role": "user", "content": request.prompt}],
        "temperature": 0.2,
        "max_tokens": 1024
    }

    try:
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None, 
            lambda: requests.post(NVIDIA_CHAT_ENDPOINT, headers=headers, json=payload, timeout=(10, 120))
        )
        if response.status_code == 200:
            content = response.json()["choices"][0]["message"]["content"]
            return {"status": "success", "output": content}
        else:
            raise HTTPException(status_code=response.status_code, detail=response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
