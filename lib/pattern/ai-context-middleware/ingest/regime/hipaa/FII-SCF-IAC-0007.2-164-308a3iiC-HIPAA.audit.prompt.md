---
title: "Audit Prompt: ePHI Access Termination Policy"
weight: 1
description: "Terminate access to ePHI promptly when employees leave or no longer require access to ensure security compliance."
publishDate: "2025-09-26"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "164.308(a)(3)(ii)(C)"
control-question: "Have you implemented procedures for terminating access to EPHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section? (A)"
fiiId: "FII-SCF-IAC-0007.2"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance"]
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

  * **Audit Standard/Framework:** HIPAA
  * **Control's Stated Purpose/Intent:** "To ensure that access to electronic Protected Health Information (ePHI) is terminated promptly when an employee leaves the organization or as required by applicable regulations."
Control Code: 164.308(a)(3)(ii)(C),
Control Question: "Have you implemented procedures for terminating access to ePHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section?"
Internal ID (Foreign Integration Identifier as FII): FII-SCF-IAC-0007.2
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy outlines the procedures for terminating access to electronic Protected Health Information (ePHI) when an employee leaves the organization or as mandated by applicable regulations. It ensures that access to sensitive information is revoked in a timely and secure manner, minimizing the risk of unauthorized access. All employees, contractors, and third-party vendors must have their access to ePHI terminated promptly upon termination of employment or contract, or when access is no longer required. This policy adheres to the Health Insurance Portability and Accountability Act (HIPAA) regulations and is designed to ensure compliance through SMART guidelines."
  * **Provided Evidence for Audit:** 
    "1. Automated alerts generated by the access control system for accounts remaining active beyond the termination notice period. 
    2. HR provided signed termination notices for three recent employees who left the organization, which include the dates of termination.
    3. IT Security logs showing access terminations that occurred within 2 hours of HR notification for the last quarter, logged in Surveilr."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: HIPAA - 164.308(a)(3)(ii)(C)

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** HIPAA Auditor
**Control Code:** 164.308(a)(3)(ii)(C)
**Control Question:** "Have you implemented procedures for terminating access to ePHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section?"
**Internal ID (FII):** FII-SCF-IAC-0007.2
**Control's Stated Purpose/Intent:** "To ensure that access to electronic Protected Health Information (ePHI) is terminated promptly when an employee leaves the organization or as required by applicable regulations."

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Access to ePHI must be terminated promptly when an employee leaves the organization or as required.
    * **Provided Evidence:** Automated alerts generated by the access control system for accounts remaining active beyond the termination notice period.
    * **Surveilr Method (as described/expected):** Automated data ingestion from access control systems via API calls.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_control_logs WHERE action = 'termination' AND timestamp < (CURRENT_TIMESTAMP - INTERVAL '2 hours').
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided evidence demonstrates that automated alerts are generated for accounts remaining active beyond the termination notice period, aligning with the control requirement.

* **Control Requirement/Expected Evidence:** Signed termination notice from HR.
    * **Provided Evidence:** HR provided signed termination notices for three recent employees who left the organization, which include the dates of termination.
    * **Surveilr Method (as described/expected):** Human attestation recorded by storing signed documents in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed termination notices adequately demonstrate compliance with the requirement for human attestation.

* **Control Requirement/Expected Evidence:** IT Security logs showing timely access terminations.
    * **Provided Evidence:** IT Security logs showing access terminations that occurred within 2 hours of HR notification for the last quarter, logged in Surveilr.
    * **Surveilr Method (as described/expected):** Machine attestation of actions logged automatically in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The logs confirm that access terminations were conducted timely, demonstrating adherence to the control requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Human attestation of access termination actions.
    * **Provided Evidence:** IT Security logs showing access terminations logged in Surveilr.
    * **Human Action Involved (as per control/standard):** IT Security team revoking access upon HR notification.
    * **Surveilr Recording/Tracking:** IT Security actions are recorded automatically in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence reflects the manual actions taken by IT Security, aligning with the control's requirement for human attestation.

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** The provided evidence demonstrates that the intent of the control is being met, as access to ePHI is terminated promptly and efficiently upon employee exits.
* **Justification:** The combination of automated alerts, signed termination notices, and timely access logs collectively ensure that the organization adheres to the control's underlying purpose of protecting ePHI.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and  Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings indicate that all aspects of the control were adequately demonstrated through both machine and human attestations, confirming compliance with the control requirements.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A