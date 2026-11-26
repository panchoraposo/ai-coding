#!/usr/bin/env bash
# Load MaaS settings (from template-baked .opencode/maas.env) and write .env for OpenCode.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

# Template-baked values win as defaults when Dev Spaces env is empty.
if [[ -f .opencode/maas.env ]]; then
  # shellcheck disable=SC1091
  set -a
  # shellcheck source=/dev/null
  source .opencode/maas.env
  set +a
fi

: "${ENMAAS_BASE_URL:=${MAAS_BASE_URL:-}}"
: "${ENMAAS_MODEL:=${MAAS_MODEL:-}}"
: "${ENMAAS_API_KEY:=${MAAS_API_KEY:-${OPENAI_API_KEY:-}}}"
: "${OPENSHELL_POLICY:=rhads-opencode}"
: "${OPENSHELL_GATEWAY:=}"

if [[ -z "${ENMAAS_BASE_URL}" ]]; then
  echo "MAAS/ENMAAS base URL is not set (template maas_base_url / .opencode/maas.env)" >&2
  exit 1
fi
if [[ -z "${ENMAAS_API_KEY}" ]]; then
  echo "MAAS/ENMAAS API key is not set (template maas_api_key / .opencode/maas.env)" >&2
  exit 1
fi
if [[ -z "${ENMAAS_MODEL}" ]]; then
  echo "MAAS model id is not set (template maas_model / .opencode/maas.env)" >&2
  exit 1
fi

# Export for sibling setup scripts / OpenCode CLI in this shell
export MAAS_BASE_URL="${ENMAAS_BASE_URL}"
export MAAS_MODEL="${ENMAAS_MODEL}"
export MAAS_API_KEY="${ENMAAS_API_KEY}"
export ENMAAS_BASE_URL ENMAAS_MODEL ENMAAS_API_KEY
export OPENAI_BASE_URL="${ENMAAS_BASE_URL}"
export OPENAI_API_KEY="${ENMAAS_API_KEY}"

cat > .env <<EOF
# Generated for OpenCode → MaaS (OpenAI-compatible)
OPENAI_BASE_URL=${ENMAAS_BASE_URL}
OPENAI_API_KEY=${ENMAAS_API_KEY}
ENMAAS_BASE_URL=${ENMAAS_BASE_URL}
ENMAAS_MODEL=${ENMAAS_MODEL}
ENMAAS_API_KEY=${ENMAAS_API_KEY}
MAAS_BASE_URL=${ENMAAS_BASE_URL}
MAAS_MODEL=${ENMAAS_MODEL}
MAAS_API_KEY=${ENMAAS_API_KEY}
OPENSHELL_POLICY=${OPENSHELL_POLICY}
OPENSHELL_GATEWAY=${OPENSHELL_GATEWAY}
EOF

mkdir -p .opencode
cat > .opencode/.env <<EOF
OPENAI_BASE_URL=${ENMAAS_BASE_URL}
OPENAI_API_KEY=${ENMAAS_API_KEY}
EOF

# Keep maas.env in sync (idempotent)
cat > .opencode/maas.env <<EOF
MAAS_BASE_URL=${ENMAAS_BASE_URL}
MAAS_MODEL=${ENMAAS_MODEL}
MAAS_API_KEY=${ENMAAS_API_KEY}
ENMAAS_BASE_URL=${ENMAAS_BASE_URL}
ENMAAS_MODEL=${ENMAAS_MODEL}
ENMAAS_API_KEY=${ENMAAS_API_KEY}
OPENAI_BASE_URL=${ENMAAS_BASE_URL}
OPENAI_API_KEY=${ENMAAS_API_KEY}
EOF

echo "Wrote .env for MaaS ${ENMAAS_BASE_URL} model=${ENMAAS_MODEL} policy=${OPENSHELL_POLICY}"
