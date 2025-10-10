---
title: "Audit Prompt: Remote Access Security Management Policy"
weight: 1
description: "Establishes automated mechanisms to monitor and control remote access sessions, ensuring the security of sensitive information and compliance with CMMC requirements."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L2-3.1.12"
control-question: "Does the organization use automated mechanisms to monitor and control remote access sessions?"
fiiId: "FII-SCF-NET-0014.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
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
  * **Control's Stated Purpose/Intent:** "The organization uses automated mechanisms to monitor and control remote access sessions."
Control Code : AC.L2-3.1.12,
Control Question : Does the organization use automated mechanisms to monitor and control remote access sessions?
Internal ID (Foreign Integration Identifier as FII) : FII-SCF-NET-0014.1
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy establishes the framework for the management of remote access sessions within the organization. Its purpose is to ensure that all remote access to sensitive information is monitored and controlled through automated mechanisms. This is crucial in protecting the confidentiality, integrity, and availability of our information systems, particularly in the context of increasing cyber threats and the need for compliance with regulatory standards such as the CMMC. The organization is committed to using automated mechanisms to effectively monitor and control remote access sessions."
  * **Provided Evidence for Audit:** "Automated monitoring tools configured to log remote access sessions through OSquery, with reports generated weekly. Documentation of quarterly training sessions for users on recognizing security incidents, along with attendance records. Logs of manual reviews of remote access sessions conducted by the IT Security Team."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L2-3.1.12

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L2-3.1.12
**Control Question:** Does the organization use automated mechanisms to monitor and control remote access sessions?
**Internal ID (FII):** FII-SCF-NET-0014.1
**Control's Stated Purpose/Intent:** The organization uses automated mechanisms to monitor and control remote access sessions.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must utilize automated mechanisms to monitor and control remote access sessions effectively.
    * **Provided Evidence:** Automated monitoring tools configured to log remote access sessions through OSquery, with reports generated weekly.
    * **Surveilr Method (as described/expected):** OSquery for continuously monitoring remote access logs.
    * **Conceptual/Actual SQL Query Context:** SQL query to retrieve remote access logs for analysis of anomalies.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that automated monitoring tools are in place and effectively logging remote access sessions as required by the control.

* **Control Requirement/Expected Evidence:** Automated reports summarizing remote access activities on a weekly basis.
    * **Provided Evidence:** Documentation showing weekly reports generated from OSquery.
    * **Surveilr Method (as described/expected):** Scheduled automated reporting from OSquery.
    * **Conceptual/Actual SQL Query Context:** SQL query used to aggregate remote access data weekly.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The organization provides documentation of weekly reports, confirming automated reporting is in place.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Conduct quarterly training sessions for users on recognizing security incidents.
    * **Provided Evidence:** Documentation of attendance for quarterly training sessions.
    * **Human Action Involved (as per control/standard):** Users attended training sessions.
    * **Surveilr Recording/Tracking:** Records stored in Surveilr confirming attendance.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The training documentation shows all users received necessary training, aligning with control expectations.

* **Control Requirement/Expected Evidence:** Maintain logs of manual reviews of remote access sessions conducted by the IT Security Team.
    * **Provided Evidence:** Logs detailing manual reviews conducted by the IT Security Team.
    * **Human Action Involved (as per control/standard):** IT Security Team performed manual reviews.
    * **Surveilr Recording/Tracking:** Records stored in Surveilr confirming the reviews.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The logs confirm that manual reviews are being conducted as required, demonstrating adherence to the control.

## 3. Overall Alignment with Control's Intent Spirit

* **Assessment:** The evidence provided meets the control's underlying purpose and intent by demonstrating the use of automated mechanisms and human oversight in monitoring remote access sessions.
* **Justification:** The combination of automated monitoring and human training ensures both compliance and awareness of security measures.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The organization has demonstrated compliance with the control requirements through effective automated mechanisms and human attestation methods. All aspects of the control are satisfied by the evidence provided.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * N/A (as the result is a PASS)
* **Specific Non-Compliant Evidence Required Correction:**
    * N/A (as the result is a PASS)
* **Required Human Action Steps:**
    * N/A (as the result is a PASS)
* **Next Steps for Re-Audit:** 
    * N/A (as the result is a PASS)