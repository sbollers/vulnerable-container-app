# vulnerable-container-app (DEMO ONLY)

> ⚠️ **Intentionally insecure.** This repository exists only to demonstrate
> **Microsoft Defender for Cloud — DevOps security** catching vulnerable
> container application code in GitHub and flowing CI/CD scan results into
> Defender for Cloud. Do **not** deploy this anywhere real. All secrets here are
> fake, non-functional example values.

## What's deliberately wrong

| Area | Issue | Surfaced by |
|---|---|---|
| `Dockerfile` | EOL base image `node:8` (100s of CVEs), runs as root, baked-in token | Trivy image scan, MSDO container scan |
| `app/package.json` | Vulnerable deps (old express, lodash, jsonwebtoken, minimist, marked, axios, handlebars) | Dependabot / dependency scanning |
| `app/server.js` | Command injection, `eval` code injection, hardcoded credentials | Code scanning (MSDO), secret scanning |
| `k8s/deploy.yaml` | Privileged, hostPath, host namespaces, no limits | IaC scanning (Trivy / Template Analyzer) |
| `infra/main.tf` | Public storage, TLS1.0, SSH/RDP open to `0.0.0.0/0` | IaC scanning (Trivy / Terrascan) |

## CI/CD security pipeline

`.github/workflows/msdo.yml` runs on every push/PR:

1. **Microsoft Security DevOps action** (`microsoft/security-devops-action`) runs
   the bundled analyzers across **code, IaC, secrets, and containers**, then
   uploads SARIF to the GitHub **Security** tab (code scanning).
2. A second job **builds the container image and runs Trivy**, uploading image
   CVE findings to code scanning as well.

When this repository is onboarded to **Microsoft Defender for Cloud** via the
**GitHub connector** (Environment settings → Add environment → GitHub), these
findings flow into **Defender for Cloud → DevOps security**, giving a single
pane across code-to-cloud.

## Demo talk track

- **(a)** Show **DevOps security** in Defender for Cloud listing this repo's
  findings — container image CVEs, code-injection, exposed secret, IaC misconfig.
- **(b)** Show the **GitHub Actions run** + the **Security tab** SARIF results,
  and explain the connector ingesting them into Defender for Cloud — *one
  pipeline integration, results centralized for the security team.*
