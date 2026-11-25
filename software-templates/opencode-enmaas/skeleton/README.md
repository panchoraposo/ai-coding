# ${{values.component_id}}

AI coding demo app for **OpenCode + EnMaaS (Praxis) + OpenShell** on the RHADS platform.

## Inner loop (Dev Spaces)

1. Open this repo in **OpenShift Dev Spaces**.
2. Run **Write .env for EnMaaS (Praxis) + OpenCode**.
3. Open **OpenCode** and ask for a change (for example extend `/api/hello`).
4. Run **Demo OpenShell deny** to show blocked egress to an unapproved host.
5. Run **Quarkus dev** and hit `/api/hello` / `/api/info`.
6. Use **Red Hat Dependency Analytics** on `pom.xml` (intentional old commons-text / snakeyaml).

## Platform links

- EnMaaS: `https://enmaas.${{values.cluster_subdomain}}/`
- OpenShell: `https://openshell.${{values.cluster_subdomain}}/`
- Vault path: `apps/${{values.component_id}}`

## Build / promote

Same RHADS Tekton path as other templates (Nexus → build → SBOM → cosign → ACS → Conforma).
