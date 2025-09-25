---
title: "Audit Prompt: ePHI Access Termination Policy"
weight: 1
description: "Establishes procedures for promptly terminating access to electronic Protected Health Information upon employee exit."
publishDate: "2025-09-25"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "164.308(a)(3)(ii)(C)"
control-question: "Have you implemented procedures for terminating access to EPHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section? (A)"
fiiId: "FII-SCF-IAC-0007.2"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance"]
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

  * **Audit Standard/Framework:** [HIPAA]
** Control's Stated Purpose/Intent:** "Terminate access to electronic Protected Health Information (ePHI) when an employee exits the organization or as mandated."
Control Code: 164.308(a)(3)(ii)(C),
Control Question: "Have you implemented procedures for terminating access to EPHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section? (A)"
Internal ID (Foreign Integration Identifier as FII): FII-SCF-IAC-0007.2
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish procedures for terminating access to electronic Protected Health Information (ePHI) when an employee exits the organization or as mandated. This policy aims to ensure compliance with regulatory requirements and maintain the confidentiality, integrity, and availability of ePHI. Access to ePHI must be terminated promptly to mitigate risks associated with unauthorized access. This policy outlines the procedures, responsibilities, and methods for both machine and human attestation regarding access termination."
  * **Provided Evidence for Audit:** "Automated access logs collected via OSquery show that employee access to ePHI is disabled within 24 hours of termination. Weekly audits were conducted confirming no unauthorized access to ePHI by terminated employees. Signed termination checklists from HR manager are uploaded to Surveilr with relevant metadata."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: HIPAA - 164.308(a)(3)(ii)(C)

**Overall Audit Result: [PASS]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., HIPAA Auditor]
**Control Code:** [Control Code from input]
**Control Question:** [Control Question from input]
**Internal ID (FII):** [FII from input]
**Control's Stated Purpose/Intent:** [Description of intent/goal from input]

## 1. Executive Summary

The audit findings indicate full compliance with the control requirements regarding the termination of access to electronic Protected Health Information (ePHI). The provided evidence demonstrates that access is consistently terminated within the required timeframe, supported by both machine and human attestation. Automated access logs and signed checklists validate adherence to the policy.

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Access to ePHI must be disabled within 24 hours of termination.
    * **Provided Evidence:** Automated access logs confirm that employee access to ePHI is disabled within 24 hours of termination.
    * **Surveilr Method (as described/expected):** OSquery collected access logs daily.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_logs WHERE access_disabled = 'true' AND termination_date <= NOW() - INTERVAL '1 day';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence clearly demonstrates that access is disabled as required, with logs affirming compliance.

* **Control Requirement/Expected Evidence:** Weekly audits show no unauthorized access to ePHI by terminated employees.
    * **Provided Evidence:** Weekly audit reports confirm compliance with no instances of unauthorized access.
    * **Surveilr Method (as described/expected):** Automated weekly audits generated compliance reports.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_logs WHERE access_status = 'unauthorized';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The weekly audit reports provide sufficient evidence of compliance, confirming that no unauthorized access occurred.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Signed termination checklist upon employee exit.
    * **Provided Evidence:** Signed checklists are uploaded to Surveilr with metadata.
    * **Human Action Involved (as per control/standard):** HR manager signs off on the termination checklist upon exit.
    * **Surveilr Recording/Tracking:** Surveilr records the signed checklist and associated metadata.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed checklists provide clear evidence of human attestation, supporting policy adherence.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence aligns with the control's intent to ensure the timely termination of ePHI access.
* **Justification:** All aspects of the control's requirements are met through both machine and human attestations, demonstrating a robust approach to compliance.
* **Critical Gaps in Spirit (if applicable):** No critical gaps identified; evidence fully supports the control's intent.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings confirm compliance with the control requirements, as evidenced by automated logs, audit reports, and human attestations. All evidence aligns with the intended purpose of the control.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A - No missing evidence identified.]
* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A - No non-compliant evidence identified.]
* **Required Human Action Steps:**
    * [N/A - No action required; compliance achieved.]
* **Next Steps for Re-Audit:** [N/A - Compliance confirmed; no re-audit necessary.]