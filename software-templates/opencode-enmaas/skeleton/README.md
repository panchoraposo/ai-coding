# ${{values.component_id}}

AI coding demo app for **OpenCode + MaaS + OpenShell** on the RHADS platform.

## Automated MaaS wiring (from the software template)

At create time the template bakes your MaaS settings into:

| File | Purpose |
| --- | --- |
| `opencode.json` | OpenCode CLI provider (`maas` → OpenAI-compatible) |
| `.opencode/config.json` | Extension-oriented OpenAI settings |
| `.opencode/maas.env` / `.opencode/.env` | URL, model, API key for postStart scripts |
| `.devfile.yaml` env | `OPENAI_*` / `MAAS_*` / `ENMAAS_*` in the workspace |
| `.vscode/settings.json` | OpenCode extension defaults |

Dev Spaces **postStart** runs **Configure OpenCode (.env + CLI) + OpenShell CLI**, which reloads those values, installs the OpenCode CLI, and refreshes local `.env`.

## Inner loop

1. Open in **OpenShift Dev Spaces** — wait for postStart / or run Commands → **Configure OpenCode (.env + CLI) + OpenShell CLI**.
2. Press **Ctrl+Esc** (or run `opencode`) and ask for a change.
3. Run **Demo OpenShell deny** for blocked egress.
4. Run **Quarkus dev** and hit `/api/hello` / `/api/info`.

Configured MaaS: `${{values.maas_base_url}}` · model `${{values.maas_model}}`

## Platform links

- OpenShell: `https://openshell.${{values.cluster_subdomain}}/`
- Vault path: `apps/${{values.component_id}}`

## Build / promote

Same RHADS Tekton path as other templates (Nexus → build → SBOM → cosign → ACS → Conforma).
