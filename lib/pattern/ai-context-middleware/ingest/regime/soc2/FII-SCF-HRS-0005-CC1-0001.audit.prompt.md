---
title: "Audit Prompt: Core Values Communication Policy"
weight: 1
description: "Communicates core values to all employees through the employee handbook and training programs."
publishDate: "2025-09-25"
publishBy: "AICPA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CC1-0001"
control-question: "Are core values communicated from executive management to personnel through policies and the employee handbook?"
fiiId: "FII-SCF-HRS-0005"
regimeType: "SOC2-TypeI"
category: ["AICPA", "Compliance"]
---

You're an **official auditor (e.g., auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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

- **Audit Standard/Framework:** [****]
- **Control's Stated Purpose/Intent:** "To ensure that core values are effectively communicated from executive management to personnel through well-defined policies and the employee handbook."
  - Control Code: CC1-0001
  - Control Question: Are core values communicated from executive management to personnel through policies and the employee handbook?
  - Internal ID (Foreign Integration Identifier as FII): FII-SCF-HRS-0005
- **Policy/Process Description (for context on intent and expected evidence):**
  "The purpose of this policy is to ensure that core values are effectively communicated from executive management to personnel through well-defined policies and the employee handbook. This communication is essential for fostering a cohesive organizational culture and aligning employee behavior with the organization's values. It is the policy of the organization that core values will be communicated clearly and consistently to all personnel through the employee handbook and relevant policies. This will ensure that all employees understand and embody these values in their daily work."
- **Provided Evidence for Audit:** "1. Employee handbook version 3.1 dated 2025-01-15, accessible to all employees. 2. Training completion records for core values training showing 95% employee completion within 30 days of employment. 3. Signed acknowledgment forms from employees confirming understanding of core values, uploaded to Surveilr."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: [Audit Standard/Framework] - CC1-0001

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., Compliance Auditor]
**Control Code:** [CC1-0001]
**Control Question:** [Are core values communicated from executive management to personnel through policies and the employee handbook?]
**Internal ID (FII):** [FII-SCF-HRS-0005]
**Control's Stated Purpose/Intent:** [To ensure that core values are effectively communicated from executive management to personnel through well-defined policies and the employee handbook.]

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Evidence that all employees have received and acknowledged the core values communication.
    * **Provided Evidence:** Employee handbook version 3.1 dated 2025-01-15, accessible to all employees.
    * **Surveilr Method (as described/expected):** Automated systems to track updates to the employee handbook.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM rssd WHERE document_type='employee_handbook' AND version='3.1' AND date_accessible='2025-01-15';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence confirms that the latest version of the employee handbook was made accessible to all employees, meeting the control requirement.

* **Control Requirement/Expected Evidence:** Documentation showing that all employees have completed training on core values within 30 days of employment.
    * **Provided Evidence:** Training completion records for core values training showing 95% employee completion within 30 days of employment.
    * **Surveilr Method (as described/expected):** Utilization of a learning management system to track training completion.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM rssd WHERE training_topic='core_values' AND completion_date <= '30 days from employment';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence shows a high completion rate within the specified timeframe, demonstrating effective communication of core values.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Signed acknowledgment forms from employees confirming their understanding of core values.
    * **Provided Evidence:** Signed acknowledgment forms from employees, uploaded to Surveilr.
    * **Human Action Involved (as per control/standard):** HR collecting signed acknowledgment forms from all employees.
    * **Surveilr Recording/Tracking:** Stored in Surveilr with appropriate metadata.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The existence of signed forms confirms that employees have acknowledged understanding the core values, fulfilling the requirement.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence adequately demonstrates that core values are communicated effectively from executive management to personnel.
* **Justification:** All aspects of the control's intent have been met through the documentation and evidence provided.
* **Critical Gaps in Spirit (if applicable):** No critical gaps identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence presented meets all control requirements and aligns with the intent of ensuring core values are communicated effectively.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A - All evidence is compliant.]
* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A - All evidence is compliant.]
* **Required Human Action Steps:**
    * [N/A - All evidence is compliant.]
* **Next Steps for Re-Audit:** [N/A - All evidence is compliant.]