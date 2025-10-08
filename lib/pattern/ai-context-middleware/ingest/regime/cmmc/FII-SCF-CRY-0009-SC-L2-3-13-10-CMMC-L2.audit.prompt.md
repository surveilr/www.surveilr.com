---
title: "Audit Prompt: Cryptographic Key Management and Security Policy"
weight: 1
description: "Establishes secure management practices for cryptographic keys to safeguard confidentiality, integrity, and availability while ensuring compliance with applicable regulations."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "SC.L2-3.13.10"
control-question: "Does the organization facilitate cryptographic key management controls to protect the confidentiality, integrity and availability of keys?"
fiiId: "FII-SCF-CRY-0009"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Cryptographic Protections"
category: ["CMMC", "Level 2", "Compliance"]
---

You're an **official auditor (e.g., CMMC Auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

**Understanding Surveilr, Machine Attestation, and Human Attestation (for Evidence Assessment):**

- **Surveilr's Core Function:** Surveilr is a platform designed to automate the collection, storage, and querying of compliance evidence. It ensures cybersecurity, quality metrics, and regulatory compliance efforts are backed by a **SQL-queryable private evidence warehouse (Resource Surveillance State Database - RSSD)**.
- **Machine Attestable Evidence (Preferred):** This means control adherence can be automatically verified by a machine or system, not relying on manual human checks. Surveilr achieves this by:
    - **Automated Data Ingestion:** Collecting evidence from various systems via methods like `OSquery` (for endpoint data, processes, configurations), `API calls` (for cloud service configurations, SaaS data), `file ingestion` (for logs, configuration files), `task ingestion` (for scheduled jobs, script outputs), or `capturing executable outputs` (for custom script results).
    - **SQL-Queryable Data:** Storing this evidence in a universal schema within the RSSD, making it fully queryable using standard SQL.
    - **Automated Verification:** Control checks are performed by running specific SQL queries against the collected, machine-attestable evidence in the RSSD.
- **Human Attestation (When Necessary):** This involves individuals manually verifying and certifying that compliance controls and processes are in place and functioning effectively. It relies on human judgment, review, or direct declaration.
    - **Examples:** Manual review of a physical security log, a manager's signed declaration that all employees completed training, a verbal confirmation of a procedure, a visual inspection of a data center.
    - **Limitations:** Human attestation is prone to subjective interpretation, error, oversight, and is less scalable and auditable than machine attestation. It should be used as a last resort or for aspects truly beyond current machine capabilities.
    - **Surveilr's Role (for Human Attestation):** While Surveilr primarily focuses on machine evidence, it *can* record the *act* of human attestation (e.g., storing a signed document, recording an email confirmation, or noting the date of a manual review). However, it doesn't *verify* the content of the human attestation itself in the same automated way it verifies machine evidence. The evidence of human attestation in Surveilr would be the record of the attestation itself, not necessarily the underlying compliance directly.
- **Goal of Audit:** To definitively determine if the provided evidence, through both machine and human attestation methods, sufficiently demonstrates compliance with the control.

**Audit Context:**

- **Audit Standard/Framework:** CMMC
- **Control's Stated Purpose/Intent:** "To facilitate cryptographic key management controls to protect the confidentiality, integrity, and availability of keys."
  - Control Code: SC.L2-3.13.10
  - Control Question: Does the organization facilitate cryptographic key management controls to protect the confidentiality, integrity and availability of keys?
  - Internal ID (Foreign Integration Identifier as FII): FII-SCF-CRY-0009
- **Policy/Process Description (for context on intent and expected evidence):**
  "This policy aims to establish robust cryptographic key management controls that are vital for protecting the confidentiality, integrity, and availability of our organization's cryptographic keys. Effective key management ensures that keys are created, stored, and destroyed securely, thereby reducing the risk of unauthorized access and data breaches. Our organization is committed to maintaining the confidentiality, integrity, and availability of cryptographic keys through stringent management practices."
- **Provided Evidence for Audit:** "1. Key usage logs collected via API integration with the key management system. 2. The Security Manager's signed report documenting the Annual Review of key management procedures."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - SC.L2-3.13.10

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [CMMC Auditor]
**Control Code:** SC.L2-3.13.10
**Control Question:** Does the organization facilitate cryptographic key management controls to protect the confidentiality, integrity and availability of keys?
**Internal ID (FII):** FII-SCF-CRY-0009
**Control's Stated Purpose/Intent:** To facilitate cryptographic key management controls to protect the confidentiality, integrity, and availability of keys.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Implement cryptographic key management controls that enforce secure generation, storage, and lifecycle management of keys.
    * **Provided Evidence:** Key usage logs collected via API integration with the key management system.
    * **Surveilr Method (as described/expected):** API integration with the key management system.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM key_usage_logs WHERE timestamp >= '2025-01-01' AND timestamp <= '2025-07-28';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided key usage logs demonstrate automated collection and monitoring of key management activities, aligning with the control's requirements.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** The Security Manager must sign off on the Annual Review of key management procedures.
    * **Provided Evidence:** The Security Manager's signed report documenting the Annual Review of key management procedures.
    * **Human Action Involved (as per control/standard):** Signing off on the review process.
    * **Surveilr Recording/Tracking:** Documented report maintained in Surveilr's evidence repository.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report serves as valid evidence of human attestation regarding the compliance of key management practices.

## 3. Overall Alignment with Control's Intent Spirit

* **Assessment:** The evidence provided demonstrates a strong alignment with the control's intent to ensure effective cryptographic key management.
* **Justification:** Both machine-attestable and human-attested evidence confirm adherence to the security control's objectives, including safeguarding the confidentiality, integrity, and availability of keys.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence submitted comprehensively meets both the literal and underlying intent of the control, demonstrating compliance with all specified requirements.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** 
    * [N/A - All required evidence is present.]
* **Specific Non-Compliant Evidence Required Correction:** 
    * [N/A - No evidence is non-compliant.]
* **Required Human Action Steps:** 
    * [N/A - No additional actions are required.]
* **Next Steps for Re-Audit:** 
    * [N/A - No re-audit needed as the result is PASS.]