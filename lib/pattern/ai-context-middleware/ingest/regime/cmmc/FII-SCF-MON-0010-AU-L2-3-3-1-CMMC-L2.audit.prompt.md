---
title: "Audit Prompt: Event Log Retention Compliance Policy"
weight: 1
description: "Establishes requirements for the retention of event logs to support investigations and ensure compliance with statutory and regulatory obligations."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AU.L2-3.3.1"
control-question: "Does the organization retain event logs for a time period consistent with records retention requirements to provide support for after-the-fact investigations of security incidents and to meet statutory, regulatory and contractual retention requirements?"
fiiId: "FII-SCF-MON-0010"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Continuous Monitoring"
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
  * **Control's Stated Purpose/Intent:** "The organization retains event logs for a time period consistent with records retention requirements to provide support for after-the-fact investigations of security incidents and to meet statutory, regulatory and contractual retention requirements."
    * **Control Code:** AU.L2-3.3.1
    * **Control Question:** Does the organization retain event logs for a time period consistent with records retention requirements to provide support for after-the-fact investigations of security incidents and to meet statutory, regulatory and contractual retention requirements?
    * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-MON-0010
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy establishes the requirements for the retention of event logs to support after-the-fact investigations of security incidents and to satisfy statutory, regulatory, and contractual retention requirements. The goal is to ensure compliance with CMMC Control AU.L2-3.3.1."
  * **Provided Evidence for Audit:** "The organization has implemented a centralized logging system that tracks and stores log data with retention policies enforced by the system. Additionally, a signed acknowledgment form submitted by the Compliance Officer documents the retention period and configurations. Automated alerts notify personnel of log access and modifications, and quarterly reviews of log accessibility are documented in Surveilr. Audit reports detailing log retention compliance are generated and stored securely, while the Compliance Officer reviews and signs off on the audit results, uploading the document to Surveilr."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AU.L2-3.3.1

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** CMMC Auditor
**Control Code:** AU.L2-3.3.1
**Control Question:** Does the organization retain event logs for a time period consistent with records retention requirements to provide support for after-the-fact investigations of security incidents and to meet statutory, regulatory and contractual retention requirements?
**Internal ID (FII):** FII-SCF-MON-0010
**Control's Stated Purpose/Intent:** The organization retains event logs for a time period consistent with records retention requirements to provide support for after-the-fact investigations of security incidents and to meet statutory, regulatory and contractual retention requirements.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Retain event logs for a defined minimum retention period.
    * **Provided Evidence:** The organization has implemented a centralized logging system that tracks and stores log data with retention policies enforced by the system.
    * **Surveilr Method (as described/expected):** Automated log retention using a centralized logging system.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM logs WHERE retention_period >= '7 years';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence indicates that the organization has a system that enforces defined retention policies, meeting the requirement.

* **Control Requirement/Expected Evidence:** Ensure logs are available for incident investigations.
    * **Provided Evidence:** Automated alerts notify personnel of log access and modifications.
    * **Surveilr Method (as described/expected):** Automated alerting systems.
    * **Conceptual/Actual SQL Query Context:** SELECT access_logs FROM alerts WHERE log_accessed = TRUE;
    * **Compliance Status:** COMPLIANT
    * **Justification:** The organization has mechanisms in place to ensure log accessibility, fulfilling the requirement.

* **Control Requirement/Expected Evidence:** Conduct regular audits of log retention practices.
    * **Provided Evidence:** Audit reports detailing log retention compliance are generated and stored securely.
    * **Surveilr Method (as described/expected):** Automated audit report generation.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM audit_reports WHERE compliance_status = 'compliant';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence shows that compliance audits are conducted regularly, meeting the control's requirements.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Document the retention period and configurations in Surveilr via a signed acknowledgment form.
    * **Provided Evidence:** A signed acknowledgment form submitted by the Compliance Officer documents the retention period and configurations.
    * **Human Action Involved (as per control/standard):** Compliance Officer's signature confirming understanding and adherence to log retention requirements.
    * **Surveilr Recording/Tracking:** The signed acknowledgment form is stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed acknowledgment serves as valid human attestation, confirming the retention period.

* **Control Requirement/Expected Evidence:** Conduct quarterly reviews of log accessibility and document findings in Surveilr.
    * **Provided Evidence:** Quarterly reviews of log accessibility are documented in Surveilr.
    * **Human Action Involved (as per control/standard):** Review and certification by responsible personnel.
    * **Surveilr Recording/Tracking:** Documentation of quarterly reviews is recorded in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The documented reviews indicate compliance with the requirement for human attestation.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization meets the underlying purpose and intent of the control.
* **Justification:** The combination of machine and human attestations effectively supports after-the-fact investigations and meets retention requirements.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings show comprehensive compliance with the control requirements through both machine and human attestations, demonstrating effective log retention practices.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A]
* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A]
* **Required Human Action Steps:**
    * [N/A]
* **Next Steps for Re-Audit:** [N/A]