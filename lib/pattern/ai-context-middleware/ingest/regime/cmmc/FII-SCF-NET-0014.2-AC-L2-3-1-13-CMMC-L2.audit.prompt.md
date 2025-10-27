---
title: "Audit Prompt: Remote Access Cryptography Security Policy"
weight: 1
description: "Establishes robust cryptographic mechanisms to secure all remote access sessions, ensuring confidentiality and integrity of sensitive information."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L2-3.1.13"
control-question: "Are cryptographic mechanisms utilized to protect the confidentiality and integrity of remote access sessions (e.g., VPN)?"
fiiId: "FII-SCF-NET-0014.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
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
  * **Control's Stated Purpose/Intent:** "To ensure that all remote access sessions are protected by robust cryptographic mechanisms, thereby maintaining the confidentiality and integrity of sensitive information transmitted over potentially insecure networks."
  * **Control Code:** AC.L2-3.1.13
  * **Control Question:** Are cryptographic mechanisms utilized to protect the confidentiality and integrity of remote access sessions (e.g., VPN)?
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-NET-0014.2
  * **Policy/Process Description (for context on intent and expected evidence):** 
    "The organization is committed to utilizing cryptographic mechanisms for all remote access sessions to protect sensitive information during transmission. This policy outlines the responsibilities of the IT Security Team, System Administrators, and Compliance Officer in ensuring compliance through regular evidence collection and audits."
  * **Provided Evidence for Audit:** 
    "1. Evidence of encryption protocols in use for remote access sessions, including logs of configuration settings and successful implementation reports. 2. Documentation of manual checks performed by IT Security Team and signed certifications by the Compliance Officer. 3. Audit logs showing regular checks conducted quarterly."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L2-3.1.13

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L2-3.1.13
**Control Question:** Are cryptographic mechanisms utilized to protect the confidentiality and integrity of remote access sessions (e.g., VPN)?
**Internal ID (FII):** FII-SCF-NET-0014.2
**Control's Stated Purpose/Intent:** To ensure that all remote access sessions are protected by robust cryptographic mechanisms, thereby maintaining the confidentiality and integrity of sensitive information transmitted over potentially insecure networks.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Successful implementation of encryption for all remote access sessions.
    * **Provided Evidence:** Evidence of encryption protocols in use for remote access sessions, including logs of configuration settings and successful implementation reports.
    * **Surveilr Method (as described/expected):** Surveilr utilized automated data ingestion methods to collect logs and configuration settings from remote access systems.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM rssd.remote_access_logs WHERE encryption_status = 'active';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided evidence shows successful implementation of encryption protocols, which directly aligns with the control requirement.

* **Control Requirement/Expected Evidence:** Evidence of regular audits conducted by the IT Security Team every Quarter.
    * **Provided Evidence:** Audit logs showing regular checks conducted quarterly.
    * **Surveilr Method (as described/expected):** Surveilr recorded the frequency and results of the audits conducted by the IT Security Team.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM rssd.audit_logs WHERE audit_frequency = 'quarterly';
    * **Compliance Status:** COMPLIANT
    * **Justification:** Audit logs confirm that the IT Security Team conducted quarterly audits, meeting the control's requirements.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Documentation of manual checks performed by IT Security Team and signed certifications by the Compliance Officer.
    * **Provided Evidence:** Documentation of manual checks and signed certifications.
    * **Human Action Involved (as per control/standard):** Manual verification of encryption settings by the IT Security Team.
    * **Surveilr Recording/Tracking:** Surveilr recorded the actions and outputs of human attestations, including signed certifications.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates the necessary human attestations were completed, confirming adherence to the control.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The evidence provided demonstrates that the organization is taking the necessary steps to ensure that remote access sessions are adequately protected through robust cryptographic mechanisms.
* **Justification:** The combination of machine and human attestations fulfills both the literal and the spirit of the control's intent.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The organization has successfully demonstrated compliance with the control requirements through both machine and human attestations, ensuring the confidentiality and integrity of remote access sessions.

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