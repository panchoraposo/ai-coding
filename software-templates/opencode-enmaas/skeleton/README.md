# ${{values.component_id}}

AI coding demo app for **OpenCode + EnMaaS (Praxis) + OpenShell** on the RHADS platform.

## Inner loop (Dev Spaces)

1. Open this repo in **OpenShift Dev Spaces** (che-code). On first start:
   - **OpenCode** IDE extension (`sst-dev.opencode`) installs from `.vscode/extensions.json` via Open VSX.
   - **postStart** installs the **OpenCode CLI** (required by the extension), writes `.env` / `opencode.json` for EnMaaS, and installs the **OpenShell** CLI.
2. If you need to re-run setup: Commands → **Configure OpenCode (.env + CLI) + OpenShell CLI**.
3. Press **Ctrl+Esc** (or run `opencode` in the terminal) and ask for a change (for example extend `/api/hello`).
4. Run **Demo OpenShell deny** to show blocked egress to an unapproved host.
5. Run **Quarkus dev** and hit `/api/hello` / `/api/info`.
6. Use **Red Hat Dependency Analytics** on `pom.xml` (intentional old commons-text / snakeyaml).

> OpenShell has **no** VS Code extension — the template installs the **CLI** and points it at the in-cluster gateway (`OPENSHELL_GATEWAY` / policy `rhads-opencode`).

## Platform links

- EnMaaS: `https://enmaas.${{values.cluster_subdomain}}/`
- OpenShell: `https://openshell.${{values.cluster_subdomain}}/`
- Vault path: `apps/${{values.component_id}}`

## Build / promote

Same RHADS Tekton path as other templates (Nexus → build → SBOM → cosign → ACS → Conforma).
