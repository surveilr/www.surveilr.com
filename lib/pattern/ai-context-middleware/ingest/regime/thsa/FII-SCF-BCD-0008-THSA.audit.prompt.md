---
title: "Audit Prompt: Together.Health Backup Storage Policy"
weight: 1
description: "Establishes requirements for secure alternate storage sites to ensure effective backup recovery and enhance organizational resilience against data loss."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-BCD-0008"
control-question: "Does the organization establish an alternate storage site that includes both the assets and necessary agreements to permit the storage and recovery of system backup information?"
fiiId: "FII-SCF-BCD-0008"
regimeType: "THSA"
category: ["THSA", "Compliance"]
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

  * **Audit Standard/Framework:** Together.Health Security Assessment (THSA)
  * **Control's Stated Purpose/Intent:** "The organization shall establish and maintain an alternate storage site that includes both the necessary assets and agreements to permit the secure storage and recovery of system backup information."
Control Code: FII-SCF-BCD-0008,
Control Question: "Does the organization establish an alternate storage site that includes both the assets and necessary agreements to permit the storage and recovery of system backup information?"
Internal ID (Foreign Integration Identifier as FII): FII-SCF-BCD-0008
  * **Policy/Process Description (for context on intent and expected evidence):**
    "In the context of Business Continuity and Disaster Recovery (BCDR), the establishment of alternate storage sites for system backup information is critical to ensure that an organization can recover from unforeseen incidents. This policy focuses on the requirements for alternate storage sites, which safeguard backup assets and facilitate their recovery. By complying with this policy, the organization can mitigate risks associated with data loss, enhance its resilience, and maintain operational continuity. The organization must identify and maintain an alternate storage site with agreements for storage and recovery of backups. Machine attestation involves utilizing API integrations with cloud providers to automatically confirm the existence of backup agreements and validate storage locations. Human attestation requires a designated manager to sign off on the annual review of the alternate storage site agreements, with documentation retained for audit purposes."
  * **Provided Evidence for Audit:** "The organization has automated API integrations with cloud providers to confirm the existence of backup agreements and validate storage locations. Documentation of the last quarterly review of backup agreements is present, showing compliance with the policy. A scanned signed policy acknowledgement form from the designated manager is included, certifying the review of alternate storage site agreements."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: Together.Health Security Assessment (THSA) - FII-SCF-BCD-0008

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., HIPAA Auditor]
**Control Code:** FII-SCF-BCD-0008
**Control Question:** "Does the organization establish an alternate storage site that includes both the assets and necessary agreements to permit the storage and recovery of system backup information?"
**Internal ID (FII):** FII-SCF-BCD-0008
**Control's Stated Purpose/Intent:** "The organization shall establish and maintain an alternate storage site that includes both the necessary assets and agreements to permit the secure storage and recovery of system backup information."

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must identify and maintain an alternate storage site with agreements for storage and recovery of backups.
    * **Provided Evidence:** The organization has automated API integrations with cloud providers to confirm the existence of backup agreements and validate storage locations.
    * **Surveilr Method (as described/expected):** API integrations with cloud providers.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM backup_agreements WHERE status = 'active';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates an automated method for verifying the existence of backup agreements and validating storage locations, which aligns with the control requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** A designated manager must sign off on the annual review of the alternate storage site agreements, with documentation retained for audit purposes.
    * **Provided Evidence:** A scanned signed policy acknowledgement form from the designated manager is included, certifying the review of alternate storage site agreements.
    * **Human Action Involved (as per control/standard):** Annual review sign-off by designated manager.
    * **Surveilr Recording/Tracking:** Surveilr records the signing of the policy acknowledgement form.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided evidence includes a signed document that confirms the required human attestation, fulfilling the control's requirements.

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** The provided evidence sufficiently demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** The combination of machine and human attestations supports the organization's ability to recover from incidents, reflecting the spirit of the control.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The organization has successfully implemented both machine and human attestation methods that demonstrate compliance with the control requirements and intent.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * N/A
* **Specific Non-Compliant Evidence Required Correction:**
    * N/A
* **Required Human Action Steps:**
    * N/A
* **Next Steps for Re-Audit:** 
    * N/A

**[END OF GENERATED PROMPT CONTENT]**