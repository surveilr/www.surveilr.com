# Opsfolio Threat Exposure Management (TEM)

Security assessments are only as valuable as the actions they drive. Traditional penetration test reports often end up as static PDFs, spreadsheets, or siloed documents that are disconnected from day-to-day workflows. The result: delays in remediation, limited visibility for leadership, and compliance gaps when auditors ask for proof.

Opsfolio Threat Exposure Management (TEM) solves this problem by providing a real-time, evidence-driven reporting and communications layer that transforms technical test results into actionable dashboards, workflows, and executive insights.

Behind TEM, the Opsfolio Enterprise Assets Assessment (EAA) engine runs structured penetration testing and lightweight threat assessments. Together, Opsfolio EAA (engine) and Opsfolio TEM (experience) form the foundation for continuous threat exposure management, delivering actionable evidence directly into compliance and remediation workflows.

- Opsfolio EAA provides the technical assessment engine.
- Opsfolio TEM delivers the reporting, dashboards, and communications experience.

Together, they feed directly into Opsfolio CaaS POA\&M workflows, ensuring every vulnerability is traceable, actionable, and tied to compliance obligations.

With TEM and EAA, Opsfolio customers can move from static reports to continuous threat exposure management — improving security posture, reducing remediation delays, and achieving audit readiness faster.

## The Opsfolio Suite

Opsfolio TEM and Opsfolio EAA are part of the Opsfolio Suite, which underpins Opsfolio Compliance-as-a-Service (CaaS) offerings.

* Opsfolio EAA (Enterprise Assets Assessment)

  * Runs the technical assessments (authorized penetration testing, asset discovery, lightweight red-team style probes).
  * Produces structured artifacts (JSON, JSONL, XML, CSV, text) stored in Opsfolio’s evidence warehouse.
  * Ingests outputs from both automated scanners and manual pentest workflows into a single system of record.

* Opsfolio TEM (Threat Exposure Management)

  * Provides the customer-facing UI/UX for exposure reporting, dashboards, and communication.
  * Automates finding delivery, triage, and ticketing in real time.
  * Powers executive dashboards that summarize exposures, risks, and remediation progress.
  * Communicates directly with IT and DevOps teams via Jira, ServiceNow, Slack, or Teams.

* Opsfolio CaaS (Compliance-as-a-Service)

  * Uses TEM and EAA as core tools to generate Plans of Actions and Milestones (POA\&M/POAM) for regulated industries.
  * Links threat assessment evidence directly to compliance frameworks (SOC2, ISO, CMMC, HIPAA, FedRAMP, etc.).
  * Provides a continuous compliance pipeline that transforms security operations into audit-ready deliverables.

## How Opsfolio TEM & EAA Work Together

1. Ingest Evidence

   * Opsfolio EAA executes authorized penetration testing workflows.
   * All findings are normalized and stored in the evidence warehouse.

2. Centralize & Correlate

   * Surveilr-based ingestion pipelines structure results into SQL.
   * Opsfolio TEM uses SQLPage dashboards to surface evidence consistently.

3. Deliver & Automate

   * TEM provides real-time dashboards showing vulnerabilities and exposures as soon as they’re found.
   * Findings are automatically routed into IT workflows with standardized rules (severity, ownership, asset type).

4. Remediate & Track

   * Issues are tracked through the TEM remediation lifecycle (Open → In Progress → Remediated → Validated → Closed).
   * TEM notifies stakeholders and ensures remediation progress is visible to both technical and leadership teams.

5. Validate & Close the Loop

   * When a POA\&M item is marked as remediated, TEM automatically triggers Opsfolio EAA retests to confirm closure.
   * Results are logged and archived for compliance audits.

## Customer Benefits

* Real-Time Visibility – Dashboards show live findings, not stale reports.
* Faster Remediation – Issues can be acted on as soon as they’re identified.
* Standardized Workflows – Every finding follows a consistent lifecycle.
* POA\&M Integration – Findings are automatically translated into POA\&M items, tracked through to resolution.
* Compliance-Ready Evidence – All evidence is structured, mapped to controls, and tied to compliance obligations.
* Multi-Tenant Capable – Opsfolio TEM supports MSPs/MSSPs delivering assessments across multiple customers.

## Usage Examples

* CISOs & Security Leaders
  Use TEM dashboards to measure exposure trends, MTTR, and compliance posture across multiple environments.

* DevOps & IT Operations
  Receive EAA findings directly in Jira or ServiceNow via TEM automation, enabling quick fixes without switching tools.

* Compliance & Audit Teams
  Use TEM’s evidence mappings to generate POA\&M items automatically, ensuring remediation is tracked in compliance workflows.

* Service Providers (MSPs/MSSPs)
  Run Opsfolio EAA assessments across multiple customers and deliver standardized TEM dashboards for each tenant.

## Implementation Roadmap (Phased)

* Phase 1 – Foundations
  Centralize EAA artifacts into TEM dashboards. Provide baseline evidence explorers and POA\&M export.

* Phase 2 – Workflow Automation
  Add real-time delivery, Jira/ServiceNow integrations, Slack/Teams notifications, and standardized remediation lifecycles.

* Phase 3 – Advanced CTEM
  Implement triggered retesting, exposure scoring, executive dashboards, and trend analytics. Integrate deeply into Opsfolio CaaS for continuous compliance.

## Phased Implementation Plan

The goal is to deliver a Fleetfolio Enterprise Assets Assessment (EAA) capability that matches (and eventually exceeds) the user experience and workflows demonstrated by industry standard tools, while building on our existing Surveilr → SQL ingestion pipeline and SQLPage UI.

