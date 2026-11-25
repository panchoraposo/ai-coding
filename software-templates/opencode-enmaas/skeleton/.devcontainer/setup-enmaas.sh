#!/usr/bin/env bash
# Write .env for OpenCode → EnMaaS (Praxis) and OpenShell policy hints.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

: "${ENMAAS_BASE_URL:=${MAAS_BASE_URL:-}}"
: "${ENMAAS_MODEL:=${MAAS_MODEL:-RedHatAI/Qwen3-8B-FP8-dynamic}}"
: "${ENMAAS_API_KEY:=${MAAS_API_KEY:-}}"
: "${OPENSHELL_POLICY:=rhads-opencode}"
: "${OPENSHELL_GATEWAY:=}"

if [[ -z "${ENMAAS_BASE_URL}" ]]; then
  echo "ENMAAS_BASE_URL / MAAS_BASE_URL is not set" >&2
  exit 1
fi

cat > .env <<EOF
# Generated for OpenCode → EnMaaS (Praxis)
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
if [[ -f .opencode/config.json ]]; then
  # Refresh runtime env file OpenCode clients commonly read
  cat > .opencode/.env <<EOF
OPENAI_BASE_URL=${ENMAAS_BASE_URL}
OPENAI_API_KEY=${ENMAAS_API_KEY}
EOF
fi

echo "Wrote .env (EnMaaS ${ENMAAS_BASE_URL}, model ${ENMAAS_MODEL}, policy ${OPENSHELL_POLICY})"
