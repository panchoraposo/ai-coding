#!/usr/bin/env bash
# Load MaaS URL/model from the template, and the API key from Vault.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

if [[ -f .opencode/maas.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .opencode/maas.env
  set +a
fi

: "${MAAS_BASE_URL:=${ENMAAS_BASE_URL:-}}"
: "${MAAS_MODEL:=${ENMAAS_MODEL:-}}"
: "${VAULT_ADDR:=http://vault.vault.svc:8200}"
: "${VAULT_SECRET_PATH:=}"
: "${OPENSHELL_POLICY:=rhads-opencode}"
: "${OPENSHELL_GATEWAY:=}"

if [[ -z "${MAAS_BASE_URL}" || -z "${MAAS_MODEL}" ]]; then
  echo "MAAS_BASE_URL and MAAS_MODEL must be set (template .opencode/maas.env)" >&2
  exit 1
fi

fetch_vault_key() {
  [[ -n "${VAULT_SECRET_PATH}" ]] || return 1
  local jwt token payload http
  jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null || true)"
  [[ -n "${jwt}" ]] || return 1
  token="$(curl -fsS --max-time 20 -X POST \
    --data "{\"role\":\"devspaces-read\",\"jwt\":\"${jwt}\"}" \
    "${VAULT_ADDR}/v1/auth/kubernetes/login" \
    | sed -n 's/.*"client_token":"\([^"]*\)".*/\1/p' | head -1)"
  [[ -n "${token}" ]] || return 1
  http="$(curl -sS -o /tmp/maas-vault.json -w '%{http_code}' --max-time 20 \
    -H "X-Vault-Token: ${token}" \
    "${VAULT_ADDR}/v1/secret/data/${VAULT_SECRET_PATH}")"
  [[ "${http}" == "200" ]] || return 1
  python3 - <<'PY'
import json
doc = json.load(open("/tmp/maas-vault.json"))
data = (doc.get("data") or {}).get("data") or {}
key = data.get("MAAS_API_KEY") or data.get("OPENAI_API_KEY") or ""
if not key:
    raise SystemExit(1)
open("/tmp/maas-api-key", "w").write(key)
PY
  MAAS_API_KEY="$(cat /tmp/maas-api-key)"
  rm -f /tmp/maas-api-key /tmp/maas-vault.json
  export MAAS_API_KEY
}

if [[ -z "${MAAS_API_KEY:-${OPENAI_API_KEY:-}}" ]]; then
  echo "Reading MaaS API key from Vault ${VAULT_SECRET_PATH}"
  fetch_vault_key || {
    echo "Could not read Vault secret/data/${VAULT_SECRET_PATH}." >&2
    echo "The GitOps job writes it after the app is created. Retry this command once that job succeeds." >&2
    exit 1
  }
else
  MAAS_API_KEY="${MAAS_API_KEY:-${OPENAI_API_KEY}}"
fi

export MAAS_BASE_URL MAAS_MODEL MAAS_API_KEY
export ENMAAS_BASE_URL="${MAAS_BASE_URL}"
export ENMAAS_MODEL="${MAAS_MODEL}"
export ENMAAS_API_KEY="${MAAS_API_KEY}"
export OPENAI_BASE_URL="${MAAS_BASE_URL}"
export OPENAI_API_KEY="${MAAS_API_KEY}"

# Local only (gitignored). Never commit the key.
cat > .env <<EOF
OPENAI_BASE_URL=${MAAS_BASE_URL}
OPENAI_API_KEY=${MAAS_API_KEY}
MAAS_BASE_URL=${MAAS_BASE_URL}
MAAS_MODEL=${MAAS_MODEL}
MAAS_API_KEY=${MAAS_API_KEY}
ENMAAS_BASE_URL=${MAAS_BASE_URL}
ENMAAS_MODEL=${MAAS_MODEL}
ENMAAS_API_KEY=${MAAS_API_KEY}
OPENSHELL_POLICY=${OPENSHELL_POLICY}
OPENSHELL_GATEWAY=${OPENSHELL_GATEWAY}
EOF
mkdir -p .opencode
cat > .opencode/.env <<EOF
OPENAI_BASE_URL=${MAAS_BASE_URL}
OPENAI_API_KEY=${MAAS_API_KEY}
EOF

if ! grep -q 'OPENAI_API_KEY' "${HOME}/.bashrc" 2>/dev/null; then
  cat >> "${HOME}/.bashrc" <<EOF
export OPENAI_BASE_URL='${MAAS_BASE_URL}'
export OPENAI_API_KEY='${MAAS_API_KEY}'
export MAAS_BASE_URL='${MAAS_BASE_URL}'
export MAAS_MODEL='${MAAS_MODEL}'
EOF
fi

echo "MaaS ${MAAS_BASE_URL} model=${MAAS_MODEL} (API key loaded from Vault)"
