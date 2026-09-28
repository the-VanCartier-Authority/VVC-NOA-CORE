# VVC-NOA: Neural Operational Assistant
> The Van Cartier Authority — Edge-Native Conversational Intelligence Framework

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Python](https://img.shields.io/badge/Python-3.11+-purple.svg)](https://www.python.org/)
[![UI Theme](https://img.shields.io/badge/Design-Obsidian_%26_Neon_Purple-10B981.svg)]()

VVC-NOA es un agente conversacional modular, elegante y de baja latencia diseñado bajo los principios de **Soberanía Técnica** y **Cero Fricción**.

---

## 🛠️ Arquitectura por Fases de Desarrollo

### 🟢 FASE 1: Core de Conectividad y Router de Modelos (Backend)
- [ ] Implementación de `ModelRouter` con soporte para OpenAI-Compatible API (NVIDIA NIM Base URL: `https://integrate.api.nvidia.com/v1`)[span_3](start_span)[span_3](end_span).
- [ ] Módulo de carga dinámica para `nvidia_models.json` (38 Presets Free Endpoints)[span_4](start_span)[span_4](end_span).
- [ ] Soporte para modo **Manual** (Custom Base URL, Model ID, API Key)[span_5](start_span)[span_5](end_span).
- [ ] Gestor de hilos de inferencia local para modelos **RT Light** via ONNX / GGUF (`rt_light_config.json`).

### 🟣 FASE 2: Engine de Voz Local (Kokoro-TTS & StT)
- [ ] Integración de motor Kokoro-82M ONNX para síntesis de audio local ultrarrápida.
- [ ] Captura de audio del sistema / micrófono y transmisión por streaming WebSockets.

### 🖤 FASE 3: Interfaz UI/UX (Obsidian & Neon Purple)
- [ ] Diseño de layout minimalista (Fondo `#0B0B10`, acentos Neón Púrpura y ecualizador interactivo Verde Esmeralda `#10B981`).
- [ ] Selector desplegable de modelos (Local RT Light / Cloud NVIDIA / Custom Manual).
- [ ] Drawer/Modal de Inspección Técnica para auditoría de procesos en tiempo real.

---

## ⚙️ Configuración del Entorno (`.env`)

```env
# Configuración del Servidor
VVC_PORT=8080
VVC_HOST=127.0.0.1

# Credenciales de Cloud Endpoints
NVIDIA_API_KEY=tu_api_key_aqui
GEMINI_API_KEY=opcional

# Parámetros por Defecto
DEFAULT_MODEL=nvidia/nemotron-3.5-lightning-30b-a3b
RT_LIGHT_MODEL=gemma-2b-it.onnx
