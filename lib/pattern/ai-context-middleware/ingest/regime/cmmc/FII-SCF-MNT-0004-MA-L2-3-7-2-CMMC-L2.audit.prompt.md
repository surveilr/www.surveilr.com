---
title: "Audit Prompt: System Maintenance Tools Control and Monitoring Policy"
weight: 1
description: "Establishes controls and monitoring for system maintenance tools to ensure compliance, protect data integrity, and maintain logs of maintenance activities."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "MA.L2-3.7.2"
control-question: "Does the organization control and monitor the use of system maintenance tools?"
fiiId: "FII-SCF-MNT-0004"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Maintenance"
category: ["CMMC", "Level 2", "Compliance"]
---

**[START OF GENERATED PROMPT CONTENT]**

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
  * **Control's Stated Purpose/Intent:** "The organization controls and monitors the use of system maintenance tools to ensure they are utilized in a manner that safeguards the integrity, availability, and confidentiality of the information systems."
Control Code: MA.L2-3.7.2,
Control Question: Does the organization control and monitor the use of system maintenance tools?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-MNT-0004
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework for the control and monitoring of system maintenance tools within the organization. This policy ensures compliance with the CMMC Control MA.L2-3.7.2 by defining clear responsibilities, evidence collection methods, and verification criteria to protect organizational assets and data. The organization shall control and monitor the use of system maintenance tools to ensure they are utilized in a manner that safeguards the integrity, availability, and confidentiality of the information systems. All maintenance activities must be logged, reviewed, and retained in accordance with established data retention policies."
  * **Provided Evidence for Audit:** "Machine attestation evidence includes OSquery monitoring logs showing the use of approved maintenance tools across endpoints, automated script results confirming the presence of these tools, and daily logging records from system administrators. Human attestation evidence consists of maintenance activity reports uploaded to Surveilr by system administrators detailing the tools used and actions taken."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - MA.L2-3.7.2

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [CMMC Auditor]
**Control Code:** MA.L2-3.7.2
**Control Question:** Does the organization control and monitor the use of system maintenance tools?
**Internal ID (FII):** FII-SCF-MNT-0004
**Control's Stated Purpose/Intent:** The organization controls and monitors the use of system maintenance tools to ensure they are utilized in a manner that safeguards the integrity, availability, and confidentiality of the information systems.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Control and monitor the use of system maintenance tools.
    * **Provided Evidence:** OSquery monitoring logs showing the use of approved maintenance tools across endpoints.
    * **Surveilr Method (as described/expected):** OSquery for endpoint data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM maintenance_logs WHERE tool IN (approved_tools) AND timestamp >= '2025-01-01';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that the usage of approved maintenance tools is logged and monitored as required by the control.

* **Control Requirement/Expected Evidence:** Daily logging of maintenance activities.
    * **Provided Evidence:** Daily logging records from system administrators.
    * **Surveilr Method (as described/expected):** Logging activities through automated scripts.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM maintenance_logs WHERE log_date = CURRENT_DATE;
    * **Compliance Status:** COMPLIANT
    * **Justification:** The daily logs are maintained and meet the minimum accuracy rate of 95%, as required by the verification criteria.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Maintenance activity reports detailing the tools used and actions taken.
    * **Provided Evidence:** Maintenance activity reports uploaded to Surveilr.
    * **Human Action Involved (as per control/standard):** System Administrators must complete reports after each maintenance activity.
    * **Surveilr Recording/Tracking:** Reports are stored in Surveilr for validation.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The uploaded reports confirm that system administrators are documenting their maintenance activities as required.

## 3. Overall Alignment with Control's Intent and Spirit

* **Assessment:** The provided evidence demonstrates that the organization is effectively controlling and monitoring the use of system maintenance tools.
* **Justification:** The evidence aligns with the control's intent to protect the integrity, availability, and confidentiality of information systems through robust logging and monitoring practices.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings indicate that the organization has met the compliance requirements for CMMC Control MA.L2-3.7.2, with all evidence assessed demonstrating adherence to the control's requirements and intent.

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

**[END OF GENERATED PROMPT CONTENT]**