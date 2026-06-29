# 🔊 Kokoro Web (TTS) — Despliegue en VPS

Kit listo para instalar **[Kokoro Web](https://github.com/eduardolat/kokoro-web)** en tu VPS:
una **interfaz web** de texto‑a‑voz basada en el modelo open‑source **Kokoro‑82M**.
Escribes texto, eliges una voz y descargas el audio. Funciona **en CPU** (no necesitas GPU)
y de regalo expone una **API compatible con OpenAI**.

- ✅ Interfaz web sencilla en tu navegador
- ✅ Multi‑idioma, **incluye voces en español**
- ✅ Un solo contenedor Docker
- ✅ Opción de **dominio + HTTPS automático** (Caddy)
- ✅ API compatible con OpenAI (`/api/v1/audio/speech`)

---

## 📋 Requisitos del VPS

| Recurso | Mínimo recomendado |
|---|---|
| Sistema | Ubuntu 22.04 / 24.04 o Debian 12 |
| CPU | 2 núcleos |
| RAM | 2 GB (4 GB cómodo) |
| Disco | ~3 GB libres (modelo + caché) |
| Red | Puerto `3000` abierto (modo simple), o `80`+`443` (modo HTTPS) |

> No hace falta GPU: Kokoro‑82M es muy ligero y va bien en CPU.

---

## 🚀 Instalación rápida (modo simple, por IP)

Conéctate a tu VPS por SSH y ejecuta:

```bash
# 1) Clona este repositorio (o sube los archivos a tu VPS)
git clone https://github.com/deadpool00/alejandro.git kokoro
cd kokoro

# 2) Lanza el instalador (instala Docker si falta, crea .env y arranca)
bash scripts/install.sh
```

Cuando termine, abre en tu navegador:

```
http://IP_DE_TU_VPS:3000
```

> ¿No tienes `git` o el repo es privado? Mira la
> [instalación sin git (copiar/pegar)](docs/DESPLIEGUE.md#instalación-sin-git).

---

## 🔐 Instalación con dominio + HTTPS

Si tienes un dominio apuntando a la IP del VPS (registro **A**):

```bash
cp .env.example .env
nano .env          # define KW_DOMAIN y KW_ACME_EMAIL
bash scripts/install.sh https
```

Quedará disponible en `https://TU_DOMINIO` con certificado automático de Let's Encrypt.
Detalles en **[docs/HTTPS-DOMINIO.md](docs/HTTPS-DOMINIO.md)**.

---

## 🗣️ Voces en español

Kokoro incluye voces en español (códigos que empiezan por `e`):

| Voz | Tipo |
|---|---|
| `ef_dora` | Femenina |
| `em_alex` | Masculina |
| `em_santa` | Masculina |

En la interfaz web puedes elegir el idioma **Español** y escuchar todas las voces
disponibles. La lista completa (y otros idiomas) aparece dentro de la propia app.

---

## 🛠️ Comandos útiles

```bash
bash scripts/logs.sh          # ver registros en vivo
bash scripts/update.sh        # actualizar a la última versión
bash scripts/uninstall.sh     # detener y borrar contenedores (conserva caché y .env)
```

En modo HTTPS añade `https` al final, p. ej. `bash scripts/logs.sh https`.

---

## 🤖 Usar la API (compatible con OpenAI)

```bash
curl -s http://IP_DE_TU_VPS:3000/api/v1/audio/speech \
  -H "Authorization: Bearer TU_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"model_q8f16","voice":"ef_dora","input":"Hola, esto es Kokoro.","response_format":"mp3"}' \
  --output salida.mp3
```

Tu `TU_API_KEY` es el valor `KW_SECRET_API_KEY` del archivo `.env`.
Más ejemplos en **[docs/USO-API.md](docs/USO-API.md)**.

---

## 📚 Documentación

- **[docs/DESPLIEGUE.md](docs/DESPLIEGUE.md)** — guía detallada paso a paso, firewall y seguridad.
- **[docs/HTTPS-DOMINIO.md](docs/HTTPS-DOMINIO.md)** — dominio + HTTPS con Caddy.
- **[docs/USO-API.md](docs/USO-API.md)** — uso de la API y ejemplos.

---

## 📝 Créditos y licencias

- Interfaz: **[kokoro-web](https://github.com/eduardolat/kokoro-web)** de Eduardo Lat — licencia MIT.
- Modelo: **[Kokoro‑82M](https://huggingface.co/hexgrad/Kokoro-82M)** — licencia Apache 2.0.

Este repositorio solo contiene la configuración de despliegue.
