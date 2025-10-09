---
title: "Audit Prompt: Mobile Device Access Control Security Policy"
weight: 1
description: "Establishes access control guidelines for mobile devices to protect sensitive data and ensure compliance with regulatory standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L2-3.1.18"
control-question: "Does the organization enforce access control requirements for the connection of mobile devices to organizational systems?"
fiiId: "FII-SCF-MDM-0002"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Mobile Device Management"
category: ["CMMC", "Level 2", "Compliance"]
---

You're an **official auditor**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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
**Control's Stated Purpose/Intent:** "The organization enforces access control requirements for the connection of mobile devices to organizational systems."
Control Code: AC.L2-3.1.18,
Control Question: Does the organization enforce access control requirements for the connection of mobile devices to organizational systems?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-MDM-0002
- **Policy/Process Description (for context on intent and expected evidence):**
  "The purpose of this policy is to establish guidelines for enforcing access control requirements for the connection of mobile devices to organizational systems. Given the increasing reliance on mobile devices for handling sensitive data, particularly electronic Protected Health Information (ePHI), it is critical to implement robust access controls to safeguard organizational assets and maintain compliance with regulatory standards. The organization commits to enforcing stringent access control requirements for mobile devices that connect to organizational systems, ensuring that only authorized devices can access sensitive data."
- **Provided Evidence for Audit:** "Daily OSquery results showing compliance status of mobile devices, along with the quarterly signed mobile device inventory report from the IT manager."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L2-3.1.18

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L2-3.1.18
**Control Question:** Does the organization enforce access control requirements for the connection of mobile devices to organizational systems?
**Internal ID (FII):** FII-SCF-MDM-0002
**Control's Stated Purpose/Intent:** The organization enforces access control requirements for the connection of mobile devices to organizational systems.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must ensure that only authorized mobile devices can access organizational systems.
    * **Provided Evidence:** Daily OSquery results showing compliance status of mobile devices.
    * **Surveilr Method (as described/expected):** OSquery was utilized to collect mobile device compliance data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM mobile_device_compliance WHERE compliance_status = 'active';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that all mobile devices have been assessed daily for compliance, resulting in an active compliance status.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** The IT manager must sign off on the quarterly mobile device inventory report.
    * **Provided Evidence:** Quarterly signed mobile device inventory report from the IT manager.
    * **Human Action Involved (as per control/standard):** IT manager's manual review and sign-off on the inventory report.
    * **Surveilr Recording/Tracking:** Surveilr records the act of signing the report.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report confirms that the IT manager has attested to the compliance of the mobile devices, fulfilling the requirement for human attestation.

## 3. Overall Alignment with Control's Intent Spirit

* **Assessment:** The evidence provided demonstrates that the organization is actively enforcing access control requirements for mobile devices.
* **Justification:** The combination of machine attestable evidence and human attestation shows a comprehensive approach to compliance, aligning with the control's intent to protect organizational systems from unauthorized access.
* **Critical Gaps in Spirit (if applicable):** None identified; evidence meets both the letter and spirit of the control.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence collected demonstrates effective enforcement of access control requirements for mobile devices, fulfilling both the literal requirements and intent of the control.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A]
* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A]
* **Required Human Action Steps:**
    * [N/A]
* **Next Steps for Re-Audit:** [N/A]

**[END OF GENERATED PROMPT CONTENT]**