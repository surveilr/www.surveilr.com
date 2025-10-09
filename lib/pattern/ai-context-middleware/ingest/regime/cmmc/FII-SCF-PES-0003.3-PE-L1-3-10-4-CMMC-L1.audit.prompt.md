---
title: "Audit Prompt: Access Logging Policy for Physical Security Control"
weight: 1
description: "Establishes a framework for logging access attempts at controlled points to enhance security, accountability, and regulatory compliance."
publishDate: "2025-10-06"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "PE.L1-3.10.4"
control-question: "Does the organization generate a log entry for each access attempt through controlled ingress and egress points?"
fiiId: "FII-SCF-PES-0003.3"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 1", "Compliance"]
---

**[START OF GENERATED PROMPT MUST CONTENT]**

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
  * **Control's Stated Purpose/Intent:** "The organization generates a log entry for each access attempt through controlled ingress and egress points."
      * **Control Code:** PE.L1-3.10.4
      * **Control Question:** Does the organization generate a log entry for each access attempt through controlled ingress and egress points?
      * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-PES-0003.3
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework for generating log entries for all access attempts through controlled ingress and egress points within the organization. This policy is crucial for maintaining the integrity of our Physical & Environmental Security posture, ensuring accountability, and facilitating compliance with regulatory requirements. By documenting access attempts, we can enhance security monitoring, investigate incidents, and demonstrate compliance with established standards. The organization mandates the generation of log entries for each access attempt through controlled ingress and egress points."
  * **Provided Evidence for Audit:** "Automated logging solutions are implemented to capture access attempts in real-time. Access attempts are logged with date, time, user identity, and access outcome. Facility Managers review and sign off on log summaries quarterly, which are uploaded to Surveilr for attestation."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: CMMC - PE.L1-3.10.4

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** PE.L1-3.10.4
**Control Question:** Does the organization generate a log entry for each access attempt through controlled ingress and egress points?
**Internal ID (FII):** FII-SCF-PES-0003.3
**Control's Stated Purpose/Intent:** The organization generates a log entry for each access attempt through controlled ingress and egress points.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** All access attempts through controlled ingress and egress points must generate log entries that capture the date, time, user identity, and access outcome (successful/unsuccessful).
    * **Provided Evidence:** Automated logging solutions are implemented to capture access attempts in real-time.
    * **Surveilr Method (as described/expected):** Automated logging systems configured to ensure that all events are recorded and stored securely.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_logs WHERE timestamp >= NOW() - INTERVAL '1 hour';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that all access attempts are logged with necessary details, fulfilling the control requirement for machine attestable evidence.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Facility Managers must review and sign off on log summaries quarterly.
    * **Provided Evidence:** Facility Managers review and sign off on log summaries quarterly, which are uploaded to Surveilr.
    * **Human Action Involved (as per control/standard):** Facility Managers conducting reviews of access logs and signing attestation.
    * **Surveilr Recording/Tracking:** Surveilr stores the uploaded log summaries and records the act of human attestation.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence confirms that the human attestation process is in place, and summaries are being reviewed and signed as required.

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** The provided evidence shows that the organization not only fulfills the literal requirements of logging access attempts but also aligns with the intent of maintaining security integrity and accountability.
* **Justification:** The comprehensive logging and human attestation process ensures that access attempts are appropriately recorded, facilitating security monitoring and compliance.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings indicate that the organization effectively generates log entries for all access attempts and has in place a robust process for human attestation, meeting both the letter and spirit of the control requirements.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * N/A
* **Specific Non-Compliant Evidence Required Correction:**
    * N/A
* **Required Human Action Steps:**
    * N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**