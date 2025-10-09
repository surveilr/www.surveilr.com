---
title: "Audit Prompt: Change Management Security Policy"
weight: 1
description: "Establishes a structured approach to manage changes, ensuring compliance, minimizing disruptions, and maintaining system integrity across the organization."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "TBD - 3.4.1e
TBD - 3.4.2e"
control-question: "Does the organization facilitate the implementation of a change management program?"
fiiId: "FII-SCF-CHG-0001"
regimeType: "CMMC"
cmmcLevel: 3
domain: "Change Management"
category: ["CMMC", "Level 3", "Compliance"]
---

You're an **official auditor (e.g.,  auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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
  * **Control's Stated Purpose/Intent:** "The organization facilitates the implementation of a change management program."
Control Code: TBD - 3.4.1e
Control Question: Does the organization facilitate the implementation of a change management program?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-CHG-0001
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this Change Management Policy is to establish a structured approach to managing changes within the organization. Effective change management is crucial for minimizing disruptions, ensuring compliance, and maintaining the integrity of systems and data. This policy outlines the procedures and responsibilities necessary to facilitate controlled and documented changes across all relevant environments."
  * **Provided Evidence for Audit:** "Automated change management logs from Surveilr showing all changes documented, risk assessments conducted, and approvals obtained. Additionally, scanned copies of signed change request forms and stakeholder approvals ingested into Surveilr for verification."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - TBD - 3.4.1e

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** TBD - 3.4.1e
**Control Question:** Does the organization facilitate the implementation of a change management program?
**Internal ID (FII):** FII-SCF-CHG-0001
**Control's Stated Purpose/Intent:** The organization facilitates the implementation of a change management program.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** All changes must be documented, assessed for risk, approved by relevant stakeholders, and communicated to affected parties.
    * **Provided Evidence:** Automated change management logs from Surveilr showing all changes documented, risk assessments conducted, and approvals obtained.
    * **Surveilr Method (as described/expected):** Automated data ingestion via API integration with the change management system.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM change_management_logs WHERE change_date >= '2025-01-01' AND status = 'approved';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided evidence clearly shows that all changes are documented, assessed for risk, and approved by relevant stakeholders, meeting the control's requirements.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Personnel must submit change request forms, maintain change logs, and provide evidence of stakeholder approvals.
    * **Provided Evidence:** Scanned copies of signed change request forms and stakeholder approvals ingested into Surveilr for verification.
    * **Human Action Involved (as per control/standard):** Submission of change request forms and approvals by stakeholders.
    * **Surveilr Recording/Tracking:** Surveilr has recorded the submission of these forms as part of the evidence.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence of signed change request forms and stakeholder approvals demonstrates compliance with the requirement for human attestation.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization is effectively facilitating the implementation of a change management program.
* **Justification:** The evidence aligns with the control's intent by showing structured documentation, risk assessment, and stakeholder involvement in the change management process.
* **Critical Gaps in Spirit (if applicable):** None identified; all aspects of the control's intent are met.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings indicate that the organization has successfully implemented a change management program that meets both the literal requirements and the underlying intent of the control. All necessary evidence has been provided and assessed as compliant.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** [N/A]
* **Specific Non-Compliant Evidence Required Correction:** [N/A]
* **Required Human Action Steps:** [N/A]
* **Next Steps for Re-Audit:** [N/A]

**[END OF GENERATED PROMPT CONTENT]**