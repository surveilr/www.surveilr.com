# 1. Getting Started with Qualityfolio

Qualityfolio is a code-first quality management solution built on Test Management as Code (TMaC). It enables you to organize and version all test artifacts—including cases, suites, and projects—in one centralized system with a Markdown-driven structure for clarity and consistency.

The platform integrates seamlessly with Surveilr for structured ingestion and tracking of test results while supporting both manual and automated test execution to ensure flexibility in testing strategies.

Through its web-based dashboards, Qualityfolio provides complete visibility into test execution, defect metrics, and compliance tracking, while its analytics capabilities allow you to generate actionable insights using custom filters, charts, and trend analysis.

## 2. Requirements of Qualityfolio

### 2.1 Surveilr Installation

Install Surveilr in any of the 3 methods in MacOS/Linux:

#### 2.1.1 Install in current path
```bash
curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | bash
```

#### 2.1.2 Install globally
```bash
curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | SURVEILR_HOME="$HOME/bin" bash
```

#### 2.1.3 Install in preferred path
```bash
curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | SURVEILR_HOME="/path/to/directory" bash
```

Refer to the official [Surveilr installation guide](https://www.surveilr.com/docs/core/quick-start/) for more details.

## 3. Installation Steps for Qualityfolio

Apart from the Surveilr installation, Qualityfolio requires no other installation. Once Surveilr is installed, all Qualityfolio execution tasks can be carried out using the following commands from the integrated terminal.

### 3.1 Ingest project/test plan/test suite/test cases
```bash
surveilr ingest files
```

### 3.2 Load Qualityfolio package
```bash
surveilr shell https://www.surveilr.com/lib/service/qualityfolio/package.sql
```

### 3.3 Launch web UI on localhost:3010
```bash
SQLPAGE_SITE_PREFIX="/qualityfolio" surveilr web-ui -d "resource-surveillance.sqlite.db" --port 3010 --host localhost
```

After this, Qualityfolio will be available at: [http://127.0.0.1:3010/qualityfolio](http://127.0.0.1:3010/qualityfolio)

## 4. Create a Project

To create a project, make a new folder under the root qualityfolio directory (e.g., `project01`). Inside it, create a project plan file (`qf-project.md`) with metadata.

**Sample project plan:**
```yaml
---
id: "PRJ-XXXX"
name: "<Project Name>"
description: "<Brief description of the project – purpose, goals, and expected outcomes>"
created_by: "your-email@example.com"
created_at: "<YYYY-MM-DD>"
last_updated_at: "<YYYY-MM-DD>"
status: "<Active | On Hold | Completed | Archived>"
tags: ["<relevant keywords or categories>"]
phase: "1.0"
related_requirements: ["REQ-101", "REQ-102"]
status: "Draft"
---

### 1. Project Overview

Provide a high-level summary of the project, its purpose, key objectives, and business value.  
This section should answer **why the project exists** and what problems it intends to solve.
---

### 2. Scope

Define the boundaries of the project and highlight what will be covered.  
This should include functional areas, integrations, and quality goals.  
Key focus areas may include (customize as needed):
- **Functional Testing**  
  - Validate creation, execution, and management of project features and workflows.  
  - Ensure correct tracking, reporting, and error handling.  
- **Integration Testing**  
  - Verify interoperability with third-party systems, APIs, or services.  
  - Confirm data synchronization and system connectivity.  
- **Authentication & Authorization**  
  - Test login, access control, and authentication mechanisms.  
  - Verify role-based or permission-based access levels.  
- **Performance & Scalability**  
  - Assess system response under load, stress, and concurrent usage.  
  - Validate scalability for projected future growth.  
- **Usability & Accessibility**  
  - Ensure the user interface follows usability best practices.  
  - Validate compliance with accessibility standards (e.g., WCAG).  
- **Security Testing**  
  - Validate secure handling of sensitive data and credentials.  
  - Ensure logging, monitoring, and auditing capabilities.  
- **Export & Reporting**  
  - Confirm reporting accuracy and data export in multiple formats.  
  - Validate automated scheduling or distribution of reports. 
```

## 5. Create Test Plan

Create a Test type folder inside the Project folder. Add Test plan folder inside the Test type folder (e.g., `test-plan/qf-plan.md`). A test plan defines objectives, scope, and testing activities.

**Sample test plan:**
```yaml
---
id: "PLN-XXXX"
name: "<Test Plan Name>"
description: "<Brief description of the test plan – scope, objectives, and focus areas>"
created_by: "your-email@example.com"
created_at: "<YYYY-MM-DD>"
tags: ["<keywords>", "<testing type>", "<domain-specific focus>"]
version: "1.0"
related_requirements: ["REQ-101", "REQ-102"]
status: "Draft"
---

## 1. Introduction

This test plan defines the overall strategy and approach for validating the **System Under Test (SUT)**.  
The focus includes functional validation, user flows, integration points, data handling, analytics tracking, security, and compliance alignment.

**Objectives include:**  
- Ensuring features function as expected.  
- Verifying smooth user navigation and workflows.  
- Validating data handling and compliance with policies.  
- Confirming correct analytics tracking and reporting.  
- Assessing security, privacy, and accessibility standards.

---

## 2. Scope of Work

The testing will cover (customize as per project needs):  
- **Functional Testing:** Validation of core features, workflows, and business rules.  
- **Entry Points:** Validation of landing pages, navigation, and external/internal access points.  
- **Conversion Paths:** Verification of forms, checkout processes, booking flows, or other business-critical journeys.  
- **Communications:** Internal notifications, user-facing messages, system alerts, and email triggers.  
- **Analytics & Tracking:** Validation of event logging, data attribution, and reporting accuracy.  
- **User Experience & Accessibility:** Responsive design checks, accessibility compliance (e.g., WCAG), and usability validation.  
- **Security & Privacy:** Authentication, authorization, encryption, secure data handling, and compliance alignment.  

**Out of Scope (examples, can be adjusted):**  
- Performance or load testing.  
- Third-party SLA validation.  
- Penetration or vulnerability testing.  

---

## 3. Test Objectives

- Validate functional correctness of all core features and modules.  
- Confirm integrity of workflows and event triggers.  
- Verify compliance-based data handling and storage.  
- Ensure analytics/events are captured accurately for reporting.  
- Validate fallback/error-handling mechanisms.  
- Confirm security/privacy features meet organizational or regulatory standards.  

---

## 4. Test Approach

### 4.1 Functional Testing
- Validate features against requirements and acceptance criteria.  
- Verify input/output processing accuracy.  
- Confirm integration with dependent services/APIs.  
- Validate exception handling and error messages.  

### 4.2 Entry Points
- Test all user access points (UI buttons, embedded tools, navigation links).  
- Verify redirections and navigation flows.  
- Confirm analytics attribution for entry actions.  

### 4.3 Conversion Paths
- Validate form submissions, workflow steps, and completion logic.  
- Verify successful conversions (purchases, bookings, registrations).  
- Confirm handling of invalid inputs and error recovery.  

### 4.4 Communications
- Test notifications, alerts, and user communications.  
- Verify system-triggered messages and scheduling.  
- Confirm formatting, language, and delivery.  
```

Include sections like **Scope of Work** and **Functional Testing** with Markdown headings.

---

## 6. Create Test Suite

Test suites are stored in files like `qf-suite.md`. A suite groups test cases under a feature, release, or regression category. A test suite file is created inside the Test type folder.

**Sample test suite:**
```yaml
---
id: "SUT-XXXX"
projectId: "PRJ-0001"
name: "<Test Suite Name>"
description: "<Brief description of the suite – purpose, focus areas, and objectives>"
created_by: "your-email@example.com"
created_at: "<YYYY-MM-DD>"
tags: ["<testing type>", "<focus area>", "<domain-specific category>"]
version: "1.0"
related_requirements: ["REQ-101", "REQ-102"]
status: "Draft"
---

## Scope of Work

This test suite is designed to validate the core functionalities of the **System Under Test (SUT)**.  
It covers end-to-end workflows, role-based interactions, integrations with external systems, automation processes, reporting accuracy, and system reliability.  
The goal is to ensure the platform functions as intended and aligns with business, technical, and compliance requirements.

---

## Test Objectives

- Validate end-to-end workflows across major modules.  
- Ensure features function as per requirements and specifications.  
- Verify automation processes execute reliably.  
- Test integrations with external systems (e.g., APIs, third-party services, analytics).  
- Validate role-based access control (admin, user, reviewer, auditor, etc.).  
- Confirm reporting and export capabilities (PDF, CSV, dashboards, audit logs).  
- Assess dashboard accuracy, notifications, and tracking features.  
- Validate system guidance (AI/automation prompts) where applicable.  
- Evaluate system behavior under concurrent/multi-user usage.  
- Identify and log defects, functional errors, and edge case handling.  

---

## Roles & Responsibilities

- **Test Lead:** Coordinate suite execution, monitor progress, and review results.  
- **Test Engineers:** Execute test cases, log and retest defects, verify fixes.  
- **Developers (support role):** Assist with defect triage, fixes, and clarifications.  
- **Stakeholders / Reviewers:** Validate outcomes, approve test results, and sign off.  
```

---

## 7. Create Test Case Groups

Organize related test cases into groups, such as:
- Group 1
- Group 2
- Group 3

Groups are represented as folders or tagged sections in Markdown. The test case group folder contains a group file (e.g., `qf-case-group.md`), test case files (e.g., `TC-BCTM-0001.case.md`), test case execution results (e.g., `TC-BCTM-0001.run-1.result.json`) and test case run status (e.g., `TC-BCTM-0001.run.md`).

Groups are represented as folders or tagged sections in Markdown. The test case group folder contains the following artifacts:
1. A group file (e.g., `qf-case-group.md`)
2. Test case files (e.g., `TC-BCTM-0001.case.md`)
3. Test case execution results (e.g., `TC-BCTM-0001.run-1.result.json`) and
4. Test case run status (e.g., `TC-BCTM-0001.run.md`).

Upon test case execution, if an issue is identified, that can be logged as a bug file inside the test case group (e.g., `TC-BCTM-0014.bug.md`).


**Sample test case group file:**
```yaml
---
id: "GRP-XXXX"
suiteId: "SUT-XXXX"
planId: ["PLN-XXXX"]
name: "<Test Case Group Name>"
description: "<Brief description of the purpose of this test group – workflows, modules, or scenarios covered>"
created_by: "your-email@example.com"
created_at: "<YYYY-MM-DD>"
tags: ["<tag1>", "<tag2>", "<tag3>"]
version: "1.0"
related_requirements: ["REQ-101", "REQ-102"]
status: "Draft"
---

## Overview

This test case group defines a collection of related test cases designed to validate a specific workflow, module, or functional area within the **System Under Test (SUT)**.  
It ensures coverage of critical user flows, proper error handling, validation, accessibility, and responsiveness.

---

## Key Functional Areas

### 🔹 Form Validation (if applicable)
- **Form Rendering**  
  - Ensure the form renders correctly with proper field labels.  
  - Validate required and optional fields are displayed.  

- **Input Validation**  
  - Test valid and invalid input formats.  
  - Verify error messages for missing or invalid data.  
  - Check feedback messages and field-level validations.  
---

### 🔹 Verification & Authentication (if applicable)
- **Verification Mechanism**  
  - Confirm verification steps are triggered correctly (e.g., email, SMS, token).  
  - Validate expired or invalid verification attempts show appropriate error messages.  
--

### 🔹 Accessibility & Responsiveness
- Validate keyboard navigation and tab order.  
- Ensure screen reader announcements for all fields, buttons, and system messages.  
- Verify responsiveness across devices (desktop, tablet, mobile). 
```

## 8. Create Test Case

Each test case is defined in Markdown with ID, steps, and expected results.(e.g., `TC-SLN-0001.case.md`)

**Sample test case:**
```yaml
---
id: "TC-XXXX"
groupId: "GRP-XXXX"
title: "<Test Case Title>"
created_by: "<Owner or responsible person/team>"
created_at: "<YYYY-MM-DD>"
last_updated_at: "<YYYY-MM-DD>"
test_type: "<Manual | Automated | Hybrid>"
tags: ["<tag1>", "<tag2>"]
priority: "<High | Medium | Low>"
scenario_type: ["<happy path | unhappy path | miserable>"]
version: "1.0"
test_cycles: ["1.0", "1.1"]
related_requirements: ["REQ-101", "REQ-102"]
status: "Draft"
---

### Description
<Brief description of the test case – purpose, functionality being tested, and expected coverage.>

---

### Preconditions
- <List any setup, configuration, or data required before execution.>  
- <Environment details, if needed.>  

---

### Test Steps
1. <Step 1 – e.g., Navigate to the target page/feature.>  
2. <Step 2 – Perform an action such as filling input, clicking a button.>  
3. <Step 3 – Verify intermediate or final results.>  
4. <Additional steps as needed.>  

---

### Expected Result
- <Clearly state the expected outcome of the test.>  
- <List any specific UI messages, data updates, or workflow transitions.>  
```

## 9. Create Test Case Run Status

Test case runs are instances of executing one or more suites/cases against a build or environment. They are defined with metadata like run ID, environment, and scope. (e.g., `TC-REG-0001.run.md`)
**Sample test case run status:**
```yaml
---
id: "TR-XXXX"
test_case_id: "TC-XXXX"
run_date: "<YYYY-MM-DD>"
environment: "<Environment Name – e.g., Dev, QA, Staging, Production>"
executed_by: "<Name or team executing the test>"
---

### Run Summary

- **Status:** <Pass | Fail | Blocked | In Progress>  
- **Notes:** <Brief summary of execution results, observations, or issues encountered>  
```

## 10. Create Test Case Execution Result

Results (Pass/Fail/Blocked) are recorded after execution. Surveilr ingests results automatically from automation or they can be logged manually. This is a JSON file (e.g., `TC-REG-0001.run-1.result.json`).

**Sample Test case execution result:**
```yaml
{
  "test_case_id": "TC-XXXX",
  "title": "<Test Case Title>",
  "status": "<Pass | Fail | Blocked | In Progress>",
  "start_time": "<YYYY-MM-DDTHH:MM:SS.sssZ>",
  "end_time": "<YYYY-MM-DDTHH:MM:SS.sssZ>",
  "total_duration": "<Duration in seconds or formatted time>",
  "steps": [
    {
      "step": 1,
      "stepname": "<Step 1 description or action>",
      "status": "<Pass | Fail | Blocked>",
      "start_time": "<YYYY-MM-DDTHH:MM:SS.sssZ>",
      "end_time": "<YYYY-MM-DDTHH:MM:SS.sssZ>"
    },
    {
      "step": 2,
      "stepname": "<Step 2 description or action>",
      "status": "<Pass | Fail | Blocked>",
      "start_time": "<YYYY-MM-DDTHH:MM:SS.sssZ>",
      "end_time": "<YYYY-MM-DDTHH:MM:SS.sssZ>"
    }
    // Add additional steps as required
  ]
}
```

## 11. Create Bug

If a test case fails, record a bug and associate it with the corresponding test case or test run. Bug files include metadata such as ID, title, severity, and status, and can be integrated with JIRA for external tracking (e.g., BUG-XXXX.md). To include screenshots, create a folder named images within the respective test type folder. Save screenshots as .png files in this folder, and reference them in the bug’s attachment section.

```yaml
---
issue_id: "BUG-XXXX"
test_case_id: "TC-XXXX"
run_id: "TR-XXXX"
group_id: "GRP-XXXX"
title: "<Brief descriptive title of the bug>"
endpoint: "<Module, feature, or page where bug occurred>"
created_by: "<Reporter Name>"
created_at: "<YYYY-MM-DD>"
test_type: "<Manual | Automated | Hybrid>"
priority: "<High | Medium | Low>"
severity: "<Critical | Major | Medium | Minor | Trivial>"
assigned_to: "<Team member or group responsible>"
status: "<Open | In Progress | Resolved | Closed | Reopened>"
---

### Description
<Concise description of the bug, its behavior, and impact on functionality or workflow.>
---

### Pre-requisites
1. <Required access or permissions>  
2. <Test data or credentials needed>  
3. <Environment setup or configuration>  
---

### Test Steps
1. <Step 1: Action performed>  
2. <Step 2: Action performed>  
3. <Step 3: Action performed>  
4. <Additional steps as needed>  
---

### Expected Result
- <Describe the correct or expected behavior of the system>  
---

### Actual Result
- <Describe the observed behavior that constitutes the bug>  
---

### Attachments (Optional)
- <Screenshots, logs, video captures, or other evidence>  
---

```

## 12. Create Dashboard

Dashboards are generated through the Surveilr web UI, providing insights into test execution progress, defect metrics, and trends. Filters and charts can be customized as needed. To set up the web UI for the currently configured dashboard, follow the three commands outlined in **Section 3: Installation Steps for Qualityfolio**.


## 13. JIRA Integration

Qualityfolio supports JIRA integration to link test cases, runs, and bugs with JIRA issues. Integration is configured using JIRA API tokens in project settings.

## 14. FAQ

**Q1: Do I need Surveilr for Qualityfolio?**

Yes, Surveilr is required for file ingestion, tracking, and dashboards.

**Q2: Can I manage manual and automated test cases together?**

Yes. Manual cases are written in Markdown, while automated results can be ingested.

**Q3: Is Git required?**

Yes, Git is used to version all test artifacts (plans, suites, cases).

**Q4: Which databases are supported?**

SQLite (default) and PostgreSQL.

**Q5: Does it integrate with JIRA?**

Yes. Bugs and cases can be linked directly to JIRA issues for traceability.

