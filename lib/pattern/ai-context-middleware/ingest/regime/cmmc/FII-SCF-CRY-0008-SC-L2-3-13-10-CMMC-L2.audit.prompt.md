---
title: "Audit Prompt: Secure Public Key Infrastructure Policy"
weight: 1
description: "Establishes secure PKI infrastructure or services to protect sensitive data and ensure compliance with cybersecurity standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "SC.L2-3.13.10"
control-question: "Does the organization securely implement an internal Public Key Infrastructure (PKI) infrastructure or obtain PKI services from a reputable PKI service provider?"
fiiId: "FII-SCF-CRY-0008"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Cryptographic Protections"
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
  * **Control's Stated Purpose/Intent:** "Ensures that organizations maintain a secure Public Key Infrastructure (PKI), either by implementing their own PKI or by engaging with a reputable PKI service provider."
Control Code: SC.L2-3.13.10
Control Question: Does the organization securely implement an internal Public Key Infrastructure (PKI) infrastructure or obtain PKI services from a reputable PKI service provider?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-CRY-0008
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The organization is committed to securely implementing PKI infrastructure or obtaining PKI services from a reputable provider. This commitment ensures that all cryptographic operations are performed within a controlled and secure environment, safeguarding sensitive data and maintaining compliance with regulatory requirements."
  * **Provided Evidence for Audit:** "OSquery results showing daily PKI configuration checks for the past month; signed PKI review report by IT Manager uploaded to Surveilr; log entries documenting changes to PKI service providers."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - SC.L2-3.13.10

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** SC.L2-3.13.10
**Control Question:** Does the organization securely implement an internal Public Key Infrastructure (PKI) infrastructure or obtain PKI services from a reputable PKI service provider?
**Internal ID (FII):** FII-SCF-CRY-0008
**Control's Stated Purpose/Intent:** Ensures that organizations maintain a secure Public Key Infrastructure (PKI), either by implementing their own PKI or by engaging with a reputable PKI service provider.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Secure implementation of PKI infrastructure.
    * **Provided Evidence:** OSquery results showing daily PKI configuration checks for the past month.
    * **Surveilr Method (as described/expected):** Collected using OSquery for endpoint data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM PKI_Configurations WHERE Check_Date >= DATEADD(month, -1, GETDATE());
    * **Compliance Status:** COMPLIANT
    * **Justification:** Evidence shows consistent daily checks and confirms the secure configuration of PKI infrastructure.

* **Control Requirement/Expected Evidence:** Signed PKI review report by IT Manager.
    * **Provided Evidence:** Signed PKI review report uploaded to Surveilr.
    * **Surveilr Method (as described/expected):** Document uploaded to Surveilr with metadata.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report confirms the review and compliance with the PKI policy.

* **Control Requirement/Expected Evidence:** Documentation of changes in PKI service providers.
    * **Provided Evidence:** Log entries documenting changes to PKI service providers.
    * **Surveilr Method (as described/expected):** Changes recorded in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** Log entries show timely documentation of changes, ensuring compliance with the policy.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Monthly PKI review signed off by IT Manager.
    * **Provided Evidence:** Signed PKI review report uploaded to Surveilr.
    * **Human Action Involved (as per control/standard):** IT Manager's manual review and signing of the report.
    * **Surveilr Recording/Tracking:** Report uploaded to Surveilr with metadata.
    * **Compliance Status:** COMPLIANT
    * **Justification:** Human attestation is documented and valid, fulfilling the requirement.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization is effectively maintaining a secure PKI as intended by the control.
* **Justification:** The evidence aligns with the control's intent to ensure the integrity and security of cryptographic operations through both machine and human attestations.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence thoroughly demonstrates compliance with the requirements of the control, including secure configurations and proper documentation.

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