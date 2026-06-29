#!/usr/bin/env bash
#
# Actualiza Kokoro Web a la última imagen y reinicia.
#
# Uso:
#   bash scripts/update.sh          # modo simple
#   bash scripts/update.sh https    # modo con dominio + HTTPS
#
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FILES=(-f docker-compose.yml)
[ "${1:-}" = "https" ] && FILES=(-f docker-compose.https.yml)

echo "==> Descargando la última imagen..."
docker compose "${FILES[@]}" pull
echo "==> Reiniciando contenedores..."
docker compose "${FILES[@]}" up -d
echo "==> Limpiando imágenes antiguas..."
docker image prune -f
echo "==> Hecho."
