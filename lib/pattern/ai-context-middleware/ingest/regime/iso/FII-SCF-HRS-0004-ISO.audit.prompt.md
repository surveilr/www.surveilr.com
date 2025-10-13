---
title: "Audit Prompt: Personnel Security Risk Management Policy"
weight: 1
description: "Establishes a systematic personnel security risk management process to screen individuals before granting access to sensitive information and systems."
publishDate: "2025-10-11"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-HRS-0004"
control-question: "Does the organization manage personnel security risk by screening individuals prior to authorizing access?"
fiiId: "FII-SCF-HRS-0004"
regimeType: "ISO"
category: ["ISO", "Compliance"]
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

  * **Audit Standard/Framework:** ISO 27001
  * **Control's Stated Purpose/Intent:** "To manage personnel security risk by screening individuals prior to authorizing access."
Control Code: FII-SCF-HRS-0004,
Control Question: Does the organization manage personnel security risk by screening individuals prior to authorizing access?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-HRS-0004
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The organization is committed to mitigating personnel security risks by implementing a thorough screening process for all individuals who require access to sensitive information and systems. This policy is guided by the principles of due diligence, privacy, and compliance with applicable laws and regulations. The organization must ensure that all individuals who are authorized to access sensitive information undergo a robust screening process, including automated background checks and signed records of completion."
  * **Provided Evidence for Audit:** "1. API integration results showing background checks completed for 100% of new hires within the last quarter. 2. Signed background check records for all employees uploaded to Surveilr for review with timestamps of completion. 3. Access logs for sensitive systems demonstrating no unauthorized access incidents related to personnel security."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: ISO 27001 - FII-SCF-HRS-0004

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., ISO Compliance Auditor]
**Control Code:** FII-SCF-HRS-0004
**Control Question:** Does the organization manage personnel security risk by screening individuals prior to authorizing access?
**Internal ID (FII):** FII-SCF-HRS-0004
**Control's Stated Purpose/Intent:** To manage personnel security risk by screening individuals prior to authorizing access.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must ensure that all individuals who are authorized to access sensitive information undergo a robust screening process.
    * **Provided Evidence:** API integration results showing background checks completed for 100% of new hires within the last quarter.
    * **Surveilr Method (as described/expected):** API integration with third-party background check services.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM screenings WHERE status = 'completed' AND date >= '2025-01-01';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence clearly shows that all individuals underwent screenings before access approval, meeting the control requirement.

* **Control Requirement/Expected Evidence:** Human attestation of background checks.
    * **Provided Evidence:** Signed background check records for all employees uploaded to Surveilr.
    * **Surveilr Method (as described/expected):** Uploading signed records to Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed records provide verifiable evidence of human attestation concerning the completion of necessary background checks.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Records of manual verification of security screenings.
    * **Provided Evidence:** Access logs for sensitive systems demonstrating no unauthorized access incidents related to personnel security.
    * **Human Action Involved (as per control/standard):** Department Managers ensuring compliance through reporting personnel incidents.
    * **Surveilr Recording/Tracking:** Logs maintained in Surveilr for all access attempts.
    * **Compliance Status:** COMPLIANT
    * **Justification:** Evidence shows there were no unauthorized access attempts, indicating that the screening process is effectively managed.

## 3. Overall Alignment with Control's Intent Spirit

* **Assessment:** The provided evidence demonstrates that the control's underlying purpose and intent are being met in practice through automated and human verification methods.
* **Justification:** The organization has implemented a comprehensive screening process that effectively mitigates personnel security risks as outlined in the policy.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings demonstrate compliance with all machine and human attestation requirements of the control. Evidence shows that the organization effectively screens personnel prior to granting access.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** 
    * [N/A]
* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A]
* **Required Human Action Steps:**
    * [N/A]
* **Next Steps for Re-Audit:** 
    * [N/A] 

**[END OF GENERATED PROMPT CONTENT]**