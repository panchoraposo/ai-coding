#!/usr/bin/env bash
# Install OpenCode CLI (required by the sst-dev.opencode VS Code extension)
# and point it at EnMaaS (Praxis) via opencode.json.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

: "${ENMAAS_BASE_URL:=${MAAS_BASE_URL:-}}"
: "${ENMAAS_MODEL:=${MAAS_MODEL:-RedHatAI/Qwen3-8B-FP8-dynamic}}"
: "${ENMAAS_API_KEY:=${MAAS_API_KEY:-${OPENAI_API_KEY:-}}}"

BIN_DIR="${HOME}/.local/bin"
OPENCODE_HOME="${HOME}/.opencode"
mkdir -p "${BIN_DIR}" "${OPENCODE_HOME}/bin"

# Prefer official installer; fall back to npm global if present.
install_cli() {
  if command -v opencode >/dev/null 2>&1; then
    ver="$(opencode --version 2>/dev/null || true)"
    # Extension expects modern CLI (1.x/2.x). Replace ancient 0.0.x/0.1.x stubs.
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

# Ensure PATH for Dev Spaces terminals
if [[ -d "${OPENCODE_HOME}/bin" && ":${PATH}:" != *":${OPENCODE_HOME}/bin:"* ]]; then
  export PATH="${OPENCODE_HOME}/bin:${PATH}"
fi
if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi
grep -q '.opencode/bin' "${HOME}/.bashrc" 2>/dev/null || \
  echo 'export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"

# Symlink into ~/.local/bin when installer dropped it under ~/.opencode/bin
if [[ -x "${OPENCODE_HOME}/bin/opencode" && ! -e "${BIN_DIR}/opencode" ]]; then
  ln -sf "${OPENCODE_HOME}/bin/opencode" "${BIN_DIR}/opencode"
fi

if [[ -z "${ENMAAS_BASE_URL}" ]]; then
  echo "ENMAAS_BASE_URL unset; wrote CLI but skipped opencode.json provider wiring" >&2
  command -v opencode && opencode --version || true
  exit 0
fi

# Project config: OpenAI-compatible EnMaaS gateway
cat > "${ROOT}/opencode.json" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "enmaas/${ENMAAS_MODEL}",
  "providers": {
    "enmaas": {
      "package": "@opencode/ai/providers/openai-compatible",
      "settings": {
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

# Keep env files the extension / CLI both honor
mkdir -p "${ROOT}/.opencode"
cat > "${ROOT}/.opencode/.env" <<EOF
OPENAI_BASE_URL=${ENMAAS_BASE_URL}
OPENAI_API_KEY=${ENMAAS_API_KEY}
EOF

export OPENAI_BASE_URL="${ENMAAS_BASE_URL}"
export OPENAI_API_KEY="${ENMAAS_API_KEY}"

echo "OpenCode CLI: $(command -v opencode || echo missing) ($(opencode --version 2>/dev/null || echo unknown))"
echo "Provider enmaas → ${ENMAAS_BASE_URL} model=${ENMAAS_MODEL}"
echo "Launch from the IDE with Ctrl+Esc (or Cmd+Esc), or run: opencode"
