# 🎙️ Voiceover Studio (Kokoro TTS) — para tu VPS con Traefik

Restauración de tu **Voiceover Studio**: una web privada para generar
voiceovers (reels de *EasyTheraNotes*) con el modelo **Kokoro**, integrada
en el **Traefik** que ya corre en tu VPS y publicada en
`https://voz.akumalao.com` con usuario y contraseña.

## Arquitectura

```
Internet ──HTTPS──► Traefik (root_web) ──► nginx (kokoro-web) ──► kokoro-fastapi (kokoro-tts:8880)
                     │  basic auth          │  sirve index.html      motor de voz Kokoro (CPU)
                     │  Let's Encrypt        └─ proxy /v1/ ───────────┘   API compatible con OpenAI
```

- **`kokoro-tts`** — backend [kokoro-fastapi](https://github.com/remsky/Kokoro-FastAPI) (CPU). No expone puertos; solo lo usa el frontend.
- **`kokoro-web`** — `nginx` que sirve tu `index.html` (la UI) y hace de proxy de `/v1/` al backend. Traefik lo publica.
- Tu `index.html` llama a `/v1/audio/speech` en el mismo origen → nginx lo reenvía a `kokoro-tts:8880`. Soporta **mezclas de voces** (`af_bella+af_nicole`) y velocidad.

## Requisitos previos en el VPS (ya los tienes)

1. **Traefik** corriendo y conectado a la red externa **`root_web`**.
2. Un **entrypoint `websecure`** (443) y un **certresolver llamado `letsencrypt`**.
   > Si en tu Traefik se llaman distinto, ajusta esos dos valores en `docker-compose.yml`.
3. **DNS:** `voz.akumalao.com` con registro **A** apuntando a la IP del VPS.
   - Verifica:  `dig +short voz.akumalao.com`  → debe dar la IP del VPS.

## Despliegue

```bash
cd voiceover-studio

# 1) Configura dominio y credenciales
cp .env.example .env
nano .env        # pon KOKORO_DOMAIN y KOKORO_BASICAUTH (¡los $ duplicados como $$!)

# 2) Levanta backend + frontend
docker compose up -d

# 3) Mira que arranquen bien (Kokoro tarda un poco la 1ª vez)
docker compose logs -f
```

Accede en **`https://voz.akumalao.com`** (te pedirá usuario y contraseña).

## Verificación rápida

```bash
docker compose ps                         # kokoro-tts y kokoro-web "running"
docker exec kokoro-web wget -qO- http://kokoro-tts:8880/health || true   # backend vivo
```

Si la web carga pero el audio falla, casi siempre es el backend aún cargando
el modelo (revisa `docker compose logs kokoro-tts`).

## Notas

- **¿Ya tenías un `kokoro-tts` corriendo aparte?** Este compose lo define él mismo.
  Si existe uno previo de otro stack, detenlo antes (`docker rm -f kokoro-tts`) para evitar choque de nombre.
- **Voces / idioma:** la UI trae voces inglesas (US/UK) y mezclas. Kokoro también
  tiene español (`ef_dora`, `em_alex`); puedes añadirlas al `<select>` de `index.html`.
- **Rendimiento:** en CPU, los textos largos tardan; el proxy ya tiene timeouts de 300s.
- **Seguridad:** `KOKORO_BASICAUTH` va en `.env` (ignorado por git). No lo subas al repo.
