---
title: "Audit Prompt: Network Segmentation Policy for ePHI Security"
weight: 1
description: "Establishes robust network segmentation practices to protect ePHI and ensure compliance with regulatory standards."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "SC.L1-3.13.5"
control-question: "Does the organization ensure network architecture utilizes network segmentation to isolate systems, applications and services that protections from other network resources?"
fiiId: "FII-SCF-NET-0006"
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
* **Control's Stated Purpose/Intent:** "To ensure network architecture utilizes network segmentation to isolate systems, applications, and services that handle protections from other network resources."
  * Control Code: SC.L1-3.13.5
  * Control Question: Does the organization ensure network architecture utilizes network segmentation to isolate systems, applications, and services that protections from other network resources?
  * Internal ID (Foreign Integration Identifier as FII): FII-SCF-NET-0006
* **Policy/Process Description (for context on intent and expected evidence):**
  "This policy establishes the framework for network segmentation within the organization to ensure the isolation of systems, applications, and services that handle electronic Protected Health Information (ePHI). Effective network segmentation is crucial for enhancing security posture, mitigating risks associated with unauthorized access, and ensuring compliance with regulatory requirements. By implementing stringent segmentation practices, the organization can safeguard sensitive data and maintain trust with stakeholders."
* **Provided Evidence for Audit:** "1. Daily OSquery results confirming correct configurations for network segmentation. 2. Quarterly signed validation report from the Network Architect uploaded to Surveilr. 3. Daily network logs showing no unauthorized access attempts for the last quarter."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - SC.L1-3.13.5

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [CMMC Auditor]
**Control Code:** SC.L1-3.13.5
**Control Question:** Does the organization ensure network architecture utilizes network segmentation to isolate systems, applications, and services that protections from other network resources?
**Internal ID (FII):** FII-SCF-NET-0006
**Control's Stated Purpose/Intent:** To ensure network architecture utilizes network segmentation to isolate systems, applications, and services that handle protections from other network resources.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Daily machine attestations confirming correct network segmentation configurations.
    * **Provided Evidence:** Daily OSquery results confirming correct configurations for network segmentation.
    * **Surveilr Method (as described/expected):** OSquery.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM network_config WHERE segmentation = 'valid';.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided OSquery results demonstrate that the network segmentation configurations are correctly implemented and maintained daily.

* **Control Requirement/Expected Evidence:** Daily network logs showing no unauthorized access attempts.
    * **Provided Evidence:** Daily network logs showing no unauthorized access attempts for the last quarter.
    * **Surveilr Method (as described/expected):** Log ingestion from network security monitoring tools.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_logs WHERE access_attempt = 'unauthorized';.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The absence of unauthorized access attempts in the provided logs confirms that the network segmentation is effectively isolating sensitive systems.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Quarterly human attestations submitted and logged in Surveilr.
    * **Provided Evidence:** Quarterly signed validation report from the Network Architect uploaded to Surveilr.
    * **Human Action Involved (as per control/standard):** Network Architect signing the validation report.
    * **Surveilr Recording/Tracking:** Uploaded signed report with metadata in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed validation report from the Network Architect confirms compliance with the network segmentation policy.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** All aspects of the control's requirements have been satisfied, indicating that proper network segmentation practices are in place, effectively safeguarding ePHI and mitigating the risk of unauthorized access.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The organization has successfully implemented the network segmentation policy and provided sufficient evidence across all required aspects, demonstrating compliance with the control's literal requirements and intent.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [If applicable, state what evidence is missing.]
* **Specific Non-Compliant Evidence Required Correction:**
    * [If applicable, state what corrections are required.]
* **Required Human Action Steps:**
    * [If applicable, state specific steps to rectify issues.]
* **Next Steps for Re-Audit:** [Outline the process for re-submission of the corrected/missing evidence for re-evaluation.]

**[END OF GENERATED PROMPT CONTENT]**