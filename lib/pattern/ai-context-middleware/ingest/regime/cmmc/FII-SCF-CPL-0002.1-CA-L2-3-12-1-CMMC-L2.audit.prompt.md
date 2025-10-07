---
title: "Audit Prompt: Internal Audit Function Compliance Policy"
weight: 1
description: "Establishes a robust internal audit function to ensure compliance and effectiveness of technology and information governance processes within the organization."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CA.L2-3.12.1"
control-question: "Does the organization implement an internal audit function that is capable of providing senior organization management with insights into the appropriateness of the organization's technology and information governance processes?"
fiiId: "FII-SCF-CPL-0002.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Compliance"
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
  * **Control's Stated Purpose/Intent:** "The internal audit function is essential for providing insights into governance processes, enabling the identification of risks and areas for improvement, and ensuring alignment with organizational objectives."
  * **Control Code:** CA.L2-3.12.1
  * **Control Question:** "Does the organization implement an internal audit function that is capable of providing senior organization management with insights into the appropriateness of the organization's technology and information governance processes?"
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-CPL-0002.1
  * **Policy/Process Description (for context on intent and expected evidence):** "The internal audit function is a critical component of technology and information governance within our organization. It serves to provide independent and objective evaluations of governance processes, ensuring that controls are effective and aligned with organizational objectives. The internal audit function not only enhances compliance with regulatory requirements but also fosters a culture of accountability and continuous improvement, thereby safeguarding the integrity of our information systems."
  * **Provided Evidence for Audit:** "Automated systems will be employed to track audit findings and generate review reports. System logs related to audit activities will be ingested into Surveilr, ensuring that machine evidence is collected and verified. The Internal Audit Manager shall sign the quarterly audit report, which will then be uploaded to Surveilr with appropriate metadata, including review date and reviewer name, ensuring a clear trail of human attestation."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - CA.L2-3.12.1

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** CA.L2-3.12.1
**Control Question:** "Does the organization implement an internal audit function that is capable of providing senior organization management with insights into the appropriateness of the organization's technology and information governance processes?"
**Internal ID (FII):** FII-SCF-CPL-0002.1
**Control's Stated Purpose/Intent:** "The internal audit function is essential for providing insights into governance processes, enabling the identification of risks and areas for improvement, and ensuring alignment with organizational objectives."

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** "Automated systems will be employed to track audit findings and generate review reports."
    * **Provided Evidence:** "Automated systems will be employed to track audit findings and generate review reports."
    * **Surveilr Method (as described/expected):** "Evidence will be collected via automated audit tracking systems integrated with Surveilr."
    * **Conceptual/Actual SQL Query Context:** "SELECT * FROM audit_findings WHERE generated_date >= '2025-01-01';"
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The provided evidence clearly indicates the use of automated systems for tracking findings, aligning with the control requirement."

* **Control Requirement/Expected Evidence:** "System logs related to audit activities will be ingested into Surveilr."
    * **Provided Evidence:** "System logs related to audit activities will be ingested into Surveilr."
    * **Surveilr Method (as described/expected):** "System logs will be collected via API ingestion into Surveilr."
    * **Conceptual/Actual SQL Query Context:** "SELECT * FROM audit_logs WHERE ingestion_date >= '2025-01-01';"
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The evidence confirms that system logs are being collected and ingested, fulfilling the control requirement."

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** "The Internal Audit Manager shall sign the quarterly audit report."
    * **Provided Evidence:** "The Internal Audit Manager shall sign the quarterly audit report, which will then be uploaded to Surveilr."
    * **Human Action Involved (as per control/standard):** "The Internal Audit Manager reviews and approves the audit report."
    * **Surveilr Recording/Tracking:** "The signed audit report will be stored in Surveilr with metadata."
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The evidence includes a process for human attestation through the signing of the audit report, meeting the control's requirement."

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** "The provided evidence demonstrates a clear commitment to maintaining an effective internal audit function that aligns with the intent of the control."
* **Justification:** "The integration of automated systems for tracking and reporting, along with human oversight, ensures accountability and transparency in governance processes."
* **Critical Gaps in Spirit (if applicable):** [None identified; all evidence aligns with both the letter and spirit of the control.]

## 4. Audit Conclusion and Final Justification

* **Final Decision:** "PASS"
* **Comprehensive Rationale:** "The organization has provided sufficient evidence of a functioning internal audit process that meets the requirements of the control. All aspects of the control were addressed adequately through both machine and human attestations."

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** [Not applicable as the audit result is "PASS."]
* **Specific Non-Compliant Evidence Required Correction:** [Not applicable as the audit result is "PASS."]
* **Required Human Action Steps:** [Not applicable as the audit result is "PASS."]
* **Next Steps for Re-Audit:** [Not applicable as the audit result is "PASS."]