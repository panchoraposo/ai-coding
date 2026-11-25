# OpenShift 5 compatibility notes

This demo targets **Red Hat OpenShift 5** with:

| Product | Expected version / channel |
| --- | --- |
| OpenShift | 5.x (Kubernetes 1.36) |
| Red Hat Developer Hub | 2.1 (`fast-2.1`) |
| OpenShift Dev Spaces | 3.31 (`stable`) |
| Quay | `stable-5.0` (not `stable-3.17`) |
| ODF | `stable-5.0` (not `stable-4.22`) |
| OpenShift AI (`rhods-operator`) | Detected at install — often via AgnosticD `rhbk-operator-catalogsource` until published on `redhat-operators` |
| RHTPA | Detected at install — same AgnosticD fallback (`stable-v3`) |
| OpenShell | Helm chart from `oci://quay.io/ai-openshell/charts/openshell` |
| Praxis AI | Container image from the Praxis AI project (`praxis-proxy/ai`) |
| Agent Sandbox | SIG manifest and/or `agent-sandbox-operator` (`preview-0.9`) |

## Catalog detection

`ansible/playbooks/roles/gitops-bootstrap/tasks/resolve-optional-operators.yaml` enables RHTPA / OpenShift AI **only** when the package is published on `redhat-operators` for this cluster.

AgnosticD `rhbk-operator-catalogsource` (often a **v4.22** OLM snapshot under `keycloak`) may still list `rhtpa-operator` / `rhods-operator` PackageManifests, but OLM on OpenShift 5 rejects them (`ConstraintsNotSatisfiable`). Those catalogs are **not** used as a fallback.

When packages are missing, install continues with `enable_rhtpa=false` / `enable_rhoai=false`. OpenCode + OpenShell + EnMaaS (Praxis) still install; in-cluster `LLMInferenceService` requires `enable_rhoai=true`.

## Capacity

| Workload | Notes |
| --- | --- |
| RHADS base + Kafka/CDC/Perses | Plan **≥ 16 CPU / 64 Gi** |
| OpenShell + Agent Sandbox | Modest CPU/memory; requires NetworkPolicy enforcement |
| llm-d / `LLMInferenceService` | **GPU required** when RHOAI is enabled |

Recommended sandbox for the full AI path: **≥ 24 CPU / 96 Gi RAM + 1× GPU**.

## llm-d / Service Mesh

llm-d on OpenShift expects **no OpenShift Service Mesh v2 / Istio** on the cluster (CRD conflicts with the inference gateway). Prefer Gateway API with the OpenShift AI inference Gateway.

## NetworkPolicy

OpenShell creates NetworkPolicies for sandbox namespaces. Confirm the cluster CNI **enforces** them (OVN-Kubernetes does).

## Smoke checks after install

```bash
./scripts/smoke-ai.sh
```

Checks EnMaaS `/v1/models`, OpenShell gateway readiness, and llm-d InferenceService status (when enabled).
