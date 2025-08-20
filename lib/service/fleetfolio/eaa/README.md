# Fleetfolio Enterprise Assets Assessment (EAA)

Enterprise Assets Assessment (EAA) is a core capability of the Fleetfolio platform, designed to provide organizations with a repeatable, evidence-driven methodology for discovering, evaluating, and documenting their external-facing digital assets. By leveraging industry-standard penetration testing tools, open-source security frameworks, and structured artifact management, EAA helps organizations maintain visibility and accountability over the security posture of their enterprise assets.

EAA is positioned within the Fleetfolio platform, which itself is a specialized service layer inside the broader Opsfolio and Opsfolio Compliance-as-a-Service (CaaS) ecosystem. Together, these platforms support continuous assurance of technology assets, compliance obligations, and security controls.

Fleetfolio EAA is not a one-off penetration testing toolkit—it is a reusable, auditable, and compliance-aligned assessment capability. By embedding EAA within Fleetfolio and the larger Opsfolio ecosystem, organizations gain a sustainable method for keeping external-facing assets visible, tested, and aligned with their compliance obligations.

- [ ] TODO: Talk with Shahid about how to integrate results from EAA into `surveilr` for full integration into Fleetfolio and larger Opsfolio ecosystem.
- [ ] TODO: Talk with Shahid about how to present the details of pen tests in Fleetfolio UI via SQLPage
- [ ] TODO: Talk with Shahid about whether/how to integrate with [Dagger](https://github.com/dagger/dagger)

## Usage Instructions

The EAA module is delivered as a containerized workflow:

1. Deploy the container
   * Based on OWASP Nightingale with Runme installed.
   * Mounts `/var/fleetfolio` as the working evidence directory.

2. Configure targets
   * Provide domains, IP ranges, and key URLs/APIs via environment variables.
   * Excludes may be set to respect customer scoping and authorization boundaries.

3. Run the assessment
   * A pre-configured [Runme](https://runme.dev/) runbook (`eaa-pentest-lite.runme.md`) orchestrates a sequence of lightweight, authorized tests.
   * Outputs are generated consistently under `/var/fleetfolio/eaa/<tool>/…` in JSON, JSONL, XML, or text formats.

4. Review artifacts
   * Evidence is automatically organized by tool.
   * Analysts can interpret logs and structured outputs directly or feed them into the broader Fleetfolio reporting pipeline.

## Benefits

* Consistency: Every assessment produces a predictable structure of artifacts, making it easier to compare results over time.
* Auditability: JSON/JSONL-first evidence formats ensure results are machine-readable and can be correlated across tools.
* Scalability: Designed to run across multiple customer environments, domains, and IP ranges.
* Compliance Fit: As part of Opsfolio CaaS, EAA supports audit preparation by linking evidence directly to compliance controls.
* Reusability: Runbooks and containerized workflows can be re-run against new scopes with minimal setup.

## Caveats & Considerations

* Scope Authorization: EAA assumes that all provided targets have been explicitly authorized for testing by the customer.
* Lightweight by Default: The included runbook (`pentest-lite`) runs “lite” tests intended for continuous or recurring assessments. Deeper, more aggressive scans should be handled by specialized teams.
* Artifacts Are Evidence, Not Conclusions: The JSON, XML, or text outputs produced by each tool are raw evidence. Interpretation, triage, and prioritization of risks remain the responsibility of analysts and compliance staff.
* Performance Controls: Rate limiting, target exclusions, and scheduling should be applied thoughtfully to avoid unintended impact on production systems.

## Relationship to Fleetfolio & Opsfolio

* Fleetfolio: EAA is one of several modules (alongside identity, assets, observability, etc.) that help organizations track and assure the lifecycle of enterprise assets.
* Opsfolio: EAA contributes to the evidence base that underpins security and compliance insights across the platform.
* Opsfolio CaaS: EAA outputs feed directly into compliance-as-a-service workflows, ensuring that asset assessment is not just a security activity but also a compliance deliverable.

## Implementation

```
eaa/
├─ Dockerfile
├─ docker-compose.yml
├─ .env.sample
├─ fleetfolio-eaa-pentest-lite.runme.md
└─ fixtures/
   ├─ Dockerfile
   ├─ fleetfolio-eaa-analyst-report-template.md
   ├─ fleetfolio-eaa-analyst-sample-report.md
   ├─ fleetfolio-eaa-executive-summary-slides.md
   └─ fleetfolio-eaa-executive-summary.html
```

### Nightingale-based container that auto-runs the Runme runbook

* Dockerfile
  * Base: `ghcr.io/rajanagori/nightingale:latest` (override-able via `--build-arg NIGHTINGALE_IMAGE=…`)
  * Installs Runme via official script.
  * Declares VOLUME for `/var/fleetfolio`.
  * Copies the runbook to `/opt/fleetfolio/eaa-pentest-lite.runme.md`.
  * CMD: runs the runbook on container start.
  * Env var knobs (overridable at runtime):
    * `FLEETFOLIO_EAA_HOME` (defaults to `./.fleetfolio/eaa` in the run context)
    * `FLEETFOLIO_EAA_DOMAINS`, `FLEETFOLIO_EAA_IP_RANGES`, `FLEETFOLIO_EAA_KEY_URLS`, `FLEETFOLIO_EAA_EXCLUDES`
    * `FLEETFOLIO_EAA_RATE_LIMIT` (default 200), `FLEETFOLIO_EAA_CONCURRENCY` (default 50)
    * `FLEETFOLIO_EAA_NAABU_PORTS` (default `top-100`)
    * `FLEETFOLIO_EAA_NUCLEI_TEMPLATES` (default `cves,default`)

### docker-compose with usage docs

* `docker-compose.yml`
  * Builds the image, mounts `./evidence` → `/var/fleetfolio` for artifacts.
  * Reads environment from local `.env` (optional).
  * Extensive in-file docs showing how to pass domains, IPs/CIDRs, key URLs, excludes, and rate/concurrency.
  * Example overrides and bind-mounting the runbook for live edits.

* `.env.sample`
  * Example values for domains, ranges, key URLs, excludes, and tool controls.
  * Copy to `.env` and adjust for each assessment.

### Runme runbook (narrative + runnable)

* `fleetfolio-eaa-pentest-lite.runme.md` (see [Runme](https://runme.dev/))
  * Clear documentation at the top on purpose, usage, and artifact model.
  * Snapshots all `FLEETFOLIO_EAA_*` env vars to `$FLEETFOLIO_EAA_HOME/arguments.env`.
  * Stores a master log at `$FLEETFOLIO_EAA_HOME/runbook.log`.
  * Normalizes env vars into newline-delimited files in `$FLEETFOLIO_EAA_HOME/session/` (domains, ip\_ranges, key\_urls, excludes).
  * Narrative (markdown-friendly) explanations before each tool: what it is, link to official source, why it’s in the chain, and what it finds.
  * Runnable `{ name=<cell> }` code blocks.
  * Artifact guidance after each cell (file paths, formats, and what to look for).
  * Steps implemented (respecting excludes, rate/concurrency, templates, ports):
    * Prep (mkdir evidence dirs)
    * Subfinder → JSONL `/var/fleetfolio/eaa/subfinder/subfinder.jsonl`
    * dnsx → JSONL `/var/fleetfolio/eaa/dnsx/dnsx.jsonl`
    * httpx → JSONL `/var/fleetfolio/eaa/httpx/httpx.jsonl`
    * WhatWeb → per-target JSON `/var/fleetfolio/eaa/whatweb/*.json`
    * Naabu → JSONL `/var/fleetfolio/eaa/naabu/naabu.jsonl`
    * Nmap (+ `xq`) → XML + JSON `/var/fleetfolio/eaa/nmap/services.xml|json`
    * OpenSSL → text certs `/var/fleetfolio/eaa/tls/*.txt`
    * Nuclei → JSONL `/var/fleetfolio/eaa/nuclei/nuclei.jsonl`
    * Katana (optional, if present) → JSONL `/var/fleetfolio/eaa/katana/katana.jsonl`
    * tlsx (optional, if present) → JSONL `/var/fleetfolio/eaa/tls/tlsx.jsonl`
  * Final summary section with quick counts and next-step hints.
  * Idempotent, safe defaults; uses `set -euo pipefail` and `jq` where helpful.

### Analyst deliverables as `fixtures/*`

* `fleetfolio-eaa-analyst-report-template.md` – structured template for reporting per tool + risk ratings + recommendations.
* `fleetfolio-eaa-analyst-sample-report.md` – dummy data example showing how to populate the template.
* Analyst’s Guide appendix embedded at the bottom of the runbook, explaining how to interpret each tool’s artifacts.

### Exec presentation (Reveal.js) in `fixtures/*`

* `fleetfolio-eaa-executive-summary-slides.md` – executive summary deck in Markdown (Reveal.js format).
* `fleetfolio-eaa-executive-summary.html` – minimal HTML wrapper that loads the Markdown slides via CDN Reveal.js.
  * Local serve tip: `deno run -A jsr:@std/http/file-server .` → open `http://localhost:8000/fleetfolio-eaa-executive-summary.html`.

### How to run (quick start)

Build and run with Compose:

```bash
# in github.com/surveilr/www.surveilr.com/lib/service/fleetfolio/eaa
cp .env.sample .env
# edit .env with scope and options

docker compose build
docker compose up
```

Typical variables to set (via `.env` or compose `environment:`):

```
FLEETFOLIO_EAA_DOMAINS="xyz.com abc.example"
FLEETFOLIO_EAA_IP_RANGES="203.0.113.0/24"
FLEETFOLIO_EAA_KEY_URLS="https://api.netspective.com/health"
FLEETFOLIO_EAA_EXCLUDES="dev.netspective.com 10.0.0.0/8"
FLEETFOLIO_EAA_RATE_LIMIT=200
FLEETFOLIO_EAA_CONCURRENCY=50
FLEETFOLIO_EAA_NAABU_PORTS=top-100
FLEETFOLIO_EAA_NUCLEI_TEMPLATES="cves,default"
```

Artifacts will be written under the container path `/var/fleetfolio/eaa/...` (mounted to `./evidence` volume on the host by default).
`surveilr files ingest` can be used to import all session details from `./evidence` mount into a Fleetfolio instance for visualizing reports, logs, etc.
