---
title: "Audit Prompt: Endpoint Security Compliance and Protection Policy"
weight: 1
description: "Establishes measures to secure endpoint devices, ensuring the protection of sensitive data and compliance with CMMC control SC.L2-3.13.16."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "SC.L2-3.13.16"
control-question: "Does the organization protect the confidentiality, integrity, availability and safety of endpoint devices?"
fiiId: "FII-SCF-END-0002"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Endpoint Security"
category: ["CMMC", "Level 2", "Compliance"]
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
  * **Control's Stated Purpose/Intent:** "The organization protects the confidentiality, integrity, availability and safety of endpoint devices."
Control Code: SC.L2-3.13.16
Control Question: Does the organization protect the confidentiality, integrity, availability and safety of endpoint devices?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-END-0002
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish comprehensive measures for protecting the confidentiality, integrity, availability, and safety of endpoint devices utilized within our organization. As endpoints serve as critical touchpoints for accessing sensitive data, including ePHI (electronic Protected Health Information), it is paramount that these devices are safeguarded against unauthorized access, potential breaches, and other security risks. This policy outlines our commitment to maintaining a secure environment that aligns with regulatory requirements and best practices."
  * **Provided Evidence for Audit:** "Automated logging mechanisms are implemented to capture security events in real-time. Endpoint detection and response (EDR) solutions are utilized for continuous monitoring and machine attestability. 100% completion rate of monthly security training by all employees is documented. Daily review of security logs has been conducted with documented findings and actions taken. Quarterly assessments of endpoint device security posture are measured against defined KPIs/SLAs. Signed acknowledgment forms indicating understanding and compliance with this policy are collected."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - SC.L2-3.13.16

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., HIPAA Auditor]
**Control Code:** SC.L2-3.13.16
**Control Question:** Does the organization protect the confidentiality, integrity, availability and safety of endpoint devices?
**Internal ID (FII):** FII-SCF-END-0002
**Control's Stated Purpose/Intent:** The organization protects the confidentiality, integrity, availability and safety of endpoint devices.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization will maintain and regularly review logs and records related to endpoint security compliance.
    * **Provided Evidence:** Automated logging mechanisms are implemented to capture security events in real-time.
    * **Surveilr Method (as described/expected):** EDR solutions for continuous monitoring and machine attestability.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM endpoint_security_logs WHERE event_date >= '2025-01-01';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided evidence demonstrates that automated logging mechanisms are in place, ensuring real-time security event capture, thereby fulfilling the control requirement.

* **Control Requirement/Expected Evidence:** 100% completion rate of monthly security training by all employees.
    * **Provided Evidence:** 100% completion rate of monthly security training is documented.
    * **Surveilr Method (as described/expected):** Training completion records stored in Surveilr.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM training_records WHERE completion_status = 'completed';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The training records indicate that all employees have completed the required training, satisfying the control's expectations.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Employees must complete a monthly training module on endpoint security, with records of completion logged in Surveilr.
    * **Provided Evidence:** Signed acknowledgment forms indicating understanding and compliance with this policy are collected.
    * **Human Action Involved (as per control/standard):** Employees signing acknowledgment forms after training completion.
    * **Surveilr Recording/Tracking:** Scanned signed acknowledgment forms stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The acknowledgment forms serve as valid human attestations that employees have understood and comply with the endpoint security policy.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The evidence demonstrates that the organization is effectively protecting the confidentiality, integrity, availability, and safety of endpoint devices.
* **Justification:** The comprehensive logging, monitoring, training, and human attestation align with the control's intent to ensure robust endpoint security measures are in place. The evidence provided addresses both literal requirements and the broader objectives of maintaining a secure environment.
* **Critical Gaps in Spirit (if applicable):** None identified. All evidence aligns well with the spirit of the control.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings indicate that the organization meets all requirements of control SC.L2-3.13.16, with adequate machine and human attestable evidence demonstrating compliance with the control's intent and spirit.

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