This plan breaks implementation into three phases to reduce complexity, deliver value early, and progressively add automation.

* Phase 1: Centralize + visualize (start with Surveilr + SQLPage basics).
* Phase 2: Automate workflows + integrate with Jira/ServiceNow + enable real-time updates.
* Phase 3: Full CTEM maturity with retesting, exposure scoring, executive dashboards, and compliance integration.

This phased roadmap ensures we deliver tangible value quickly while steadily moving toward a comprehensive Pentest Reporting & Threat Exposure Management platform that rivals industry standard tools within our Opsfolio CaaS ecosystem.

### Phase 1 – Foundations

Timeline: Immediate (1–2 months)
Objective: Centralize evidence and findings, provide baseline reporting, and deliver a usable analyst UI.

* Surveilr ingests tool outputs (Subfinder, dnsx, httpx, WhatWeb, Naabu, Nmap, OpenSSL, Nuclei, Katana, tlsx, etc.) directly into SQL tables.
* SQLPage web server presents dashboards and evidence views from these SQL tables.
* Fleetfolio UI/UX extended to include:

  * Evidence Explorer: browse artifacts by tool, scope, or run ID.
  * Findings Viewer: filter/search by domain, severity, asset.
  * Runbook Log Viewer: view captured environment and arguments for traceability.
* Analysts can use the Qualityfolio test management model for manual notes, triage, and tagging.

Deliverable: A functioning Fleetfolio EAA portal where raw findings are structured, viewable, and exportable—no more static PDFs or spreadsheet-based analysis.

### Phase 2 – Workflow Automation & Integrations

Timeline: Near-term (3–6 months)
Objective: Automate delivery and remediation workflows, reduce manual triage, and integrate with customer systems.

* Add rules-based routing of findings:

  * Auto-tag findings based on severity, asset type, or business unit.
  * Route critical findings to Jira/ServiceNow via connectors.
* Enable real-time delivery: as Surveilr ingests evidence, SQLPage dashboards update automatically.
* Introduce remediation workflows:

  * Analysts assign findings to owners.
  * Track finding status (Open → In Progress → Remediated → Retested → Closed).
* Add notifications: Slack/Teams/email integration for critical/high findings.
* Begin integrating Opsfolio CaaS compliance mapping (link findings to SOC2, ISO, CMMC controls).

Deliverable: A workflow-driven EAA UI with integrated ticketing, real-time delivery, and standardized remediation lifecycle.

### Phase 3 – Advanced CTEM (Continuous Threat Exposure Management)

Timeline: Mid-term (6–12 months)
Objective: Build a complete Threat Exposure Management layer that goes beyond industry standard tools by leveraging Opsfolio’s compliance-driven architecture.

* Add triggered retesting: when a Jira/ServiceNow issue is closed, automatically queue/run relevant EAA runbook tests and mark validation in Fleetfolio.
* Introduce exposure scoring and trend analytics:

  * Track MTTR, number of open findings by severity, remediation velocity.
  * Show trends over time for individual clients and across the Opsfolio tenant base.
* Provide executive dashboards: high-level summaries for leadership and auditors.
* Enable multi-tenant reporting for MSP/MSSP models.
* Expand Opsfolio CaaS integration: automatically produce compliance-ready evidence bundles.

Deliverable: A mature CTEM-aligned EAA platform, with automation, analytics, and compliance baked into Fleetfolio/Opsfolio, exceeding industry standard tools' capabilities.

### Capabilities Required

| Capability             | Competitors Today                                                         | Fleetfolio EAA – Phase 1 (Foundations)                                     | Fleetfolio EAA – Phase 2 (Workflows & Integrations)                          | Fleetfolio EAA – Phase 3 (Advanced CTEM)                         |
| -------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Data Ingestion         | Centralized ingestion of scanner + pentest findings into database | Surveilr ingestion → SQL tables, structured JSON/JSONL artifacts from runbooks | Live ingestion pipelines updating dashboards automatically                       | Exposure scoring + historical trend analysis across all tenants      |
| Reporting              | Interactive dashboards, reports replacing static PDFs                      | SQLPage UI: Evidence explorer, Findings viewer, Runbook log viewer             | Customizable dashboards per domain/asset; Opsfolio compliance views              | Executive dashboards, compliance-ready evidence bundles              |
| Workflow Automation    | Findings routed in real time via Workflow Automation Engine                | Manual triage via SQLPage/Qualityfolio tagging                                 | Rules-based routing by severity/asset; automated status workflow (Open → Closed) | Triggered retesting + validation workflows linked to ticket closures |
| Ticketing Integration  | Jira/ServiceNow integration for auto-ticket creation                       | Not yet (manual export only)                                                   | Direct Jira/ServiceNow connectors; Slack/Teams/email notifications               | Closed-loop integration with ticketing for continuous remediation    |
| Remediation Lifecycle  | Standardized workflows for triage → remediation → closure                  | Manual updates in Qualityfolio/SQL UI                                          | Full remediation workflows with ownership, SLA tracking                          | Retesting automation + continuous validation                         |
| Validation / Retesting | Triggered retest when finding is resolved                                  | N/A                                                                            | N/A                                                                              | Automated retest & validation on ticket closure                      |
| Analytics / Metrics    | MTTR, remediation velocity, exposure trending                              | Basic counts from SQL queries                                                  | MTTR + SLA dashboards; per-tenant KPIs                                           | Exposure scoring, trending across tenants; benchmarking              |
| Multi-Tenant Support   | SaaS platform for service providers                                        | Single-tenant SQLPage instance                                                 | Limited multi-tenant by schema separation                                        | Full Opsfolio multi-tenant support (MSP/MSSP ready)                  |
