---
title: "Audit Prompt: Privileged Account Multi-Factor Authentication Policy"
weight: 1
description: "Establishes Multi-Factor Authentication for privileged accounts to enhance security and ensure compliance with CMMC control IA.L2-3.5.3."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "IA.L2-3.5.3"
control-question: "Does the organization utilize Multi-Factor Authentication (MFA) to authenticate network access for privileged accounts?"
fiiId: "FII-SCF-IAC-0006.1"
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
  * **Control's Stated Purpose/Intent:** "The organization utilizes Multi-Factor Authentication (MFA) to authenticate network access for privileged accounts."
    * Control Code: IA.L2-3.5.3
    * Control Question: Does the organization utilize Multi-Factor Authentication (MFA) to authenticate network access for privileged accounts?
    * Internal ID (Foreign Integration Identifier as FII): FII-SCF-IAC-0006.1
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a comprehensive framework for implementing Multi-Factor Authentication (MFA) for privileged accounts within the organization. This policy aims to enhance the security posture of the organization by ensuring that only authorized personnel can access sensitive information and systems, thereby mitigating the risks associated with unauthorized access. The organization is committed to implementing Multi-Factor Authentication (MFA) for all privileged accounts to safeguard critical data and systems against unauthorized access and ensure compliance with CMMC control IA.L2-3.5.3."
  * **Provided Evidence for Audit:** "Evidence includes API integration logs showing MFA is enabled for 100% of privileged accounts as tracked by system logs, and a signed quarterly report from the IT manager confirming MFA compliance uploaded to Surveilr with metadata."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - IA.L2-3.5.3

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** IA.L2-3.5.3
**Control Question:** Does the organization utilize Multi-Factor Authentication (MFA) to authenticate network access for privileged accounts?
**Internal ID (FII):** FII-SCF-IAC-0006.1
**Control's Stated Purpose/Intent:** The organization utilizes Multi-Factor Authentication (MFA) to authenticate network access for privileged accounts.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** All privileged accounts must utilize Multi-Factor Authentication to ensure secure access.
    * **Provided Evidence:** Evidence includes API integration logs showing MFA is enabled for 100% of privileged accounts.
    * **Surveilr Method (as described/expected):** Surveilr used API integrations to validate MFA configurations and monitor compliance.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM privileged_accounts WHERE MFA_enabled = TRUE;
    * **Compliance Status:** COMPLIANT
    * **Justification:** The logs confirm that MFA is enabled for all privileged accounts, directly correlating with the control requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** The IT manager must sign a quarterly report confirming MFA compliance.
    * **Provided Evidence:** A signed quarterly report from the IT manager confirming MFA compliance uploaded to Surveilr with metadata.
    * **Human Action Involved (as per control/standard):** The IT manager's manual confirmation of MFA compliance.
    * **Surveilr Recording/Tracking:** The signed report is stored in Surveilr with metadata for tracking.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report meets the human attestation requirement by providing verification of compliance.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** Both machine and human attestation evidence confirm that MFA is implemented for all privileged accounts, thus fulfilling the control's objectives.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided shows full compliance with the control requirements and intent, as both machine attestations and human attestations confirm the implementation of MFA for privileged accounts.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [For each missing piece of evidence identified in Section 2, state *exactly* what is needed. E.g., "Missing current firewall rule sets from production firewalls (FII-XYZ-001) for the quarter ending 2025-06-30."]
    * [Specify the required format/type for each missing piece: e.g., "Obtain OSquery results for network interface configurations on all servers tagged 'production_web'.", "Provide a signed PDF of the latest incident response plan approval."]
* **Specific Non-Compliant Evidence Required Correction:**
    * [For each instance of non-compliant evidence identified in Section 2, clearly state *why* it is non-compliant and what *specific correction* is required. E.g., "Provided access logs show unapproved access event on 2025-07-15 by UserID 123; requires an associated incident ticket (IR-2025-005) or justification."]
    * [Specify the action needed: e.g., "Remediate firewall rule CC6-0010-005 to correctly block traffic from IP range X.Y.Z.0/24.", "Provide evidence of user access review completion for Q2 2025 for all critical systems."]
* **Required Human Action Steps:**
    * [List precise steps a human auditor or compliance officer needs to take. E.g., "Engage IT Operations to retrieve the specific logs for server X from date Y.", "Contact system owner Z to obtain management attestation for policy P."]
    * [Specify which teams or individuals are responsible for producing or correcting the evidence.]
* **Next Steps for Re-Audit:** [Outline the process for re-submission of the corrected/missing evidence for re-evaluation.]