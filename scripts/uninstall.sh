#!/usr/bin/env bash
#
# Detiene y elimina los contenedores de Kokoro Web.
# Conserva la caché de modelos (./kokoro-cache) y tu archivo .env.
#
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Deteniendo modo simple..."
docker compose down 2>/dev/null || true
echo "==> Deteniendo modo https..."
docker compose -f docker-compose.https.yml down 2>/dev/null || true
echo "==> Contenedores detenidos. Se conservan ./kokoro-cache y el archivo .env."
