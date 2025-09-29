---
title: "Audit Prompt: Backup Data Encryption Compliance Policy"
weight: 1
description: "Ensure the encryption of backup information to protect its confidentiality and integrity, supporting compliance and business continuity efforts."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "MP.L2-3.8.9"
control-question: "Are cryptographic mechanisms utilized to prevent the unauthorized disclosure and/or modification of backup information?"
fiiId: "FII-SCF-BCD-0011.4"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Business Continuity & Disaster Recovery"
category: ["CMMC", "Level 2", "Compliance"]
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

  * **Audit Standard/Framework:** CMMC
  * **Control's Stated Purpose/Intent:** "To ensure the integrity and confidentiality of backup information through the use of cryptographic mechanisms, preventing unauthorized disclosure and modification."
Control Code: MP.L2-3.8.9,
Control Question: Are cryptographic mechanisms utilized to prevent the unauthorized disclosure and/or modification of backup information?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-BCD-0011.4
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy outlines the organization's commitment to ensuring the integrity and confidentiality of backup information through the use of cryptographic mechanisms. It is essential for maintaining Business Continuity & Disaster Recovery (BCDR) by preventing unauthorized disclosure and modification of critical data. The implementation of this policy is crucial for safeguarding sensitive information and ensuring compliance with regulatory requirements."
  * **Provided Evidence for Audit:** "Automated reports indicating that 100% of backup files are encrypted using AES-256 encryption. Signed manager verification report confirming encryption status of backup files dated 2025-07-01."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - MP.L2-3.8.9

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** MP.L2-3.8.9
**Control Question:** Are cryptographic mechanisms utilized to prevent the unauthorized disclosure and/or modification of backup information?
**Internal ID (FII):** FII-SCF-BCD-0011.4
**Control's Stated Purpose/Intent:** To ensure the integrity and confidentiality of backup information through the use of cryptographic mechanisms, preventing unauthorized disclosure and modification.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** All backup information must be encrypted using approved cryptographic mechanisms to prevent unauthorized access and modifications.
    * **Provided Evidence:** Automated reports indicating that 100% of backup files are encrypted using AES-256 encryption.
    * **Surveilr Method (as described/expected):** Automated tools utilized to verify the encryption status of backup files.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM backup_files WHERE encryption_status = 'encrypted';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence provided demonstrates that all backup files are encrypted as required by the control, meeting the specified encryption standard.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** A designated manager must sign off on encryption verification reports to confirm that all backup information is adequately protected.
    * **Provided Evidence:** Signed manager verification report confirming encryption status of backup files dated 2025-07-01.
    * **Human Action Involved (as per control/standard):** Manager's review and sign-off on encryption verification.
    * **Surveilr Recording/Tracking:** The signed report is stored in Surveilr as evidence of human attestation.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed manager verification report confirms that the encryption status has been reviewed and approved, fulfilling the human attestation requirement.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** The automated reports and signed manager verification collectively confirm that backup information is encrypted, thereby preventing unauthorized disclosure and modification.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided sufficiently demonstrates compliance with the control requirements and intent, with all backup files encrypted and verified by management.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [For each missing piece of evidence identified in Section 2, state *exactly* what is needed.]
    * [Specify the required format/type for each missing piece.]
* **Specific Non-Compliant Evidence Required Correction:**
    * [For each instance of non-compliant evidence identified in Section 2, clearly state *why* it is non-compliant and what *specific correction* is required.]
    * [Specify the action needed.]
* **Required Human Action Steps:**
    * [List precise steps a human auditor or compliance officer needs to take.]
    * [Specify which teams or individuals are responsible for producing or correcting the evidence.]
* **Next Steps for Re-Audit:** [Outline the process for re-submission of the corrected/missing evidence for re-evaluation.]