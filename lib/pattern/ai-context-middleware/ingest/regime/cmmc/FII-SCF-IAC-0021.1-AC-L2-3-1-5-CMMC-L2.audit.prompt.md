---
title: "Audit Prompt: Access Control for Privileged Users Policy"
weight: 1
description: "Limit access to security functions to authorized privileged users while ensuring documentation, monitoring, and regular reviews to maintain compliance and security."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L2-3.1.5"
control-question: "Does the organization limit access to security functions to explicitly-authorized privileged users?"
fiiId: "FII-SCF-IAC-0021.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You're an **official auditor (e.g., auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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
  * **Control's Stated Purpose/Intent:** "The organization limits access to security functions to explicitly-authorized privileged users."
Control Code: AC.L2-3.1.5,
Control Question: Does the organization limit access to security functions to explicitly-authorized privileged users?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-IAC-0021.1
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy establishes guidelines for limiting access to security functions within the organization to explicitly authorized privileged users, as mandated by CMMC Control AC.L2-3.1.5. Proper management of access to security functions is vital to maintain the integrity, confidentiality, and availability of sensitive data, including electronic protected health information (ePHI). This policy outlines the methods for machine and human attestation to ensure compliance and security."
  * **Provided Evidence for Audit:** "Evidence includes access logs collected via OSquery, showing no unauthorized access attempts over a 30-day period. Additionally, quarterly access control review reports signed by Department Managers have been submitted, detailing privileged access and anomalies found."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L2-3.1.5

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L2-3.1.5
**Control Question:** Does the organization limit access to security functions to explicitly-authorized privileged users?
**Internal ID (FII):** FII-SCF-IAC-0021.1
**Control's Stated Purpose/Intent:** The organization limits access to security functions to explicitly-authorized privileged users.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Limit access to security functions to authorized privileged users.
    * **Provided Evidence:** Access logs collected via OSquery showing no unauthorized access attempts over a 30-day period.
    * **Surveilr Method (as described/expected):** OSquery for endpoint data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_logs WHERE access_attempt = 'unauthorized' AND timestamp BETWEEN NOW() - INTERVAL '30 DAY' AND NOW();
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that there were no unauthorized access attempts logged, fulfilling the requirement of limiting access to authorized users.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Quarterly access control review reports signed by Department Managers.
    * **Provided Evidence:** Signed quarterly access control review reports detailing privileged access and any anomalies found.
    * **Human Action Involved (as per control/standard):** Department Managers reviewing and signing access control reports.
    * **Surveilr Recording/Tracking:** Reports are ingested into Surveilr for compliance evidence.
    * **Compliance Status:** COMPLIANT
    * **Justification:** All Department Managers submitted signed reports within the required timeframe, indicating compliance with the control.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization effectively limits access to security functions to explicitly-authorized privileged users.
* **Justification:** The absence of unauthorized access attempts and the timely submission of signed reports indicate a proactive approach to access management.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided meets both the literal requirements and the underlying intent of the control. All access is logged and reviewed, and there have been no unauthorized access attempts, validating the control's effectiveness.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**