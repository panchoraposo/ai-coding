#!/usr/bin/env bash
# Post-install smoke checks for EnMaaS, OpenShell, and llm-d.
set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing $1" >&2; exit 1; }; }
need oc
need curl

DOMAIN="$(oc get dnses.config.openshift.io cluster -o jsonpath='{.spec.baseDomain}')"
APPS="apps.${DOMAIN}"
ENMAAS="https://enmaas.${APPS}"
OPENSHELL="https://openshell.${APPS}"

echo "== cluster ${APPS} =="

echo "-- EnMaaS demo API key"
KEY="$(oc -n enmaas get secret enmaas-demo-key -o jsonpath='{.data.api-key}' 2>/dev/null | base64 -d || true)"
if [[ -z "${KEY}" ]]; then
  echo "FAIL: enmaas/enmaas-demo-key missing"
  exit 1
fi
echo "OK: secret present"

echo "-- Praxis /v1/models"
if curl -fsS -H "Authorization: Bearer ${KEY}" --max-time 30 "${ENMAAS}/v1/models" | head -c 200; then
  echo
  echo "OK: EnMaaS models"
else
  echo "WARN: EnMaaS /v1/models not ready yet (Praxis or llm-d still starting)"
fi

echo "-- OpenShell route / pods"
oc -n openshell get route openshell >/dev/null 2>&1 && echo "OK: openshell route" || echo "WARN: openshell route missing"
oc -n openshell get pods 2>/dev/null | head -20 || echo "WARN: no openshell pods"

echo "-- llm-d LLMInferenceService"
if oc -n llmd get llminferenceservice enmaas-openweight >/dev/null 2>&1; then
  oc -n llmd get llminferenceservice enmaas-openweight -o wide || true
  echo "OK: LLMInferenceService present"
else
  echo "WARN: LLMInferenceService not found (RHOAI/llm-d CRDs or apply still pending)"
fi

echo "-- OpenShell policy ConfigMap"
oc -n openshell get configmap rhads-opencode-policy >/dev/null && echo "OK: policy rhads-opencode" || echo "WARN: policy ConfigMap missing"

echo "-- Dev Spaces OpenCode defaults"
oc -n openshift-devspaces get configmap opencode-enmaas-defaults >/dev/null && echo "OK: opencode defaults" || echo "WARN: opencode-enmaas-defaults missing"

echo "Smoke finished. Review WARN lines before the live demo."
