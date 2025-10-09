---
title: "Audit Prompt: Authorized Maintenance Personnel Compliance Policy"
weight: 1
description: "Establishes and maintains a current list of authorized maintenance personnel to ensure secure access and compliance with ePHI handling standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "MA.L2-3.7.6"
control-question: "Does the organization maintain a current list of authorized maintenance organizations or personnel?"
fiiId: "FII-SCF-MNT-0006"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Maintenance"
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
  * **Control's Stated Purpose/Intent:** "To maintain a current list of authorized maintenance organizations or personnel to ensure that only vetted and approved entities have access to our systems for maintenance purposes, thereby promoting trust and compliance with industry standards."
    * Control Code: MA.L2-3.7.6
    * Control Question: Does the organization maintain a current list of authorized maintenance organizations or personnel?
    * Internal ID (Foreign Integration Identifier as FII): FII-SCF-MNT-0006
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy outlines the procedures for maintaining a current list of authorized maintenance organizations or personnel. It is crucial for ensuring the integrity and security of our systems, particularly those handling electronic Protected Health Information (ePHI). Keeping an updated list mitigates risks associated with unauthorized access and potential breaches, thereby enhancing our compliance posture and safeguarding sensitive data."
  * **Provided Evidence for Audit:** "Evidence includes a current list of authorized maintenance personnel extracted daily via OSquery, a signed report from the IT manager confirming quarterly reviews of the personnel list, along with metadata including review date and reviewer name."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - MA.L2-3.7.6

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** MA.L2-3.7.6
**Control Question:** Does the organization maintain a current list of authorized maintenance organizations or personnel?
**Internal ID (FII):** FII-SCF-MNT-0006
**Control's Stated Purpose/Intent:** To maintain a current list of authorized maintenance organizations or personnel to ensure that only vetted and approved entities have access to our systems for maintenance purposes, thereby promoting trust and compliance with industry standards.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must maintain a current list of authorized maintenance organizations or personnel.
    * **Provided Evidence:** A daily extracted list of authorized maintenance personnel from OSquery.
    * **Surveilr Method (as described/expected):** OSquery collected the current list of authorized personnel.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM authorized_personnel WHERE last_updated >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY);
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence is compliant as it demonstrates that the organization has a current list of authorized maintenance personnel, validated through an automated process.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** The IT manager must sign off on quarterly reviews of the authorized maintenance personnel list.
    * **Provided Evidence:** Signed report from the IT manager confirming the quarterly review of the personnel list, uploaded to Surveilr with metadata.
    * **Human Action Involved (as per control/standard):** IT manager's manual review and certification of the personnel list.
    * **Surveilr Recording/Tracking:** The signed report and metadata were recorded in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report provides clear evidence of the quarterly review, meeting the human attestation requirement.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization is actively maintaining and validating a current list of authorized maintenance personnel.
* **Justification:** The automated and manual methods of evidence collection align with the control's intent to ensure that only vetted individuals have access to sensitive systems.
* **Critical Gaps in Spirit (if applicable):** None identified; all evidence supports both the letter and spirit of the control.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided substantiates that the organization maintains a current list of authorized maintenance personnel, validated through both automated and manual processes.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**
* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**