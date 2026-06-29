#!/usr/bin/env bash
#
# Instalador de Kokoro Web (TTS) para un VPS Ubuntu/Debian.
#
# Uso:
#   bash scripts/install.sh          # modo simple por IP (puerto 3000)
#   bash scripts/install.sh https    # modo con dominio + HTTPS (usa KW_DOMAIN del .env)
#
set -euo pipefail

# Situarse en la raíz del proyecto (carpeta padre de scripts/)
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${GREEN}==>${NC} $*"; }
warn() { echo -e "${YELLOW}!  ${NC} $*"; }
err()  { echo -e "${RED}x  ${NC} $*" >&2; }

MODE="${1:-http}"

# 1) Docker ---------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  info "Docker no está instalado. Instalando con el script oficial..."
  curl -fsSL https://get.docker.com | sh
  info "Docker instalado: $(docker --version)"
else
  info "Docker ya está instalado: $(docker --version)"
fi

# 2) Plugin de Docker Compose v2 ------------------------------
if ! docker compose version >/dev/null 2>&1; then
  err "Falta el plugin 'docker compose' (v2)."
  err "En Ubuntu/Debian:  sudo apt-get update && sudo apt-get install -y docker-compose-plugin"
  exit 1
fi

# 3) Archivo .env ---------------------------------------------
if [ ! -f .env ]; then
  info "Creando .env a partir de .env.example"
  cp .env.example .env
  if command -v openssl >/dev/null 2>&1; then
    KEY="$(openssl rand -hex 32)"
  else
    KEY="$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  fi
  sed -i "s|^KW_SECRET_API_KEY=.*|KW_SECRET_API_KEY=${KEY}|" .env
  info "Generada una KW_SECRET_API_KEY aleatoria (guardada en .env)"
else
  info ".env ya existe; se respeta la configuración actual."
fi

# Cargar variables del .env para validaciones
set -a
# shellcheck disable=SC1091
source .env
set +a

# 4) Arranque -------------------------------------------------
if [ "$MODE" = "https" ]; then
  if [ -z "${KW_DOMAIN:-}" ] || [ "${KW_DOMAIN}" = "tts.midominio.com" ]; then
    err "Para el modo https debes definir KW_DOMAIN en .env con tu dominio real."
    exit 1
  fi
  info "Levantando Kokoro Web con HTTPS para el dominio: ${KW_DOMAIN}"
  docker compose -f docker-compose.https.yml pull
  docker compose -f docker-compose.https.yml up -d
  echo
  info "Listo. Accede en:  https://${KW_DOMAIN}"
  warn "Asegúrate de que el dominio apunta a la IP del VPS y de tener abiertos los puertos 80 y 443."
else
  info "Levantando Kokoro Web en modo simple (IP:puerto)"
  docker compose pull
  docker compose up -d
  IP="$(curl -s --max-time 5 ifconfig.me || true)"
  [ -z "$IP" ] && IP="$(hostname -I | awk '{print $1}')"
  PORT="${KW_PORT:-3000}"
  echo
  info "Listo. Accede en:  http://${IP}:${PORT}"
  warn "Si no carga, abre el puerto ${PORT} en el firewall del VPS y en el panel de tu proveedor."
fi

echo
info "Ver registros:        bash scripts/logs.sh ${MODE/http/}"
info "Actualizar:           bash scripts/update.sh ${MODE/http/}"
info "Tu clave de API está en el archivo .env (KW_SECRET_API_KEY)."
