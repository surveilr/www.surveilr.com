---
title: "Audit Prompt: Cryptographic Protections for Data at Rest Policy"
weight: 1
description: "Implement cryptographic protections to secure data at rest, ensuring confidentiality and compliance with regulatory requirements for handling sensitive information."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "MP.L2-3.8.6"
control-question: "Are cryptographic mechanisms utilized to prevent unauthorized disclosure of data at rest?"
fiiId: "FII-SCF-CRY-0005"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Cryptographic Protections"
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
  * **Control's Stated Purpose/Intent:** "To ensure the use of cryptographic mechanisms to protect sensitive information and prevent unauthorized disclosure of data at rest."
  * Control Code: MP.L2-3.8.6
  * Control Question: Are cryptographic mechanisms utilized to prevent unauthorized disclosure of data at rest?
  * Internal ID (Foreign Integration Identifier as FII): FII-SCF-CRY-0005
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The use of cryptographic mechanisms is essential in safeguarding sensitive information, specifically in preventing unauthorized disclosure of data at rest. As organizations increasingly rely on digital storage solutions, the risk of data breaches escalates. By employing robust cryptographic protections, we can ensure the confidentiality, integrity, and availability of electronic protected health information (ePHI) against unauthorized access and disclosure. Our organization is committed to implementing comprehensive cryptographic protections to secure data at rest. We will utilize industry-standard cryptographic algorithms and protocols to encrypt sensitive information stored in our systems, thereby ensuring compliance with applicable regulations and safeguarding our stakeholders' privacy."
  * **Provided Evidence for Audit:** "Evidence includes automated logs from configuration management tools verifying encryption settings, monthly reports indicating 100% encryption compliance for systems storing ePHI, and quarterly review documentation signed by relevant personnel confirming that encryption implementations are in place."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - MP.L2-3.8.6

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** MP.L2-3.8.6
**Control Question:** Are cryptographic mechanisms utilized to prevent unauthorized disclosure of data at rest?
**Internal ID (FII):** FII-SCF-CRY-0005
**Control's Stated Purpose/Intent:** To ensure the use of cryptographic mechanisms to protect sensitive information and prevent unauthorized disclosure of data at rest.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Cryptographic mechanisms must be utilized to protect data at rest to mitigate risks of unauthorized access.
    * **Provided Evidence:** Automated logs from configuration management tools verifying encryption settings and monthly reports indicating 100% encryption compliance for systems storing ePHI.
    * **Surveilr Method (as described/expected):** Configuration management tools and automated logging for encryption compliance.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM encryption_logs WHERE compliance_status = 'COMPLIANT';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided evidence clearly demonstrates that all systems storing ePHI are encrypted, meeting the control's requirements.

* **Control Requirement/Expected Evidence:** Monthly reviews of encryption compliance.
    * **Provided Evidence:** Monthly compliance reports generated from the monitoring system.
    * **Surveilr Method (as described/expected):** Automated reporting from Surveilr based on collected evidence.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM compliance_reports WHERE compliance = 'TRUE' AND report_date >= '2025-01-01';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence indicates a consistent review process, confirming all systems are compliant with encryption standards.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Quarterly reviews by personnel to validate encryption implementations.
    * **Provided Evidence:** Documentation of quarterly review signed by relevant personnel.
    * **Human Action Involved (as per control/standard):** Manual verification and documentation of encryption processes.
    * **Surveilr Recording/Tracking:** Storage of signed review documentation in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed documentation provides clear human attestation that encryption implementations are validated quarterly.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization is meeting the underlying intent of the control by employing cryptographic mechanisms effectively.
* **Justification:** The combination of machine-attestable evidence and human attestation confirms that the organization is taking the necessary steps to protect data at rest from unauthorized disclosure.
* **Critical Gaps in Spirit (if applicable):** None identified; evidence sufficiently meets both the letter and spirit of the control.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided meets all control requirements as established, demonstrating both compliance and the effective use of cryptographic mechanisms to protect data at rest.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [For each missing piece of evidence identified in Section 2, state *exactly* what is needed. E.g., "Missing current firewall rule sets from production firewalls (FII-XYZ-001) for the quarter ending 2025-06-30."]
    * [Specify the required format/type for each missing piece: e.g., "Obtain OSquery results for network interface configurations on all servers tagged 'production_web'.", "Provide a signed PDF of the latest incident response plan approval."]
* **Specific Non-Compliant Evidence Required Correction:**
    * [For each instance of non-compliant evidence identified in Section 2, clearly state *why* it is non-compliant and what *specific correction* is required. E.g., "Provided access logs show unapproved access event on 2025-07-15 by UserID 123; requires an associated incident ticket (IR-2025-005) or justification."]
    * [Specify the action needed: e.g., "Remediate firewall rule CC6-0010-005 to correctly block traffic from IP range X.Y.Z.0/24.", "Provide evidence of user access review completion for Q2 2025 for all critical systems."]
* **Required Human Action Steps:**
    * [List precise steps a human auditor or compliance officer needs to take. E.g., "Engage IT Operations to retrieve the specific logs for server X from date Y.", "Contact system owner Z to obtain management attestation for policy P."]
    * [Specify which teams or individuals are responsible for producing or correcting the evidence.]
* **Next Steps for Re-Audit:** [Outline the process for re-submission of the corrected/missing evidence for re-evaluation.]