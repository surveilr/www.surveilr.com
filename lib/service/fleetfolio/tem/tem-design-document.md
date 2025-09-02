# Opsfolio Threat Exposure Management (TEM) Design Document

## 1. Purpose & Scope

This document outlines the design of **Opsfolio Threat Exposure Management
(TEM)** and its integration with **Opsfolio Suite** and **Surveilr**.\
It compares Opsfolio with **PlexTrac** and other industry players in the
**Threat Exposure Management (TEM)** and **Continuous Threat Exposure Management
(CTEM)** space, while highlighting Opsfolio’s unique positioning in combining
**exposure management with compliance evidence pipelines**.

---

## 2. Background & Context

Organizations face an ever-expanding attack surface across cloud, on-premises,
and hybrid infrastructures. Traditional vulnerability management approaches are
insufficient for real-time visibility and continuous threat exposure management
(TEM/CTEM).

- **Problem:** Traditional pentest and vulnerability assessment reports are
  static (PDFs, spreadsheets), making them difficult to track, correlate, and
  act upon.
- **Opportunity:** Deliver **real-time, SQL-queryable TEM data** directly tied
  to regulatory compliance workflows (POA&M, SOC2, CMMC, HIPAA, FedRAMP).
- **Drivers:**
  - Increasing regulatory demands.
  - Shorter remediation cycles.
  - Multi-tenant support for MSP/MSSPs.
  - Customer demand for **compliance-linked security validation**.

**Opsfolio Suite** (with **Surveilr**) provides a unified, auditable, and
compliance-ready solution for identifying, prioritizing, validating, and
remediating security exposures. By combining **continuous discovery,
SQL-queryable evidence, compliance mapping, and automation workflows**, Opsfolio
bridges the gap between IT security and regulatory requirements in ways that
existing platforms like **PlexTrac, Wiz, Palo Alto Cortex XSIAM, Cisco
Vulnerability Management, Intruder, Pentera, and Aikido Security** do not.

---

## How It Works: Continuous Threat Exposure Management

Opsfolio aligns with the **CTEM lifecycle**:

1. **Scope** → Define assets, identities, applications, and cloud infrastructure
   in scope.
2. **Discover** → Continuously collect evidence using integrated tools and
   agents.
3. **Prioritize** → Map exposures to business risk, compliance impact, and
   exploitability.
4. **Validate** → Confirm exposures through adversary emulation and automated
   re-tests.
5. **Mobilize** → Trigger remediation workflows (Jira, ServiceNow, Slack) and
   generate audit-ready reports.

---

## Customer Benefits

- **Compliance-First TEM**: Aligns exposures with SOC2, FedRAMP, HIPAA, HITRUST,
  and FDA SaMD.
- **Auditability**: Every action and data point stored in Surveilr for
  traceability.
- **Data Privacy**: No forced cloud vendor lock-in; evidence stays private
  unless explicitly shared.
- **Integration Ready**: Works with best-in-class open-source and commercial
  tools.
- **Reduced Risk**: Provides a single pane of glass for vulnerabilities,
  exposures, and compliance risks.

## 3. Competitive Landscape

### 3.1 PlexTrac Benchmark

PlexTrac positions itself as a leading TEM/CTEM platform with the following
features:

- AI-assisted pentest reporting (25k+ content library, Plex AI).
- CTEM lifecycle alignment: **Scope → Discover → Prioritize → Validate →
  Mobilize**.
- Risk scoring with configurable equations.
- Automated remediation workflows (Jira, ServiceNow, Slack, Teams).
- Validation/retesting automation.
- Multi-tenant MSSP support.

**Strengths:** Mature CTEM alignment, strong AI automation, MSSP-ready.\
**Weaknesses:** Proprietary architecture, limited transparency into evidence
warehouse, weaker compliance integration.

---

### 3.2 Other Industry Players

Other vendors offering TEM/CTEM-like capabilities include:

- **Wiz** – Cloud-native vulnerability and risk management with strong attack
  surface visibility.
- **Palo Alto Cortex XSIAM** – AI-driven SOC operations, integrates exposure
  management with threat detection.
- **Cisco Vulnerability Management (Kenna Security)** – Risk-based vulnerability
  prioritization.
