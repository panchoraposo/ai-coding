# RHADS + OpenCode / EnMaaS / OpenShell

**Ansible + OpenShift GitOps** installer based on [demo-rhads-kafka](https://github.com/panchoraposo/demo-rhads-kafka), extended with **OpenCode**, **OpenShell**, and **EnMaaS** (Praxis AI gateway + llm-d) on **OpenShift 5**, while keeping Streams for Apache Kafka, Apicurio, Debezium, and the existing Developer Hub templates.

| Template | Default name | Stack |
| --- | --- | --- |
| **AI Coding App — OpenCode / EnMaaS** | `code-assist` | Quarkus service + Dev Spaces OpenCode → EnMaaS (Praxis) + OpenShell policy |
| **Agentic Trip Planner — LangChain4j/Kafka** | `trip-quarkus` | RHBOQ + langchain4j agents + Kafka CloudEvents HITL |
| **Agentic Trip Planner — Go/Kafka** | `trip-go` | Go + Kafka HITL |
| **CDC — Debezium PostgreSQL** | `orders-cdc` | Shared Debezium Connect + Postgres Order Desk |

This repository is the **source of truth for a repeatable install**. Clone it, log in to a cluster, run `./install.sh`. Ansible publishes the working tree to in-cluster GitLab and points Argo CD at that copy.

## Stack

| Product | Channel / notes |
| --- | --- |
| OpenShift GitOps / Pipelines / RHDH / Dev Spaces | RHADS base (OpenShift **5**, RHDH 2.1, Dev Spaces 3.31) |
| RHTAS / TPA / ACS / Quay / RHBK / GitLab / ODF MCG / Vault / ESO / Nexus | same as demo-rhads |
| Streams for Apache Kafka + Console / Apicurio / Debezium / Perses | same as demo-rhads-kafka |
| **OpenShift AI + llm-d** | `LLMInferenceService` open-weight model for EnMaaS |
| **EnMaaS (Praxis AI)** | Governed OpenAI-compatible gateway → llm-d (+ optional frontier) |
| **OpenShell + Agent Sandbox** | Policy-enforced agent runtime for OpenCode tool/network calls |

## Architecture

```
GitHub (this repo)  ──install.sh──► cluster (RHADS + Kafka + EnMaaS + OpenShell + llm-d)
                         │
                         └── GitLab platform-engineers/rhads-platform  ◄── Argo CD

Developer Hub  ──template──► GitLab (source + *-gitops)
      │                         │
      └── Dev Spaces            ├── OpenCode → EnMaaS (Praxis) → llm-d
         OpenCode + OpenShell   ├── OpenShell denies unapproved egress
                                ├── RHADS pipeline → Nexus + Builds + SBOM + cosign + ACS + TPA
                                └── Kafka / CDC templates still available
```

Details: [docs/architecture.md](docs/architecture.md). Live script: [docs/demo-script.md](docs/demo-script.md). Credentials: [docs/credentials.md](docs/credentials.md). OpenShift 5 notes: [docs/openshift5.md](docs/openshift5.md).

## Prerequisites

* OpenShift **5.x** with `cluster-admin`.
* Typical sandbox: **≥ 24 CPU / 96 Gi** plus **at least one GPU node** sized for the chosen open-weight model (see `docs/openshift5.md`).
* CNI that **enforces NetworkPolicy** (required for OpenShell).
* No OpenShift Service Mesh v2 when using the stock llm-d gateway topology.
* A **default** StorageClass. PVCs omit `storageClassName`. ODF Multicloud Object Gateway for ObjectBucketClaims.
* `oc` logged in. `python3`. Helm 3 is installed by `install.sh` if missing.

## Installation

```bash
git clone https://github.com/panchoraposo/ai-coding.git
cd ai-coding
oc login --server=https://api.<cluster> --token=...
./install.sh
```

Typical time: **70–100 minutes** on a GPU-capable sandbox (RHADS + Kafka + RHOAI/llm-d + Praxis + OpenShell).

After install, GitOps self-heals from **GitLab**. Commit platform changes to GitHub `main` before the next sandbox recreate.

## Users

| Who | Username | Password | Where |
| --- | --- | --- | --- |
| Developer | `dev1` / `dev2` / `dev3` | `backstage` | Keycloak → RHDH, GitLab, gitsign, EnMaaS |
| Platform engineer | `pe1` / `pe2` / `pe3` | `backstage` | Keycloak → RHDH (admin RBAC) |
| GitLab root | `root` | `backstage` | GitLab |
| Quay | `quayadmin` | `backstage` | Quay |
| Nexus | `admin` | `admin123` | Nexus |
| Vault | `vaultadmin` | `backstage` | Vault UI |
| TPA | `tpa-admin` | `backstage` | realm `trustify` |
| EnMaaS demo API key | — | secret `enmaas/enmaas-demo-key` | Praxis `/v1` |

## Demo flow (short)

1. Sign in to Developer Hub as `dev1`.
2. Create → **AI Coding App — OpenCode / EnMaaS**.
3. Dev Spaces → OpenCode (prewired to EnMaaS) → ask for a code change; show Praxis routing to llm-d.
4. Trigger unapproved egress → OpenShell denies.
5. Overview: Vault card (`apps/{name}`) + EnMaaS / OpenShell links.
6. Optional appendix: trip planner / CDC path as in the Kafka demo.
7. OpenShift console → Observe → Dashboards (Perses).

## Uninstall

```bash
./venv/bin/ansible-playbook -i ansible/inventory ansible/playbooks/uninstall.yaml
```
