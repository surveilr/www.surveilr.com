---
title: "Audit Prompt: Network Session Termination Security Policy"
weight: 1
description: "Establishes guidelines for automatically terminating network sessions to enhance security and reduce unauthorized access risks."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "SC.L2-3.13.9"
control-question: "Does the organization terminate network connections at the end of a session or after an organization-defined time period of inactivity?"
fiiId: "FII-SCF-NET-0007"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
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
  * **Control's Stated Purpose/Intent:** "To ensure network connections are terminated at the end of a session or after a defined period of inactivity to protect sensitive information."
Control Code: SC.L2-3.13.9
Control Question: Does the organization terminate network connections at the end of a session or after an organization-defined time period of inactivity?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-NET-0007
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The organization mandates the termination of network connections automatically at the end of a session or after a predefined period of inactivity. This policy is designed to safeguard sensitive information and ensure compliance with industry standards, thereby enhancing the overall security posture of the organization."
  * **Provided Evidence for Audit:** "Automated monitoring tools log session activities and timeout events. Scripts verify compliance with session termination policies and generate reports. Employees have completed session termination acknowledgment forms, which are collected and ingested into Surveilr via a secure upload process."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - SC.L2-3.13.9

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** SC.L2-3.13.9
**Control Question:** Does the organization terminate network connections at the end of a session or after an organization-defined time period of inactivity?
**Internal ID (FII):** FII-SCF-NET-0007
**Control's Stated Purpose/Intent:** To ensure network connections are terminated at the end of a session or after a defined period of inactivity to protect sensitive information.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The control requires organizations to terminate network connections at the end of a session or after a defined period of inactivity.
    * **Provided Evidence:** Automated monitoring tools log session activities and timeout events.
    * **Surveilr Method (as described/expected):** Automated monitoring tools configured to track session terminations and log events.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM session_logs WHERE session_end_time > current_timestamp - interval '30 minutes';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that the organization has automated monitoring tools in place that log session activities and timeout events, providing a clear trail of compliance with the control’s requirements.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Employees must complete a session termination acknowledgment form and submit it to the IT Security Team.
    * **Provided Evidence:** Employees have completed session termination acknowledgment forms, collected and ingested into Surveilr.
    * **Human Action Involved (as per control/standard):** Employees signing acknowledgment forms regarding session termination practices.
    * **Surveilr Recording/Tracking:** The signed acknowledgment forms are securely uploaded into Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The collection of signed acknowledgment forms verifies that employees are aware of and comply with the session termination requirements.

## 3. Overall Alignment with Control's Intent and Spirit

* **Assessment:** The provided evidence demonstrates adherence to the control's requirements and intent.
* **Justification:** The organization has implemented both machine attestation tools and human acknowledgment processes that collectively ensure session termination practices are followed effectively.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The organization has successfully implemented both machine and human evidence collection methods that align with the control's requirements and intent. The automated monitoring tools and employee acknowledgment forms provide sufficient evidence of compliance.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [Not applicable, as the result is PASS.]

* **Specific Non-Compliant Evidence Required Correction:**
    * [Not applicable, as the result is PASS.]

* **Required Human Action Steps:**
    * [Not applicable, as the result is PASS.]

* **Next Steps for Re-Audit:** 
    * [Not applicable, as the result is PASS.]

**[END OF GENERATED PROMPT CONTENT]**