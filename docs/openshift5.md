# OpenShift 5 compatibility notes

This demo targets **Red Hat OpenShift 5** with:

| Product | How it installs on OCP 5 | Compatible? |
| --- | --- | --- |
| OpenShift | 5.x | — |
| RHDH 2.1 | `fast-2.1` on `redhat-operators` | Yes |
| Dev Spaces 3.31 | `stable` | Yes |
| Pipelines / GitOps / ACS / RHTAS | `latest` / `stable` | Yes |
| Quay | **`stable-5.0`** | Yes |
| ODF | **`stable-5.0`** | Yes |
| AMQ Streams / Console / Apicurio / COO / ESO | `stable` / `2.x` | Yes |
| **Trusted Profile Analyzer** | Prefer OLM `rhtpa-operator` when on `redhat-operators`; otherwise **Helm** chart `redhat-trusted-profile-analyzer` 3.1.x | Yes (Helm path avoids incompatible OperatorHub CSV) |
| **OpenShift AI (`rhods-operator`)** | Only if published on `redhat-operator-index:v5.0` | Not in the GA OCP 5 index yet — skipped |
| RHBK | Often from sandbox `rhbk-operator-catalogsource` (AgnosticD) | Catalog lists many OCP 4.22 packages → OperatorHub **Incompatible** noise |

## Why OperatorHub shows “Incompatible”

On RHPDS / AgnosticD sandboxes, `keycloak/rhbk-operator-catalogsource` is usually a **`olm_snapshot_redhat_catalog:v4.22_*`** image. OLM still indexes those PackageManifests on an OCP 5 cluster, so the console Cluster compatibility filter lists them as **Incompatible**. That does **not** mean your subscribed demo operators are broken.

Do **not** subscribe to `rhtpa-operator` / `rhods-operator` from that v4.22 snapshot — OLM returns `ConstraintsNotSatisfiable` on OCP 5.

Official OCP 5 marketplace indexes:

- `registry.redhat.io/redhat/redhat-operator-index:v5.0`
- (same tag pattern for certified / community)

As of this demo’s target date, **`rhtpa-operator` and `rhods-operator` are absent from `redhat-operator-index:v5.0`**.

## TPA on OCP 5 (Helm)

Installer task: `gitops-bootstrap/tasks/apply-tpa.yaml`

1. Applies `gitops/components/rhtpa` (Postgres, secrets, RHDA backend).
2. If the OLM CRD exists → apply `TrustedProfileAnalyzer` CR.
3. Else → `helm upgrade --install` from [openshift-helm-charts/redhat-trusted-profile-analyzer](https://charts.openshift.io/).

## OpenShift AI / llm-d

`enable_rhoai` stays false until `rhods-operator` appears on `redhat-operators` for OCP 5. OpenCode + OpenShell + EnMaaS (Praxis) still install; in-cluster `LLMInferenceService` waits on RHOAI.

## Capacity / CNI / Service Mesh

See earlier notes: NetworkPolicy-capable CNI for OpenShell; no OSSM v2 when using llm-d; GPU when RHOAI is enabled.

## Smoke

```bash
./scripts/smoke-ai.sh
oc -n trusted-profile-analyzer get route,pods
```
