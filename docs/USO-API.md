# Usar la API (compatible con OpenAI)

Kokoro Web expone una API **compatible con OpenAI** en `/api/v1`. Esto significa
que puedes usarla como reemplazo directo de la API de texto‑a‑voz de OpenAI
en muchas herramientas (Open WebUI, librerías, scripts…).

- **Base URL:** `http://IP_DE_TU_VPS:3000/api/v1`  (o `https://TU_DOMINIO/api/v1`)
- **Autenticación:** cabecera `Authorization: Bearer <KW_SECRET_API_KEY>`
- **Docs interactivas:** abre `http://IP_DE_TU_VPS:3000/api/v1/index.html`

> La `KW_SECRET_API_KEY` está en tu archivo `.env`.

---

## Ejemplo con `curl`

```bash
curl -s http://IP_DE_TU_VPS:3000/api/v1/audio/speech \
  -H "Authorization: Bearer TU_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "model_q8f16",
    "voice": "ef_dora",
    "input": "Hola, esto es una prueba de Kokoro en español.",
    "response_format": "mp3"
  }' \
  --output salida.mp3
```

Esto guarda el audio en `salida.mp3`.

---

## Parámetros principales

| Campo | Descripción |
|---|---|
| `model` | Variante del modelo. Más ligero = más rápido en CPU. Ej.: `model_q8f16`, `model_q4f16`, `model_fp32`. |
| `voice` | Voz a usar. Español: `ef_dora`, `em_alex`, `em_santa`. Inglés: `af_heart`, `am_michael`, etc. |
| `input` | El texto a convertir en voz. |
| `response_format` | `mp3`, `wav`, `opus`, `flac`, `pcm`… |
| `speed` | (Opcional) velocidad de habla, p. ej. `1.0`. |

> La lista exacta de modelos y voces disponibles aparece en la interfaz web y en
> las docs interactivas (`/api/v1/index.html`). Úsala como fuente de verdad.

---

## Ejemplo con Python (SDK de OpenAI)

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://IP_DE_TU_VPS:3000/api/v1",
    api_key="TU_API_KEY",
)

with client.audio.speech.with_streaming_response.create(
    model="model_q8f16",
    voice="ef_dora",
    input="Hola desde Python con Kokoro.",
    response_format="mp3",
) as response:
    response.stream_to_file("salida.mp3")
```

---

## Integración con Open WebUI

En **Settings → Audio → TTS**:

- **TTS Engine:** OpenAI
- **API Base URL:** `http://IP_DE_TU_VPS:3000/api/v1`
- **API Key:** tu `KW_SECRET_API_KEY`
- **Voice:** `ef_dora` (u otra)
- **Model:** `model_q8f16`
