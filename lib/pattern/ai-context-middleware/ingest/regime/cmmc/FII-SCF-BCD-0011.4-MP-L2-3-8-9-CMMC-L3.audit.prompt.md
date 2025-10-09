---
title: "Audit Prompt: Backup Information Cryptography Policy"
weight: 1
description: "Implement robust cryptographic measures to ensure the confidentiality and integrity of backup information across all organizational systems and environments."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "MP.L2-3.8.9"
control-question: "Are cryptographic mechanisms utilized to prevent the unauthorized disclosure and/or modification of backup information?"
fiiId: "FII-SCF-BCD-0011.4"
regimeType: "CMMC"
cmmcLevel: 3
domain: "Business Continuity & Disaster Recovery"
category: ["CMMC", "Level 3", "Compliance"]
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

  * **Audit Standard/Framework:** CMMC
  * **Control's Stated Purpose/Intent:** "To ensure that cryptographic mechanisms are utilized to prevent the unauthorized disclosure and/or modification of backup information."
Control Code: MP.L2-3.8.9,
Control Question: Are cryptographic mechanisms utilized to prevent the unauthorized disclosure and/or modification of backup information?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-BCD-0011.4
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy outlines the commitment of our organization to implement robust cryptographic measures to safeguard backup data, thereby supporting our Business Continuity & Disaster Recovery objectives. All backup data must be encrypted using industry-standard cryptographic algorithms to ensure its confidentiality and integrity throughout its lifecycle."
  * **Provided Evidence for Audit:** "Automated reports generated by OSquery confirming that 100% of backup files are encrypted. The IT manager signed the quarterly backup encryption report within 5 business days of completion."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - MP.L2-3.8.9

**Overall Audit Result: [PASS]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** MP.L2-3.8.9
**Control Question:** Are cryptographic mechanisms utilized to prevent the unauthorized disclosure and/or modification of backup information?
**Internal ID (FII):** FII-SCF-BCD-0011.4
**Control's Stated Purpose/Intent:** To ensure that cryptographic mechanisms are utilized to prevent the unauthorized disclosure and/or modification of backup information.

## 1. Executive Summary

The audit findings indicate compliance with the control requirements. The evidence provided demonstrates that cryptographic mechanisms are effectively utilized to protect backup information from unauthorized disclosure and modification. The automated reports confirm that all backup files are encrypted, and the IT manager's timely sign-off on the quarterly report further supports compliance.

## 2. Evidence Assessment Against Control Requirements

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** All backup information must be encrypted using approved cryptographic mechanisms to prevent unauthorized access and alterations.
    * **Provided Evidence:** Automated reports generated by OSquery confirming that 100% of backup files are encrypted.
    * **Surveilr Method (as described/expected):** OSquery was used to verify encryption status of backup files and generate automated reports.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM backup_files WHERE encryption_status = 'encrypted';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided evidence shows that all backup files are encrypted as required, meeting the control's expectations.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** The IT manager must sign off on the quarterly backup encryption report, ensuring compliance with this policy.
    * **Provided Evidence:** The IT manager signed the quarterly backup encryption report within 5 business days of completion.
    * **Human Action Involved (as per control/standard):** The IT manager's review and sign-off of the encryption report.
    * **Surveilr Recording/Tracking:** The signed report is stored in Surveilr's evidence repository.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The timely sign-off by the IT manager confirms that the human attestation requirement is met.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the intent and spirit of the control are being met, as all backup information is encrypted, and proper oversight is maintained.
* **Justification:** The combination of machine and human evidence confirms that the organization is effectively using cryptographic mechanisms to protect backup data.
* **Critical Gaps in Spirit (if applicable):** No critical gaps identified; all aspects of the control are satisfied.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided clearly demonstrates compliance with the control requirements, including both machine attestable evidence and human attestation. The organization has effectively implemented cryptographic measures to safeguard backup information.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * N/A (All evidence is present and compliant)
* **Specific Non-Compliant Evidence Required Correction:**
    * N/A (No non-compliant evidence identified)
* **Required Human Action Steps:**
    * N/A (No actions required)
* **Next Steps for Re-Audit:** 
    * N/A (No re-audit necessary)