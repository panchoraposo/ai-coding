# Live demo script (~35–45 min) — RHADS + OpenCode / EnMaaS / OpenShell

Shared password: `backstage`. Keep `https://dashboard.apps.<cluster>/` open.

## 0. Context (3 min)

**Governed AI coding** on the RHADS software supply chain: Developer Hub → Dev Spaces → **OpenCode** → **EnMaaS (Praxis + llm-d)** under **OpenShell**, then promote with Tekton / Quay / ACS / TPA.

Also available (appendix): Kafka trip planners and Debezium CDC from the [demo-rhads-kafka](https://github.com/panchoraposo/demo-rhads-kafka) lineage.

- Developer Hub catalogs **four** templates; lead with **AI Coding App — OpenCode / EnMaaS**.
- EnMaaS Route: `https://enmaas.apps.<cluster>/` (Praxis OpenAI-compatible `/v1`).
- OpenShell policy profile: `rhads-opencode` (deny unapproved egress).
- Vault secrets card on each component Overview (`apps/{name}`).

## 1. Portal — create the AI coding app (5 min)

1. Developer Hub → login as **`dev1`**.
2. Create → **AI Coding App — OpenCode / EnMaaS** (`code-assist`, ≤18 chars).
3. Set the MaaS base URL (OpenCode appends `/chat/completions`; for the external gateway use `https://<host>/prelude-maas/<model>/v1`), the model id, and the API key. The key is written to Vault `apps/{name}/config` and is not committed to the application repo.
4. Wait for source + gitops repos and Argo apps (`code-assist-build|dev|staging|prod`).
5. Catalog → component Overview: **Vault** card, **EnMaaS** and **OpenShell** links.

## 2. Inner loop — OpenCode + EnMaaS + OpenShell (12 min)

1. Catalog → **OpenShift Dev Spaces (VS Code + OpenCode)**. Prefer a workspace already Running.
2. Devfile command → **Write .env for EnMaaS (Praxis) + OpenCode**.
3. Open **OpenCode** chat. Ask: *Add a `/api/health-message` endpoint that returns a JSON status string.*
4. Show Praxis / EnMaaS accepting Chat Completions (open-weight model via llm-d). Optional: `curl -H "Authorization: Bearer $KEY" https://enmaas.apps.<cluster>/v1/models`.
5. Devfile → **Demo OpenShell deny** (or curl `https://example.com`) — egress blocked / fails under policy.
6. Run **Quarkus dev** → hit `/api/hello` and the new endpoint.
7. Command palette → **Red Hat Dependency Analytics** on `pom.xml` (commons-text 1.9 / snakeyaml 1.33).
8. **Trusted Profile Analyzer** — SBOM from the first build. Optionally switch to Hardened Images Dockerfile as in the Kafka demo.

## 3. Supply chain promotion (8 min)

Continue the RHADS promotion story (unsigned tag → ACS → signed promote → Conforma STRICT) as on the trip planner path. See appendix notes or the original Kafka demo script for timing.

## 4. Observability (3 min)

OpenShift console → **Observe → Dashboards (Perses)** → `rhads-observability`. Mention Kafka dashboards still present for the event-driven path.

## Appendix A — Kafka trip planner + CDC

Same flow as demo-rhads-kafka:

1. Create → **Agentic Trip Planner — LangChain4j/Kafka** (or Go).
2. Trip UI → plan → Kafka Console → **Approve**.
3. Create → **CDC — Debezium PostgreSQL** → Order Desk → events on `{app}.public.orders`.

## Appendix B — Credentials cheat sheet

See [credentials.md](credentials.md). EnMaaS key: `enmaas/enmaas-demo-key`. OpenShell: `openshell.apps.<cluster>`.
