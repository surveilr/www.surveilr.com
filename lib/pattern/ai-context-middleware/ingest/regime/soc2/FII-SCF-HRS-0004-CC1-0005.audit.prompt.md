---
title: "Audit Prompt: Employee Onboarding Policy"
weight: 1
description: "Establishes standardized procedures for effective and compliant employee onboarding across all departments."
publishDate: "2025-09-25"
publishBy: "AICPA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CC1-0005"
control-question: "Has management documented formal HR procedures that include the employee on-boarding process?"
fiiId: "FII-SCF-HRS-0004"
regimeType: "SOC2-TypeI"
category: ["AICPA", "Compliance"]
---

You're an **official auditor (e.g., auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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

  * **Audit Standard/Framework:** [Audit Standard/Framework]
  * **Control's Stated Purpose/Intent:** "[Management must maintain formal documentation of HR procedures that encompass the employee onboarding process. This documentation should ensure compliance, efficiency, and clarity in onboarding new employees.]"
  * **Control Code:** CC1-0005
  * **Control Question:** Has management documented formal HR procedures that include the employee onboarding process?
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-HRS-0004
  * **Policy/Process Description (for context on intent and expected evidence):**
    "[The purpose of this policy is to ensure that management has documented formal Human Resources (HR) procedures that include a comprehensive employee onboarding process. This policy aims to establish a standardized approach that ensures compliance, efficiency, and clarity in onboarding new employees. The documentation should be accessible, regularly updated, and compliant with applicable laws and regulations.]"
  * **Provided Evidence for Audit:** "[Automated document management system tracks revisions to onboarding documentation, quarterly audits conducted to ensure adherence, signed acknowledgment forms from new employees, and manager sign-off on onboarding completion checklists stored in personnel files.]"

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: [Audit Standard/Framework] - CC1-0005

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., HR Compliance Auditor]
**Control Code:** CC1-0005
**Control Question:** Has management documented formal HR procedures that include the employee onboarding process?
**Internal ID (FII):** FII-SCF-HRS-0004
**Control's Stated Purpose/Intent:** Management must maintain formal documentation of HR procedures that encompass the employee onboarding process. This documentation should ensure compliance, efficiency, and clarity in onboarding new employees.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Formal documentation of HR procedures for employee onboarding must be maintained and reviewed biannually.
    * **Provided Evidence:** Automated document management system tracks revisions to onboarding documentation.
    * **Surveilr Method (as described/expected):** Automated Document Management System.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM onboarding_docs WHERE updated_at > LAST_BIANNUAL_REVIEW_DATE;
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that the onboarding documentation is being tracked and reviewed as required.

* **Control Requirement/Expected Evidence:** Evidence of onboarding completion must be available for all new hires within 30 days of their start date.
    * **Provided Evidence:** Manager sign-off on onboarding completion checklists stored in personnel files.
    * **Surveilr Method (as described/expected):** Scheduled audits and checks against employee records.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM onboarding_completions WHERE completed_at <= DATE_ADD(start_date, INTERVAL 30 DAY);
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence confirms that onboarding completion is documented within the specified timeframe.

* **Control Requirement/Expected Evidence:** At least 95% of new hires must complete the onboarding process as per documented procedures.
    * **Provided Evidence:** Quarterly audits show compliance rates of 97% for new hires completing onboarding.
    * **Surveilr Method (as described/expected):** Automated data ingestion from HR records.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM new_hires WHERE onboarding_completed = TRUE;
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence indicates compliance with the onboarding completion percentage requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Each new employee must sign an acknowledgment form indicating they have reviewed the onboarding materials.
    * **Provided Evidence:** Signed acknowledgment forms stored securely.
    * **Human Action Involved (as per control/standard):** New employees must review and acknowledge onboarding materials.
    * **Surveilr Recording/Tracking:** HR team verifies and stores acknowledgment forms.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence confirms that all new employees have signed acknowledgment forms as required.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence satisfactorily demonstrates adherence to both the letter and the spirit of the control.
* **Justification:** The documented HR procedures and evidence of onboarding completion reflect a commitment to an effective onboarding process.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings show comprehensive documentation and adherence to onboarding procedures, fulfilling both the requirements and the intent of the control.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A