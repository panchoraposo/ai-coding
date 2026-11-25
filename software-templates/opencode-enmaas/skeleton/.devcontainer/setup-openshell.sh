#!/usr/bin/env bash
# Install OpenShell CLI into the Dev Spaces user home (no IDE extension exists).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

: "${OPENSHELL_VERSION:=0.1.10}"
: "${OPENSHELL_GATEWAY:=}"
: "${OPENSHELL_POLICY:=rhads-opencode}"

BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) ASSET="openshell-x86_64-unknown-linux-musl.tar.gz" ;;
  aarch64|arm64) ASSET="openshell-aarch64-unknown-linux-musl.tar.gz" ;;
  *)
    echo "Unsupported arch ${ARCH}; skip OpenShell CLI install" >&2
    exit 0
    ;;
esac

if ! command -v openshell >/dev/null 2>&1; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "${TMP}"' EXIT
  URL="https://github.com/ai-openshell/openshell/releases/download/v${OPENSHELL_VERSION}/${ASSET}"
  echo "Installing OpenShell CLI ${OPENSHELL_VERSION} from ${URL}"
  curl -fsSL --retry 5 --max-time 120 "${URL}" -o "${TMP}/openshell.tgz"
  tar -xzf "${TMP}/openshell.tgz" -C "${TMP}"
  install -m 0755 "${TMP}/openshell" "${BIN_DIR}/openshell"
fi

# Ensure PATH for subsequent terminals / tasks
if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi
grep -q '.local/bin' "${HOME}/.bashrc" 2>/dev/null || \
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"

if [[ -n "${OPENSHELL_GATEWAY}" ]]; then
  mkdir -p "${HOME}/.config/openshell"
  cat > "${HOME}/.config/openshell/gateway.env" <<EOF
OPENSHELL_GATEWAY=${OPENSHELL_GATEWAY}
OPENSHELL_POLICY=${OPENSHELL_POLICY}
EOF
fi

echo "OpenShell CLI: $(command -v openshell) ($(openshell --version 2>/dev/null || echo ok))"
echo "Gateway=${OPENSHELL_GATEWAY:-unset} policy=${OPENSHELL_POLICY}"
