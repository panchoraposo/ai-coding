# OpenShift 5 compatibility notes

This demo targets **Red Hat OpenShift 5** with:

| Product | Expected version / channel |
| --- | --- |
| OpenShift | 5.x (Kubernetes 1.36) |
| Red Hat Developer Hub | 2.1 (`fast-2.1`) |
| OpenShift Dev Spaces | 3.31 (`stable`) |
| OpenShift AI | latest stable on the cluster (`stable` / `fast` as published) |
| Streams for Apache Kafka | `stable` (AMQ Streams) |
| OpenShell | Helm chart from `oci://quay.io/ai-openshell/charts/openshell` (or NVIDIA GHCR equivalent) |
| Praxis AI | Container image from the Praxis AI project (`praxis-proxy/ai`) |

## Capacity

| Workload | Notes |
| --- | --- |
| RHADS base + Kafka/CDC/Perses | Same as demo-rhads-kafka; plan **≥ 16 CPU / 64 Gi** |
| OpenShell + Agent Sandbox | Modest CPU/memory; requires NetworkPolicy enforcement |
| llm-d / `LLMInferenceService` | **GPU required**; default model is a small Red Hat AI FP8 checkpoint — change `gitops/components/llmd/inference-service.yaml` for larger GPUs |

Recommended sandbox for the full AI path: **≥ 24 CPU / 96 Gi RAM + 1× GPU** (for example A10/L4/A100 class depending on model).

## llm-d / Service Mesh

llm-d on OpenShift expects **no OpenShift Service Mesh v2 / Istio** on the cluster (CRD conflicts with the inference gateway). Prefer Gateway API with the OpenShift AI inference Gateway.

## NetworkPolicy

OpenShell creates NetworkPolicies for sandbox namespaces. Confirm the cluster CNI **enforces** them (OVN-Kubernetes does). Without enforcement, egress denials will not demonstrate correctly.

## Operator channels

Channels in `ansible/vars/demo.yaml` and `gitops/platform/operators/` are starting points. On a fresh OpenShift 5 catalog, adjust Subscription channels if OperatorHub publishes different names.

## Smoke checks after install

```bash
./scripts/smoke-ai.sh
```

Checks EnMaaS `/v1/models`, OpenShell gateway readiness, and llm-d InferenceService status.
