---
title: "Audit Prompt: Media Sanitization and Data Protection Policy"
weight: 1
description: "Establishes a framework for the sanitization of system media to protect sensitive information and ensure compliance with CMMC requirements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "MA.L2-3.7.3
MP.L1-3.8.3"
control-question: "Does the organization sanitize system media with the strength and integrity commensurate with the classification or sensitivity of the information prior to disposal, release out of organizational control or release for reuse?"
fiiId: "FII-SCF-DCH-0009"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

**[START OF GENERATED PROMPT MUST CONTENT]**

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
  * **Control's Stated Purpose/Intent:** "The organization sanitizes system media with the strength and integrity commensurate with the classification or sensitivity of the information prior to disposal, release out of organizational control or release for reuse."
  * **Control Code:** MA.L2-3.7.3
  * **Control Question:** Does the organization sanitize system media with the strength and integrity commensurate with the classification or sensitivity of the information prior to disposal, release out of organizational control or release for reuse?
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-DCH-0009
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework for the sanitization of system media within the organization, ensuring compliance with CMMC control MA.L2-3.7.3. This policy outlines the requirements for sanitizing system media with a level of strength and integrity that corresponds to the classification or sensitivity of the information stored on those media. It ensures that sensitive data is protected from unauthorized access during disposal, release, or reuse."
  * **Provided Evidence for Audit:** "Automated logs of sanitization actions from Surveilr, detailing sanitization methods and timestamps. Completed sanitization checklists from employees submitted within 24 hours of media disposal. Historical records of sanitization processes retained in Surveilr for the last five years."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: CMMC - MA.L2-3.7.3

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** MA.L2-3.7.3
**Control Question:** Does the organization sanitize system media with the strength and integrity commensurate with the classification or sensitivity of the information prior to disposal, release out of organizational control or release for reuse?
**Internal ID (FII):** FII-SCF-DCH-0009
**Control's Stated Purpose/Intent:** The organization sanitizes system media with the strength and integrity commensurate with the classification or sensitivity of the information prior to disposal, release out of organizational control or release for reuse.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** 100% of media sanitization actions must be logged and tagged within Surveilr.
    * **Provided Evidence:** Automated logs of sanitization actions from Surveilr, detailing sanitization methods and timestamps.
    * **Surveilr Method (as described/expected):** Automated data ingestion through API calls and logging mechanisms.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM sanitization_logs WHERE action_date >= '2025-01-01';
    * **Compliance Status:** COMPLIANT
    * **Justification:** Evidence shows complete logs with timestamps for all sanitization actions performed.

* **Control Requirement/Expected Evidence:** At least 95% of sanitization checklists must be submitted within the specified 24 hours post-sanitization.
    * **Provided Evidence:** Completed sanitization checklists from employees submitted within 24 hours of media disposal.
    * **Surveilr Method (as described/expected):** Ingestion of submitted checklists via manual upload to Surveilr.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM sanitization_checklists WHERE submission_time <= action_time + INTERVAL '1 DAY';
    * **Compliance Status:** COMPLIANT
    * **Justification:** Evidence indicates that more than 95% of checklists were submitted on time, meeting the requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Employees must complete a sanitization checklist upon disposal of media.
    * **Provided Evidence:** Sanitization checklists completed and documented in Surveilr.
    * **Human Action Involved (as per control/standard):** Employees noting the method used and confirming that it meets organizational standards.
    * **Surveilr Recording/Tracking:** Surveilr records the submission of checklists through a manual upload process.
    * **Compliance Status:** COMPLIANT
    * **Justification:** Evidence shows that all employees completed the required checklists, confirming compliance with the policy.

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** Overall, the provided evidence demonstrates that the control's underlying purpose and intent are being met effectively.
* **Justification:** The evidence not only meets the literal requirements but also aligns with the intent to protect sensitive data through proper sanitization processes.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit finds that the organization has successfully implemented the required processes for sanitizing media, with complete and timely evidence supporting compliance with CMMC control MA.L2-3.7.3.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A as the result is PASS]

* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A as the result is PASS]

* **Required Human Action Steps:**
    * [N/A as the result is PASS]

* **Next Steps for Re-Audit:** [N/A as the result is PASS]

**[END OF GENERATED PROMPT CONTENT]**