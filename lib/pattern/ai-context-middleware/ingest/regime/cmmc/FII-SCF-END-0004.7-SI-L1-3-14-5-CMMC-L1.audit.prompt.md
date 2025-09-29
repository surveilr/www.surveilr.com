---
title: "Audit Prompt: Anti-Malware Technology Compliance Policy"
weight: 1
description: "Establishes continuous anti-malware technology operation on all endpoints to protect sensitive data and ensure compliance with CMMC control SI.L1-3.14.5."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "SI.L1-3.14.5"
control-question: "Does the organization ensure that anti-malware technologies are continuously running in real-time and cannot be disabled or altered by non-privileged users, unless specifically authorized by management on a case-by-case basis for a limited time period?"
fiiId: "FII-SCF-END-0004.7"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Endpoint Security"
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
  * **Control's Stated Purpose/Intent:** "The organization ensures that anti-malware technologies are continuously running in real-time and cannot be disabled or altered by non-privileged users, unless specifically authorized by management on a case-by-case basis for a limited time period."
  * **Control Code:** SI.L1-3.14.5
  * **Control Question:** Does the organization ensure that anti-malware technologies are continuously running in real-time and cannot be disabled or altered by non-privileged users, unless specifically authorized by management on a case-by-case basis for a limited time period?
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-END-0004.7
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy outlines the organization's commitment to maintaining endpoint security through the continuous operation of anti-malware technologies. The organization is committed to ensuring that anti-malware technologies are continuously running in real-time on all endpoints. These technologies must not be disabled or altered by non-privileged users without specific authorization from management. This measure is crucial for safeguarding our systems and data integrity."
  * **Provided Evidence for Audit:** "Evidence includes OSquery results confirming that anti-malware technologies are running on all endpoints, daily logs reviewed by IT Security, and documented exceptions approved by management."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - SI.L1-3.14.5

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** CMMC Auditor
**Control Code:** SI.L1-3.14.5
**Control Question:** Does the organization ensure that anti-malware technologies are continuously running in real-time and cannot be disabled or altered by non-privileged users, unless specifically authorized by management on a case-by-case basis for a limited time period?
**Internal ID (FII):** FII-SCF-END-0004.7
**Control's Stated Purpose/Intent:** The organization ensures that anti-malware technologies are continuously running in real-time and cannot be disabled or altered by non-privileged users, unless specifically authorized by management on a case-by-case basis for a limited time period.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Anti-malware technologies must operate continuously and in real-time on all endpoints.
    * **Provided Evidence:** OSquery results confirming that anti-malware technologies are running on all endpoints.
    * **Surveilr Method (as described/expected):** OSquery for endpoint data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM anti_malware WHERE status = 'running';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence provided shows that all endpoints have anti-malware technologies running continuously, meeting the control's requirements.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Documentation of exceptions to the policy must be maintained.
    * **Provided Evidence:** Documented exceptions approved by management.
    * **Human Action Involved (as per control/standard):** Managers must document any exceptions to the policy.
    * **Surveilr Recording/Tracking:** The act of human attestation is recorded in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The documented exceptions are appropriately approved by management, fulfilling the requirement for human attestation.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** The organization has implemented effective measures to ensure that anti-malware technologies are continuously operational and that any exceptions are properly documented and authorized.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings indicate full compliance with the control requirements, as evidenced by the machine attestable data and human attestations.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**