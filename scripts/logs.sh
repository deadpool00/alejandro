#!/usr/bin/env bash
#
# Muestra los registros (logs) en vivo.
#
# Uso:
#   bash scripts/logs.sh            # modo simple
#   bash scripts/logs.sh https      # modo con dominio + HTTPS
#
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FILES=(-f docker-compose.yml)
[ "${1:-}" = "https" ] && FILES=(-f docker-compose.https.yml)

docker compose "${FILES[@]}" logs -f
