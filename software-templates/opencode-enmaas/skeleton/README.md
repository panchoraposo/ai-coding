# ${{values.component_id}}

AI coding app with **OpenCode** pointed at your MaaS. The API key is stored in **Vault**, not in Git.

## What the template does

| Item | Where |
| --- | --- |
| Base URL and model | `opencode.json`, `.opencode/maas.env`, Dev Spaces env |
| API key | Vault `secret/apps/${{values.component_id}}/config` key `MAAS_API_KEY` |
| Dev Spaces start | Loads that key, writes a local `.env`, refreshes `opencode.json` |

OpenCode calls `${{values.maas_base_url}}/chat/completions` with model `${{values.maas_model}}`.

## Inner loop

1. Wait until the GitOps copy-secrets job has written Vault (Developer Hub → Vault card).
2. Open **Dev Spaces**. postStart runs **Configure OpenCode (.env + CLI) + OpenShell CLI**.
3. Press **Ctrl+Esc** or run `opencode`.

If the key is not ready yet, rerun `bash .devcontainer/setup-opencode-cli.sh`.

## Links

- Vault path: `apps/${{values.component_id}}`
- OpenShell: `https://openshell.${{values.cluster_subdomain}}/`
