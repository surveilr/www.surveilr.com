---
title: "Audit Prompt: Automated Network Access Control Policy"
weight: 1
description: "Implement automated mechanisms for Network Access Control to detect unauthorized devices and ensure compliance with CMMC standards."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "TBD - 3.5.3e"
control-question: "Does the organization use automated mechanisms to employ Network Access Control (NAC), or a similar technology, which is capable of detecting unauthorized devices and disable network access to those unauthorized devices?"
fiiId: "FII-SCF-AST-0002.5"
regimeType: "CMMC"
cmmcLevel: 3
domain: "Asset Management"
category: ["CMMC", "Level 3", "Compliance"]
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
  * **Control's Stated Purpose/Intent:** "The organization uses automated mechanisms to employ Network Access Control (NAC) or a similar technology, which is capable of detecting unauthorized devices and disabling network access to those unauthorized devices."
Control Code: TBD - 3.5.3e,
Control Question: Does the organization use automated mechanisms to employ Network Access Control (NAC), or a similar technology, which is capable of detecting unauthorized devices and disable network access to those unauthorized devices?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-AST-0002.5
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy outlines the organization's commitment to utilizing automated mechanisms for Network Access Control (NAC) to detect unauthorized devices and manage network access. The importance of this policy lies in its role in ensuring compliance with the Cybersecurity Maturity Model Certification (CMMC) requirements, thereby safeguarding sensitive information and maintaining the integrity of our network infrastructure."
  * **Provided Evidence for Audit:** "Evidence includes OSquery logs indicating unauthorized access attempts, documentation of incident response actions taken for unauthorized devices, and records of NAC configuration settings. All logs and documentation are stored in the Surveilr system for review."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - TBD - 3.5.3e

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** TBD - 3.5.3e
**Control Question:** Does the organization use automated mechanisms to employ Network Access Control (NAC), or a similar technology, which is capable of detecting unauthorized devices and disable network access to those unauthorized devices?
**Internal ID (FII):** FII-SCF-AST-0002.5
**Control's Stated Purpose/Intent:** The organization uses automated mechanisms to employ Network Access Control (NAC) or a similar technology, which is capable of detecting unauthorized devices and disabling network access to those unauthorized devices.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must implement automated mechanisms for NAC that can detect unauthorized devices and restrict their access to the network.
    * **Provided Evidence:** OSquery logs indicating unauthorized access attempts and compliance status.
    * **Surveilr Method (as described/expected):** Utilized OSquery for automated monitoring of network devices.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM network_access_logs WHERE access_status = 'unauthorized';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The OSquery logs provide clear evidence of unauthorized access attempts and demonstrate that the NAC mechanisms are functioning as intended.

* **Control Requirement/Expected Evidence:** Documentation of incident response actions taken for unauthorized devices.
    * **Provided Evidence:** Incident response documentation submitted into the Surveilr system.
    * **Surveilr Method (as described/expected):** Records of incident responses are stored in Surveilr for review.
    * **Compliance Status:** COMPLIANT
    * **Justification:** All incidents are documented accurately and submitted within the required timeframe, meeting the control's expectations.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Personnel must document any incidents of unauthorized access.
    * **Provided Evidence:** Documentation of unauthorized access incidents from personnel.
    * **Human Action Involved (as per control/standard):** Manual documentation of incidents by IT Security Team.
    * **Surveilr Recording/Tracking:** Records of human attestation are stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** All incidents have been documented and submitted as required, demonstrating compliance with the control.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** The evidence shows that automated mechanisms are effectively detecting unauthorized devices and managing network access, aligning with the control's objectives.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided meets the control requirements and demonstrates compliance with the intent of the control, showing effective use of automated mechanisms for NAC.

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