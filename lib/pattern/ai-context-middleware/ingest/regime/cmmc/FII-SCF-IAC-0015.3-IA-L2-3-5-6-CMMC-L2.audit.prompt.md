---
title: "Audit Prompt: Automated Inactive Account Disabling Policy"
weight: 1
description: "Establishes automated processes to disable inactive user accounts, enhancing security and compliance with CMMC control IA.L2-3.5.6."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "IA.L2-3.5.6"
control-question: "Does the organization use automated mechanisms to disable inactive accounts after an organization-defined time period?"
fiiId: "FII-SCF-IAC-0015.3"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You're an **official auditor (e.g., CMMC Auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

**Understanding Surveilr, Machine Attestation, and Human Attestation (for Evidence Assessment):**

  * **Surveilr's Core Function:** Surveilr is a platform designed to automate the collection, storage, and querying of compliance evidence. It ensures cybersecurity, quality metrics, and regulatory compliance efforts are backed by a **SQL-queryable private evidence warehouse (Resource Surveillance State Database - RSSD)**.
  * **Machine Attestable Evidence (Preferred):** This means control adherence can be automatically verified by a machine or system, not relying on manual human checks. Surveilr achieves this by:
      * **Automated Data Ingestion:** Collecting evidence from various systems via methods like `OSquery` (for endpoint data, processes, configurations), `API calls` (for cloud service configurations, SaaS data), `file ingestion` (for logs, configuration files), `task ingestion` (for scheduled jobs, script outputs), or `capturing executable outputs` (for custom script results).
      * **SQL-Queryable Data:** Storing this evidence in a universal schema within the RSSD, making it fully queryable using standard SQL.
      * **Automated Verification:** Control checks are performed by running specific SQL queries against the collected, machine-attestable evidence in the RSSD.
  * **Human Attestation (When Necessary):** This involves individuals manually verifying and certifying that compliance controls and processes are in place and functioning effectively. It relies on human judgment, review, or direct declaration.
      * **Examples:** Manual review of a physical security log, a manager's signed declaration that all employees completed training, a verbal confirmation of a procedure, a visual inspection of a data center.
      * **Limitations:** Human attestation is prone to subjective interpretation, error, oversight, and is less scalable and auditable than machine attestation. It should be used as a last resort or for aspects truly beyond current machine capabilities.
      * **Surveilr's Role (for Human Attestation):** While Surveilr primarily focuses on machine evidence, it *can* record the *act* of human attestation (e.g., storing a signed document, recording an email confirmation, or noting the date of a manual review). However, it doesn't *verify* the content of the human attestation itself in the same automated way it verifies machine evidence. The evidence of human attestation in Surveilr would be the record of the attestation itself, not necessarily the underlying compliance directly.
  * **Goal of Audit:** To definitively determine if the provided evidence, through both machine and human attestation methods, sufficiently demonstrates compliance with the control.

**Audit Context:**

  * **Audit Standard/Framework:** CMMC
  * **Control's Stated Purpose/Intent:** "The purpose of this control is to ensure that the organization uses automated mechanisms to disable inactive accounts after an organization-defined time period."
  * **Control Code:** IA.L2-3.5.6
  * **Control Question:** Does the organization use automated mechanisms to disable inactive accounts after an organization-defined time period?
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-IAC-0015.3
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish guidelines for the automated disabling of inactive user accounts as required by the CMMC control IA.L2-3.5.6. This control emphasizes the importance of maintaining an effective identification and authentication process by ensuring that inactive accounts are systematically disabled, thereby minimizing potential security risks. The organization commits to using automated mechanisms to disable inactive accounts within a defined period of inactivity. This policy mandates the implementation of machine attestation methods to ensure compliance and security while defining human attestation where automation is not feasible."
  * **Provided Evidence for Audit:** 
    "Evidence collected includes:
    - Daily OSquery results indicating active user accounts and their last active timestamps.
    - System logs demonstrating automated disabling actions taken on accounts after 90 days of inactivity.
    - Signed quarterly user account review report from the IT Manager, stored in Surveilr."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - IA.L2-3.5.6

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [CMMC Auditor]
**Control Code:** IA.L2-3.5.6
**Control Question:** Does the organization use automated mechanisms to disable inactive accounts after an organization-defined time period?
**Internal ID (FII):** FII-SCF-IAC-0015.3
**Control's Stated Purpose/Intent:** The purpose of this control is to ensure that the organization uses automated mechanisms to disable inactive accounts after an organization-defined time period.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must disable inactive accounts after a defined period.
    * **Provided Evidence:** Daily OSquery results indicating active user accounts and their last active timestamps.
    * **Surveilr Method (as described/expected):** OSquery to collect user account activity data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM users WHERE last_active < CURRENT_DATE - INTERVAL '90 days';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The daily OSquery results show that user accounts inactive for over 90 days are being successfully identified and disabled.

* **Control Requirement/Expected Evidence:** Evidence of account disabling actions.
    * **Provided Evidence:** System logs demonstrating automated disabling actions taken.
    * **Surveilr Method (as described/expected):** Automated logging of account disabling actions.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM actions WHERE action_type = 'disable_account' AND action_date >= CURRENT_DATE - INTERVAL '90 days';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The system logs confirm that accounts are being disabled in accordance with the policy.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Signed quarterly user account review report.
    * **Provided Evidence:** Signed quarterly user account review report from the IT Manager.
    * **Human Action Involved (as per control/standard):** The IT Manager's signature on the report.
    * **Surveilr Recording/Tracking:** Report stored in Surveilr for compliance tracking.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report provides evidence of the required human attestation confirming the review of user accounts.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization is actively using automated mechanisms to manage inactive accounts, aligning well with the control's intent.
* **Justification:** The combination of automated actions and human oversight ensures that the organization minimizes security risks associated with inactive accounts.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided clearly meets the control requirements and demonstrates both machine and human attestation methods effectively. No gaps in compliance were identified.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** [If applicable]
* **Specific Non-Compliant Evidence Required Correction:** [If applicable]
* **Required Human Action Steps:** [If applicable]
* **Next Steps for Re-Audit:** [If applicable] 

**[END OF GENERATED PROMPT CONTENT]**