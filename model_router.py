import os
import json
from typing import Dict, Any, Generator, Optional
from openai import OpenAI

class ModelRouter:
    """
    Router modular para VVC-NOA enfocado en GLM-5.3 y NVIDIA NIM.
    """
    def __init__(self, config_path: str = "providers_config.json"):
        self.config_path = config_path
        self.config = self._load_config()
        self.active_provider = self.config.get("default_provider", "nvidia")
        self.active_model = self.config.get("default_model", "z-ai/glm-5-3")

    def _load_config(self) -> Dict[str, Any]:
        if not os.path.exists(self.config_path):
            raise FileNotFoundError(f"Configuración no encontrada en {self.config_path}")
        with open(self.config_path, "r", encoding="utf-8") as f:
            return json.load(f)

    def set_model(self, provider_key: str, model_id: str):
        if provider_key in self.config["providers"]:
            self.active_provider = provider_key
            self.active_model = model_id

    def get_client(self, api_key: str) -> tuple[OpenAI, str]:
        if self.active_provider == "nvidia":
            base_url = self.config["providers"]["nvidia"]["base_url"]
            return OpenAI(base_url=base_url, api_key=api_key), self.active_model
        raise ValueError("Proveedor no configurado para pruebas.")

    def generate_response(self, api_key: str, messages: list[dict]) -> Generator[str, None, None]:
        client, model_name = self.get_client(api_key)
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            stream=True
        )
        for chunk in response:
            if chunk.choices and chunk.choices[0].delta.content:
                yield chunk.choices[0].delta.content
              
