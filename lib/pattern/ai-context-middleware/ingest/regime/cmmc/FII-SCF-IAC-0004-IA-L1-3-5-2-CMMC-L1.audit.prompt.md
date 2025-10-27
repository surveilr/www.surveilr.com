---
title: "Audit Prompt: Device Authentication and Identification Policy"
weight: 1
description: "Establishes a framework for the unique identification and secure authentication of devices connecting to organizational systems to protect sensitive information."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "IA.L1-3.5.2"
control-question: "Does the organization uniquely identify and centrally Authenticate, Authorize and Audit (AAA) devices before establishing a connection using bidirectional authentication that is cryptographically- based and replay resistant?"
fiiId: "FII-SCF-IAC-0004"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Identification & Authentication"
category: ["CMMC", "Level 1", "Compliance"]
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
  * **Control's Stated Purpose/Intent:** "To ensure that all devices connecting to organizational systems are uniquely identified and authenticated using centralized AAA mechanisms, including cryptographically-based bidirectional authentication to protect sensitive information."
  * **Control Code:** IA.L1-3.5.2
  * **Control Question:** Does the organization uniquely identify and centrally Authenticate, Authorize and Audit (AAA) devices before establishing a connection using bidirectional authentication that is cryptographically-based and replay resistant?
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-IAC-0004
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework for the unique identification and centralized authentication, authorization, and auditing (AAA) of devices prior to establishing a connection to organizational systems. This policy ensures that all devices are authenticated using bidirectional authentication methods that are cryptographically-based and replay resistant, thereby protecting sensitive information and maintaining compliance with CMMC standards."
  * **Provided Evidence for Audit:** 
    "1. OSquery results showing device inventories and authentication logs collected daily. 
    2. Signed quarterly validation reports from managers confirming device compliance with authentication protocols. 
    3. TLS/SSL certificates implemented for all device connections with logs of certificate validation events. 
    4. Monthly reviews of authentication logs documented by the IT Security Team. 
    5. SIEM tools aggregating and analyzing connection logs in real-time. 
    6. Bi-annual audit reports reviewed and signed off by the Compliance Officer."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - IA.L1-3.5.2

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [CMMC Auditor]
**Control Code:** IA.L1-3.5.2
**Control Question:** Does the organization uniquely identify and centrally Authenticate, Authorize and Audit (AAA) devices before establishing a connection using bidirectional authentication that is cryptographically-based and replay resistant?
**Internal ID (FII):** FII-SCF-IAC-0004
**Control's Stated Purpose/Intent:** To ensure that all devices connecting to organizational systems are uniquely identified and authenticated using centralized AAA mechanisms, including cryptographically-based bidirectional authentication to protect sensitive information.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Unique identification and centralized authentication of devices.
    * **Provided Evidence:** OSquery results showing device inventories and authentication logs collected daily.
    * **Surveilr Method (as described/expected):** OSquery for endpoint data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM device_inventory WHERE authentication_status = 'authenticated';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that all devices are uniquely identified and authenticated, fulfilling the control requirement.

* **Control Requirement/Expected Evidence:** Bidirectional authentication that is cryptographically-based and replay resistant.
    * **Provided Evidence:** TLS/SSL certificates implemented for all device connections and logs of certificate validation events.
    * **Surveilr Method (as described/expected):** Automated logging of certificate validation events.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM certificate_logs WHERE validation_status = 'valid';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence confirms that bidirectional authentication is in place and meets cryptographic standards.

* **Control Requirement/Expected Evidence:** Audit of device connections.
    * **Provided Evidence:** SIEM tools aggregating and analyzing connection logs in real-time.
    * **Surveilr Method (as described/expected):** Real-time log aggregation and analysis.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM connection_logs WHERE timestamp >= CURRENT_DATE - INTERVAL '1 day';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence shows that device connections are audited effectively.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Manager's signed quarterly validation reports confirming device compliance with authentication protocols.
    * **Provided Evidence:** Signed quarterly validation reports from managers.
    * **Human Action Involved (as per control/standard):** Managers reviewing and signing off on device compliance.
    * **Surveilr Recording/Tracking:** Signed documents stored as evidence.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence indicates that human attestation is in place to validate compliance.

* **Control Requirement/Expected Evidence:** Monthly reviews of authentication logs documented by the IT Security Team.
    * **Provided Evidence:** Documentation of monthly reviews.
    * **Human Action Involved (as per control/standard):** IT Security Team conducting reviews.
    * **Surveilr Recording/Tracking:** Records of review dates and findings.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence supports that the IT Security Team is actively reviewing logs.

* **Control Requirement/Expected Evidence:** Bi-annual audit reports reviewed and signed off by the Compliance Officer.
    * **Provided Evidence:** Audit reports signed by the Compliance Officer.
    * **Human Action Involved (as per control/standard):** Compliance Officer reviewing and signing reports.
    * **Surveilr Recording/Tracking:** Signed audit reports stored in compliance records.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence shows that the Compliance Officer is fulfilling their review responsibilities.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization meets the control's underlying purpose and intent effectively.
* **Justification:** The evidence collectively supports the unique identification and centralized authentication of devices, fulfilling the spirit of the control.
* **Critical Gaps in Spirit (if applicable):** None identified; all evidence aligns with the control's intent.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided meets all control requirements and demonstrates the organization’s commitment to maintaining compliance with CMMC standards.

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