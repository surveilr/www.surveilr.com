# Opsfolio TEM – Unit Testing Pattern Design Document

## 1. Overview

This document defines the **unit testing design pattern** for the **Threat
Exposure Management (TEM)** product within the Opsfolio Suite.\
The unit testing pattern leverages **Surveilr** and the **EAA-generated Resource
Surveillance Database** to validate findings ingestion, anomaly detection, and
reporting.

The focus is on providing **tenant-wise** and **session-wise** anomaly reporting
views to ensure correctness, isolation, and auditability.

---

## 2. Scope

The unit testing design applies to:

- **Tenant-Wise Findings & Anomaly Reports**
- **Session-Wise Findings & Anomaly Reports**

Out of scope (future phases):

- Automated adversary emulation workflows.
- External ticketing integrations.
- Exposure scoring and trending analytics.

---

## 3. Tenant-Wise Findings & Anomaly Reports

### 3.1 Purpose

Validate that **findings are grouped by tenant** and anomaly reports are
correctly generated for each tenant using **tool-specific POML prompts**
executed via Surveilr’s _Capturable Executable_ feature.

### 3.2 Test Pattern

1. **Seed Test Data**
   - Insert findings from supported tools (e.g., WhatWeb, Naabu, Nuclei,
     Subfinder, tlsx, etc.) into the Resource Surveillance Database for multiple
     tenants.
2. **Generate Anomaly Reports**
   - Run POML-based prompts against each tool’s findings using Surveilr.
3. **Render Tenant-Wise Views**
   - List tenants in the UI.
   - Under each tenant, display:
     - Findings by tool.
     - Generated anomaly reports linked to each finding set.
4. **Validate Output**
   - Verify that:
     - Findings are grouped correctly per tenant.
     - Anomalies map back to raw evidence.
     - Data isolation between tenants is enforced.

### 3.3 Expected Output

- Tenant list with collapsible findings sections.
- Per-tenant anomaly reports organized by tool.
- Metadata shown:
  - Tenant ID
  - Scan date/time
  - Tool name
  - Severity level

---

## 4. Session-Wise Findings & Anomaly Reports

### 4.1 Purpose

Validate that findings across **sessions** are correctly aggregated, enabling a
**security engineer** to review anomalies from multiple tenants in a single
consolidated view.

### 4.2 Test Pattern

1. **Seed Test Data**
   - Insert findings from multiple sessions with timestamps, tenant IDs, and
     tool outputs.
2. **Generate Reports**
   - Aggregate findings by **session ID**.
   - Generate anomaly reports via POML prompts.
3. **Render Session-Wise Views**
   - Display sessions in chronological order.
   - Each session view shows:
     - Date/time of action
     - Tenant name(s)
     - Tool findings
     - Generated anomalies
4. **Validate Output**
   - Verify:
     - Correct session grouping.
     - Findings maintain tenant references.
     - Metadata (timestamp, action details) is accurate.

### 4.3 Expected Output

- Session dashboard with table format:\
  `Session ID | Date/Time | Tenant | Tool | Findings | Anomaly Summary`
- Filtering options: by tenant, tool, or date range.

---

## 5. General Validation Rules

- **Integrity**: Findings in anomaly reports must trace back to raw evidence in
  Surveilr.
- **Isolation**: Tenant data must remain isolated; no cross-contamination.
- **Auditability**: All anomaly reports include metadata:
  - Tool name
  - Prompt ID
  - Timestamp
  - Tenant ID / Session ID
- **Consistency**: Same input findings + same tool → identical anomaly report
  results.

---

## 6. Automation Hooks

- **Surveilr Capturable Executable Tests**
  - Run anomaly detection prompts against seeded test findings.
- **Database Validation Queries**
  - SQL assertions for correct tenant/session grouping.
- **UI Snapshot Testing**
  - Validate that dashboards render correctly for tenant-wise and session-wise
    views.

---

## 7. Future Enhancements

- Add **exposure scoring** per tenant and session.
- Enable **cross-tenant anomaly correlation** (useful for MSP/MSSP).
- Automate **retest validation** when findings are marked as remediated.

---

## 8. Deliverables

- Unit test harness integrated with Surveilr.
- SQL validation queries for tenant/session grouping.
- UI test cases for anomaly views.
- Documentation for test execution and expected results.

---

## 9. References

- **Opsfolio TEM Design Document**
- **Surveilr Capturable Executable Specification**
- **Opsfolio EAA Resource Surveillance Database Schema**

---
# Opsfolio TEM – Unit Testing Tasks

This task list tracks the development and testing activities required to implement the **Tenant-Wise** and **Session-Wise** anomaly reporting features for TEM using **Surveilr + EAA Resource Surveillance Database**.
---

## Phase 1 – Setup & Data Seeding

- [x] Define **test database schema** for Resource Surveillance Database (mock
      tenants, sessions, tools).
- [x] Insert **sample findings** from supported tools (WhatWeb, Naabu, Nuclei,
      Subfinder, tlsx, etc.).
- [x] Document **test data generation scripts**.

---

## Phase 2 – Tenant-Wise Views

- [x] Implement tenant grouping queries for findings.
- [ ] Add POML prompt execution using **Surveilr Capturable Executable** for
      each tool.
- [ ] Generate per-tenant anomaly reports.
- [ ] Build **UI view** for tenant-wise anomaly dashboard.
- [ ] Add metadata display: Tenant ID, tool, scan date/time, severity.
- [ ] Write unit tests for tenant data isolation.
- [ ] Validate anomaly traceability to raw evidence.

---

## Phase 3 – Session-Wise Views

- [ ] Implement session grouping queries (findings aggregated by session ID).
- [ ] Generate anomaly reports per session.
- [ ] Build **UI view** for session-wise anomaly dashboard.
- [ ] Display session metadata: Session ID, tenant name(s), date/time, tool
      name.
- [ ] Add filters (tenant, tool, date range).
- [ ] Write unit tests for session grouping correctness.
- [ ] Validate findings trace back to correct tenant and session.

---

## Phase 4 – Automation Hooks

- [ ] Create Surveilr **test harness** for automated anomaly prompt execution.
- [ ] Write SQL validation queries for tenant/session grouping.
- [ ] Implement UI snapshot testing for dashboards.
- [ ] Integrate test suite into CI/CD pipeline.

---

## Phase 5 – Documentation

- [ ] Document **test execution steps** (commands, expected results).
- [ ] Provide examples of **tenant-wise anomaly report output**.
- [ ] Provide examples of **session-wise anomaly report output**.
- [ ] Update Opsfolio TEM developer wiki with testing patterns.

---

## Phase 6 – Future Enhancements (Backlog)

- [ ] Add exposure scoring validation per tenant/session.
- [ ] Implement cross-tenant anomaly correlation tests.
- [ ] Automate retest validation for remediated findings.