- **Intruder** – Continuous vulnerability scanning and attack surface
  monitoring.
- **Pentera** – Automated penetration testing and security validation.
- **Aikido Security** – Developer-friendly vulnerability management across
  cloud, app, and container environments.

**Common Strengths Across Competitors:**

- Attack surface discovery and mapping.
- Risk-based prioritization of exposures.
- Automated remediation workflows.

**Opsfolio’s Differentiator:** Unlike others, Opsfolio integrates **compliance
evidence pipelines** (SOC2, HIPAA, CMMC, FedRAMP) directly into TEM, ensuring
exposures are tied not only to **risk** but also to **audit readiness**.

---

## 4. Opsfolio Suite Components

### 4.1 Enterprise Assets Assessment (EAA)

- Asset discovery and inventory across IT, cloud, and IoT/medical devices.
- Metadata-driven classification (sensitivity, criticality, compliance scope).
- Provenance tracking of changes for auditability.

### 4.2 Threat Exposure Management (TEM)

- Centralized exposure catalog (findings from pentests, scanners, audits).
- Exposure lifecycle: detection, prioritization, remediation, validation.
- Risk scoring aligned with compliance requirements.
- Evidence linked to audit artifacts for direct compliance mapping.

### 4.3 Surveilr Integration

- Private, SQL-queryable evidence warehouse.
- Immutable provenance logs for compliance traceability.
- Evidence sharing only when explicitly permitted.
- Supports integration with regulatory standards (SOC2, CMMC, HIPAA, FedRAMP,
  FDA).

---

## 5. System Architecture

- **Data Sources:** Pentests, vulnerability scanners, cloud security tools,
  EDR/XDR feeds.
- **Data Ingestion:** Normalization pipeline, mapped to Opsfolio’s evidence
  schema.
- **Storage:** Surveilr warehouse (SQL-queryable, auditable, private).
- **Processing:** Risk scoring engine, compliance-mapping logic.
- **Presentation:** SQLPage dashboards, API endpoints, Opsfolio web UI.
- **Integrations:** Jira, ServiceNow, Slack, Teams for remediation workflows.

---

## Ecosystem of TEM Data Collection Tools

Opsfolio doesn’t replace existing best-in-class tools; it **orchestrates and
normalizes them** into an audit-ready, compliance-aligned workflow. Below is the
landscape of tools Opsfolio integrates with for data collection across the CTEM
lifecycle.

### 🔍 Asset Discovery & Attack Surface Mapping

- **Amass (OWASP)** – Subdomain and DNS-based attack surface mapping.
- **Shodan / Censys** – Internet-wide scanner insights.
- **Masscan** – High-speed port scanning.
- **Aquatone** – Subdomain reconnaissance and screenshotting.
- **WhatWeb / Wappalyzer** – Web technology fingerprinting.

### 🛡️ Vulnerability & Misconfiguration Scanning

- **OpenVAS / Greenbone** – Comprehensive CVE scanning.
- **Nessus** – Commercial industry standard.
- **Trivy** – Container and IaC vulnerability scanning.
- **Grype / Syft** – SBOM analysis.
- **Kube-bench / Kube-hunter** – Kubernetes misconfigurations.

### 📊 Configuration & Compliance Evidence

- **ScoutSuite** – Multi-cloud security posture.
- **Prowler** – AWS compliance checks.
- **Cloud Custodian** – Cloud policy enforcement.
- **KICS (Checkmarx)** – IaC scanning.
- **Falco** – Runtime container/K8s anomaly detection.

### 📡 Recon & Intelligence Gathering

- **theHarvester** – OSINT for emails and domains.
- **FOCA** – Metadata analysis.
- **SpiderFoot** – Automated OSINT framework.
- **Assetnote** – Continuous attack surface monitoring.
- **Recon-ng** – Modular reconnaissance automation.

### 🔧 Endpoint & Host Evidence Collection

- **Velociraptor** – Forensic endpoint collection.
- **Wazuh** – SIEM + vulnerability detection.
- **Sysdig Secure** – Runtime workload monitoring.
- **Kolide** – User-focused osquery evidence reporting.

### 📦 Specialized Exposure Management

