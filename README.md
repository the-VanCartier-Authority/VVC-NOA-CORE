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
[ GitHub Mobile / Web Interface ]
│
▼
[ GitHub Actions Workflow: call_nvidia_api.yml ]
│
▼
[ Script Operativo: glm_coder_instructions.py ]
│
▼
[ NVIDIA NIM API Endpoint ] ──► Modelo Activo: z-ai/glm-5-3
---

## 📂 Estructura del Repositorio

- **`README.md`**: Especificaciones generales y hoja de ruta del proyecto.
- **`glm_coder_instructions.py`**: Parámetros de ejecución, System Prompt e instrucciones operativas para la generación de código con `z-ai/glm-5-3`.
- **`.github/workflows/call_nvidia_api.yml`**: Workflow manual (`workflow_dispatch`) para disparar consultas técnicas al modelo y recibir el código generado directamente en los logs de GitHub[span_2](start_span)[span_2](end_span).

---

## 🚀 Guía de Ejecución Rápida (Desde Móvil / Web)

1. En la pestaña **Settings** de este repositorio, navega a **Secrets and variables ➔ Actions**.
2. Crea un secreto llamado `NVIDIA_API_KEY` guardando tu clave de acceso de NVIDIA Build[span_3](start_span)[span_3](end_span).
3. Ve a la pestaña **Actions** en la parte superior del repositorio.
4. Selecciona el workflow **Trigger NVIDIA NIM API (GLM-5.3)**.
5. Toca en **Run workflow**, escribe tu consulta o instrucción de código y ejecuta el proceso.
6. Revisa el resultado generado en los logs del trabajo sin necesidad de compilar o instalar nada localmente.

---

## 🎨 Identidad Estética de la Suite
- **Base Principal:** Negro Obsidiana (`#0B0B10`)
- **Iluminación Principal:** Púrpura Neón (`#A855F7`)
- **Indicador Interactivo:** Verde Esmeralda (`#10B981`)

---
*Developed under the guidelines of The Van Cartier Authority.*
