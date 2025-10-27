---
title: "Audit Prompt: Session Lock Policy for ePHI Security Compliance"
weight: 1
description: "Establishes guidelines for implementing session locks to protect ePHI and ensure compliance with CMMC Control AC.L2-3.1.10."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L2-3.1.10"
control-question: "Does the organization initiate a session lock after an organization-defined time period of inactivity, or upon receiving a request from a user and retain the session lock until the user reestablishes access using established identification and authentication methods?"
fiiId: "FII-SCF-IAC-0024"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You're an **official auditor**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

**Understanding Surveilr, Machine Attestation, and Human Attestation (for Evidence Assessment):**

- **Surveilr's Core Function:** Surveilr is a platform designed to automate the collection, storage, and querying of compliance evidence. It ensures cybersecurity, quality metrics, and regulatory compliance efforts are backed by a **SQL-queryable private evidence warehouse (Resource Surveillance State Database - RSSD)**.
- **Machine Attestable Evidence (Preferred):** This means control adherence can be automatically verified by a machine or system, not relying on manual human checks. Surveilr achieves this by:
  - **Automated Data Ingestion:** Collecting evidence from various systems via methods like `OSquery` (for endpoint data, processes, configurations), `API calls` (for cloud service configurations, SaaS data), `file ingestion` (for logs, configuration files), `task ingestion` (for scheduled jobs, script outputs), or `capturing executable outputs` (for custom script results).
  - **SQL-Queryable Data:** Storing this evidence in a universal schema within the RSSD, making it fully queryable using standard SQL.
  - **Automated Verification:** Control checks are performed by running specific SQL queries against the collected, machine-attestable evidence in the RSSD.
- **Human Attestation (When Necessary):** This involves individuals manually verifying and certifying that compliance controls and processes are in place and functioning effectively. It relies on human judgment, review, or direct declaration.
  - **Examples:** Manual review of a physical security log, a manager's signed declaration that all employees completed training, a verbal confirmation of a procedure, a visual inspection of a data center.
  - **Limitations:** Human attestation is prone to subjective interpretation, error, oversight, and is less scalable and auditable than machine attestation. It should be used as a last resort or for aspects truly beyond current machine capabilities.
  - **Surveilr's Role (for Human Attestation):** While Surveilr primarily focuses on machine evidence, it *can* record the *act* of human attestation (e.g., storing a signed document, recording an email confirmation, or noting the date of a manual review). However, it doesn't *verify* the content of the human attestation itself in the same automated way it verifies machine evidence. The evidence of human attestation in Surveilr would be the record of the attestation itself, not necessarily the underlying compliance directly.
- **Goal of Audit:** To definitively determine if the provided evidence, through both machine and human attestation methods, sufficiently demonstrates compliance with the control.

**Audit Context:**

- **Audit Standard/Framework:** CMMC
- **Control's Stated Purpose/Intent:** "The organization initiates a session lock after an organization-defined time period of inactivity, or upon receiving a request from a user and retain the session lock until the user reestablishes access using established identification and authentication methods."
  - **Control Code:** AC.L2-3.1.10
  - **Control Question:** "Does the organization initiate a session lock after an organization-defined time period of inactivity, or upon receiving a request from a user and retain the session lock until the user reestablishes access using established identification and authentication methods?"
  - **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-IAC-0024
- **Policy/Process Description (for context on intent and expected evidence):**
  "The purpose of this policy is to establish guidelines for implementing session locks to protect sensitive information and ensure compliance with the CMMC Control AC.L2-3.1.10. Session locks help mitigate unauthorized access to systems that handle electronic Protected Health Information (ePHI) by automatically securing user sessions after a defined period of inactivity or upon user request. Our organization is committed to implementing session locks in accordance with defined inactivity periods or user requests. All systems that handle ePHI will initiate a session lock to prevent unauthorized access until the user reestablishes access through recognized identification and authentication methods."
- **Provided Evidence for Audit:** "Evidence includes API logs showing session lock events, user training logs indicating acknowledgment of the session lock policy, and system logs documenting session lock enforcement after 15 minutes of inactivity."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: CMMC - AC.L2-3.1.10

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L2-3.1.10
**Control Question:** "Does the organization initiate a session lock after an organization-defined time period of inactivity, or upon receiving a request from a user and retain the session lock until the user reestablishes access using established identification and authentication methods?"
**Internal ID (FII):** FII-SCF-IAC-0024
**Control's Stated Purpose/Intent:** "The organization initiates a session lock after an organization-defined time period of inactivity, or upon receiving a request from a user and retain the session lock until the user reestablishes access using established identification and authentication methods."

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** "Session locks must be initiated within 5 minutes of user inactivity."
    * **Provided Evidence:** "API logs showing session lock events triggered after 15 minutes of inactivity."
    * **Surveilr Method (as described/expected):** "API integrations with identity management systems to verify session lock status."
    * **Conceptual/Actual SQL Query Context:** "SELECT * FROM session_lock_logs WHERE inactivity_duration >= 15; -- checks for session locks after inactivity."
    * **Compliance Status:** NON-COMPLIANT
    * **Justification:** "Evidence indicates that session locks are initiated after 15 minutes of inactivity, which does not meet the control requirement of locking within 5 minutes."

* **Control Requirement/Expected Evidence:** "All session locks must be documented and verified through logs retained for auditing purposes."
    * **Provided Evidence:** "Session lock enforcement logs retained for auditing purposes."
    * **Surveilr Method (as described/expected):** "Logging mechanisms to track session lock events."
    * **Conceptual/Actual SQL Query Context:** "SELECT COUNT(*) FROM session_lock_logs WHERE log_date >= CURRENT_DATE - INTERVAL '6 YEARS'; -- checks retention."
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The evidence shows that all session locks are documented in logs retained for the required length of time."

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** "Users to acknowledge understanding of the session lock policy in training logs."
    * **Provided Evidence:** "Training logs indicate acknowledgment of session lock policy."
    * **Human Action Involved (as per control/standard):** "Users attended training sessions and signed acknowledgment forms."
    * **Surveilr Recording/Tracking:** "Surveilr recorded training attendance and acknowledgment."
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The training logs adequately document that users have acknowledged understanding the session lock requirements."

## 3. Overall Alignment with Control's Intent and Spirit

* **Assessment:** Partially compliant; while human attestation is satisfactory, the machine attestation does not meet the defined time requirement for session locks.
* **Justification:** The organization demonstrates a commitment to session locking through user training and logging, but the technical implementation fails to satisfy the control’s intent of immediate session locking after inactivity.
* **Critical Gaps in Spirit (if applicable):** The delay in session locking fails to protect sensitive information effectively, which is the spirit of the control.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** FAIL
* **Comprehensive Rationale:** The audit uncovered that while documentation and human attestation processes are compliant, the automated session lock implementation does not adhere to the required timeframe, resulting in a failure to protect sensitive data adequately.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * "Missing logs that demonstrate session locks are initiated within 5 minutes of inactivity."
* **Specific Non-Compliant Evidence Required Correction:**
    * "The current session lock implementation must be adjusted to ensure locks occur within the 5-minute timeframe."
* **Required Human Action Steps:**
    * "Engage IT Security to review and modify the session lock policy to comply with the 5-minute requirement."
    * "Verify and retest the session lock functionality to ensure compliance."
* **Next Steps for Re-Audit:** "Upon correction, submit session lock implementation logs for re-evaluation."