- **SSLyze / testssl.sh** – TLS and SSL exposure analysis.
- **OWASP ZAP / Burp Suite** – Web app scanning and validation.
- **Gitleaks / TruffleHog** – Secrets detection.

### 🔄 Workflow, Automation & Evidence Orchestration

- **Mitre Caldera** – Adversary emulation.
- **Atomic Red Team** – TTP simulation.
- **DefectDojo** – Vulnerability consolidation.
- **Cortex (TheHive)** – Threat data enrichment.
- **FleetDM** – Osquery fleet management.

## 6. CTEM Lifecycle Alignment

Opsfolio TEM supports CTEM with compliance traceability at each step:

1. **Scoping:** Define assets and compliance domains (HIPAA, SOC2, CMMC).
2. **Discovery:** Continuous ingestion from scanners, pentests, and assessments.
3. **Prioritization:** Risk scoring + compliance criticality weighting.
4. **Validation:** Automated retesting and evidence capture.
5. **Mobilization:** Integration with ITSM/SOC tools for remediation workflows.

---

## ⚙️ Mapping to CTEM Phases

| TEM Phase      | Example Tools                                   |
| -------------- | ----------------------------------------------- |
| **Scope**      | Amass, Shodan, cnquery, steampipe, ScoutSuite   |
| **Discover**   | Nuclei, OpenVAS, Trivy, osquery, SSLyze         |
| **Prioritize** | DefectDojo, Opsfolio risk scoring engine        |
| **Validate**   | Mitre Caldera, Atomic Red Team, Nuclei re-tests |
| **Mobilize**   | Opsfolio workflows → Jira, ServiceNow, Slack    |

**Opsfolio + Surveilr Advantage**: While these tools collect _raw technical
evidence_, Opsfolio **normalizes findings, maps them to compliance frameworks,
scores risks, and ensures full auditability**—delivering what PlexTrac and
others lack.

## 7. Roadmap

### Phase 1 – Foundations (0–6 months)

- Core EAA + TEM exposure catalog.
- Surveilr integration with SQL evidence warehouse.
- Basic compliance mapping (SOC2, HIPAA).
- Jira/Slack integrations.

### Phase 2 – CTEM Maturity (6–12 months)

- Full CTEM lifecycle automation.
- AI-assisted reporting and prioritization.
- Compliance-linked POA&M generation.
- Multi-tenant support for MSP/MSSPs.

### Phase 3 – Differentiation (12–24 months)

- Deep healthcare & IoT/medical device exposure management.
- Advanced analytics (attack path simulation, compliance impact heatmaps).
- Extended integrations (ServiceNow, Teams, cloud-native security tools).

---

## 8. Differentiation Summary

| Capability                      | PlexTrac              | Wiz / Cortex / Others | Opsfolio TEM + Surveilr                |
| ------------------------------- | --------------------- | --------------------- | -------------------------------------- |
| CTEM lifecycle support          | ✅ Strong             | ✅ Moderate–Strong    | ✅ Strong + compliance                 |
| AI reporting & automation       | ✅ Advanced (Plex AI) | ✅ Varies             | 🚀 Planned, compliance-aware           |
| Risk-based prioritization       | ✅ Yes                | ✅ Yes                | ✅ Yes + compliance weighting          |
| Compliance evidence integration | ❌ Limited            | ❌ Limited            | ✅ Native (SOC2, HIPAA, CMMC, FedRAMP) |
| Evidence warehouse              | ❌ Proprietary        | ❌ Varies             | ✅ SQL-queryable, auditable            |
| Multi-tenant support (MSSP)     | ✅ Yes                | ❌ Limited            | ✅ Yes (planned)                       |
| Medical/IoT device coverage     | ❌ Limited            | ❌ Limited            | ✅ Differentiator                      |

---

## 9. Conclusion

Opsfolio TEM, combined with Surveilr, is positioned to **go beyond PlexTrac and
current TEM/CTEM competitors** by:

- Embedding **compliance evidence** directly into TEM workflows.
- Delivering a **transparent, SQL-queryable evidence warehouse**.
- Supporting **healthcare, IoT, and safety-critical environments** where
  compliance and security intersect.

This integration of **risk + compliance** offers customers both **security
resilience** and **audit readiness**—a combination unmatched in the current
TEM/CTEM market.
