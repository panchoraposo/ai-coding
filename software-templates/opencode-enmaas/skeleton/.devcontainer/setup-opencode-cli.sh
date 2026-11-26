#!/usr/bin/env bash
# Install OpenCode CLI (required by sst-dev.opencode) and ensure opencode.json
# targets the template-baked MaaS endpoint.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

# shellcheck disable=SC1091
bash "${ROOT}/.devcontainer/setup-enmaas.sh"

: "${ENMAAS_BASE_URL:=${MAAS_BASE_URL:-}}"
: "${ENMAAS_MODEL:=${MAAS_MODEL:-}}"
: "${ENMAAS_API_KEY:=${MAAS_API_KEY:-${OPENAI_API_KEY:-}}}"

BIN_DIR="${HOME}/.local/bin"
OPENCODE_HOME="${HOME}/.opencode"
mkdir -p "${BIN_DIR}" "${OPENCODE_HOME}/bin"

install_cli() {
  if command -v opencode >/dev/null 2>&1; then
    ver="$(opencode --version 2>/dev/null || true)"
    case "${ver}" in
      *\ 0.0.*|*\ 0.1.*|0.0.*|0.1.*)
        echo "Replacing outdated OpenCode CLI (${ver})"
        ;;
      *)
        echo "OpenCode CLI already present: ${ver}"
        return 0
        ;;
    esac
  fi

  echo "Installing OpenCode CLI..."
  if curl -fsSL --retry 5 --max-time 180 https://opencode.ai/install | bash; then
    :
  elif command -v npm >/dev/null 2>&1; then
    npm install -g opencode-ai@latest
  else
    echo "Could not install OpenCode CLI (no installer/npm)" >&2
    return 1
  fi
}

install_cli || true

if [[ -d "${OPENCODE_HOME}/bin" && ":${PATH}:" != *":${OPENCODE_HOME}/bin:"* ]]; then
  export PATH="${OPENCODE_HOME}/bin:${PATH}"
fi
if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi
grep -q '.opencode/bin' "${HOME}/.bashrc" 2>/dev/null || \
  echo 'export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"

if [[ -x "${OPENCODE_HOME}/bin/opencode" && ! -e "${BIN_DIR}/opencode" ]]; then
  ln -sf "${OPENCODE_HOME}/bin/opencode" "${BIN_DIR}/opencode"
fi

# OpenCode 1.19 reads provider.options.baseURL and appends /chat/completions.
# The API key stays in the environment (loaded from Vault); it is not written here.
cat > "${ROOT}/opencode.json" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "maas/${ENMAAS_MODEL}",
  "provider": {
    "maas": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "MaaS",
      "options": {
        "baseURL": "${ENMAAS_BASE_URL}",
        "apiKey": "{env:OPENAI_API_KEY}"
      },
      "models": {
        "${ENMAAS_MODEL}": {
          "name": "${ENMAAS_MODEL}"
        }
      }
    }
  }
}
EOF

echo "OpenCode CLI: $(command -v opencode || echo missing) ($(opencode --version 2>/dev/null || echo unknown))"
echo "MaaS provider → ${ENMAAS_BASE_URL} model=${ENMAAS_MODEL}"
echo "Launch with Ctrl+Esc (Cmd+Esc) or: opencode"
