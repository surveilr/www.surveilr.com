---
title: "Audit Prompt: Job Description Documentation Policy"
weight: 1
description: "Establishes a standardized approach for documenting and managing job descriptions within the organization."
publishDate: "2025-09-25"
publishBy: "AICPA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CC1-0003"
control-question: "Can management provide a sample of (5) company job descriptions?"
fiiId: "FII-SCF-GOV-0004"
regimeType: "SOC2-TypeI"
category: ["AICPA", "Compliance"]
---

You're an **official auditor**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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

  * **Audit Standard/Framework:** [Audit Framework Name]
  * **Control's Stated Purpose/Intent:** "[The purpose of this control is to ensure that company job descriptions are documented and attested to accurately reflect roles and responsibilities within the organization. This is vital for compliance and effective workforce management.]"
  * **Control Code:** CC1-0003
  * **Control Question:** "Can management provide a sample of (5) company job descriptions?"
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-GOV-0004
  * **Policy/Process Description (for context on intent and expected evidence):**
    "[This policy establishes a standardized approach for the documentation and attestation of job descriptions, ensuring clarity, compliance, and effective workforce management. Job descriptions must be documented, reviewed, and maintained, with evidence stored in a centralized HR management system and reviewed quarterly by Department Heads and the Compliance Officer.]"
  * **Provided Evidence for Audit:** "[A sample of 5 job descriptions has been retrieved from the HR management system, with documented timestamps of their creation and last update, along with confirmation emails from Department Heads attesting to their accuracy.]"

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: [Audit Standard/Framework] - CC1-0003

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., HR Compliance Auditor]
**Control Code:** CC1-0003
**Control Question:** Can management provide a sample of (5) company job descriptions?
**Internal ID (FII):** FII-SCF-GOV-0004
**Control's Stated Purpose/Intent:** [The purpose of this control is to ensure that company job descriptions are documented and attested to accurately reflect roles and responsibilities within the organization. This is vital for compliance and effective workforce management.]

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** All job descriptions must be documented and stored in the HR management system.
    * **Provided Evidence:** A sample of 5 job descriptions retrieved from the HR management system.
    * **Surveilr Method (as described/expected):** Utilized the centralized HR management system; changes logged with timestamps.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM job_descriptions WHERE status = 'active'; 
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided evidence fulfills the requirement as it includes documented job descriptions stored in the HR management system with appropriate timestamps.

* **Control Requirement/Expected Evidence:** Evidence of quarterly reviews must exist, with signed attestations from Department Heads.
    * **Provided Evidence:** Confirmation emails from Department Heads verifying the accuracy of job descriptions.
    * **Surveilr Method (as described/expected):** Emails logged in Surveilr with metadata.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM email_confirmations WHERE department_head = 'true'; 
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence provided includes valid confirmations from Department Heads, meeting the review requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Signed documents confirming the accuracy of job descriptions quarterly.
    * **Provided Evidence:** Signed documents uploaded to Surveilr with relevant metadata.
    * **Human Action Involved (as per control/standard):** Department Heads submitted signed documents quarterly.
    * **Surveilr Recording/Tracking:** Signed documents are stored in Surveilr with timestamps.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence includes signed documents confirming the accuracy of job descriptions, fulfilling the requirement.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The evidence demonstrates that the control's underlying purpose and intent are being met.
* **Justification:** The provided evidence not only meets the literal checklist requirements but also shows that job descriptions are being actively managed and reviewed.
* **Critical Gaps in Spirit (if applicable):** None.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings confirm that the organization is compliant with the control requirements, as all job descriptions are documented, reviewed, and attested to accurately.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**