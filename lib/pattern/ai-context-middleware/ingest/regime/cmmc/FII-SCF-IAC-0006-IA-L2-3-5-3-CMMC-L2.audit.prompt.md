---
title: "Audit Prompt: Multi-Factor Authentication Security Policy"
weight: 1
description: "Establishes Multi-Factor Authentication (MFA) requirements to enhance security and protect sensitive data across the organization."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "IA.L2-3.5.3"
control-question: "Does the organization use automated mechanisms to enforce Multi-Factor Authentication (MFA) for:
 ▪ Remote network access; 
 ▪ Third-party systems, applications and/or services; and/ or
 ▪ Non-console access to critical systems or systems that store, transmit and/or process sensitive/regulated data?"
fiiId: "FII-SCF-IAC-0006"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
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
  * **Control's Stated Purpose/Intent:** "The control is designed to ensure that Multi-Factor Authentication (MFA) is enforced to protect remote access and sensitive systems, thereby mitigating unauthorized access risks."
Control Code: IA.L2-3.5.3,
Control Question: "Does the organization use automated mechanisms to enforce Multi-Factor Authentication (MFA) for: ▪ Remote network access; ▪ Third-party systems, applications and/or services; and/or ▪ Non-console access to critical systems or systems that store, transmit and/or process sensitive/regulated data?"
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The organization has established a Multi-Factor Authentication (MFA) Policy to provide an additional layer of security for critical system access. This policy mandates MFA for all users accessing sensitive data remotely or through third-party services. Evidence for compliance will be collected through a combination of automated log tracking and human attestations from management."
  * **Provided Evidence for Audit:** "API logs showing MFA compliance metrics for the last quarter (Q2 2025) indicate 98% of users successfully authenticated using MFA. The IT Manager signed the quarterly compliance report on 2025-07-10, documenting that all relevant access points enforced MFA."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - IA.L2-3.5.3

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [CMMC Auditor]
**Control Code:** IA.L2-3.5.3
**Control Question:** "Does the organization use automated mechanisms to enforce Multi-Factor Authentication (MFA) for: ▪ Remote network access; ▪ Third-party systems, applications and/or services; and/or ▪ Non-console access to critical systems or systems that store, transmit and/or process sensitive/regulated data?"
**Internal ID (FII):** FII-SCF-IAC-0006
**Control's Stated Purpose/Intent:** "The control is designed to ensure that Multi-Factor Authentication (MFA) is enforced to protect remote access and sensitive systems, thereby mitigating unauthorized access risks."

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** "Automated mechanisms enforce MFA for remote network access."
    * **Provided Evidence:** "API logs showing MFA compliance metrics for the last quarter indicate 98% of users successfully authenticated using MFA."
    * **Surveilr Method (as described/expected):** "API integrations with identity providers to verify MFA status."
    * **Conceptual/Actual SQL Query Context:** "SELECT COUNT(*) FROM user_authentication_logs WHERE mfa_status = 'successful' AND access_type = 'remote';"
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The evidence demonstrates that automated mechanisms are in place and effectively enforcing MFA for remote access, with a compliance rate of 98%."

* **Control Requirement/Expected Evidence:** "Automated mechanisms enforce MFA for third-party systems."
    * **Provided Evidence:** "API logs indicate MFA is enforced for all third-party access attempts."
    * **Surveilr Method (as described/expected):** "API call to the third-party authentication service to verify MFA implementation."
    * **Conceptual/Actual SQL Query Context:** "SELECT COUNT(*) FROM third_party_access_logs WHERE mfa_status = 'enforced';"
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The logs confirm that all third-party access attempts are subject to MFA enforcement."

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** "Human attestation of MFA compliance."
    * **Provided Evidence:** "The IT Manager signed the quarterly compliance report on 2025-07-10."
    * **Human Action Involved (as per control/standard):** "The IT Manager certifies the MFA compliance of all access points."
    * **Surveilr Recording/Tracking:** "Surveilr records the signed compliance report."
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The signed report serves as valid human attestation confirming that all systems enforced MFA as required."

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** The provided evidence demonstrates that the organization is effectively enforcing Multi-Factor Authentication (MFA) in line with the control's intent.
* **Justification:** "The metrics indicate a high compliance rate and the IT Manager's attestation confirms adherence to the policy, fulfilling both the letter and spirit of the control."
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and  Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** "The evidence collectively demonstrates that all required mechanisms for enforcing MFA are in place, and compliance is documented thoroughly. No significant gaps were identified."

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**