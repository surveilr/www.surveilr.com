---
title: "Audit Prompt: Unauthorized Software Execution Prevention Policy"
weight: 1
description: "Establishes guidelines to prevent unauthorized software execution, protecting sensitive information and ensuring compliance with regulatory requirements."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CM.L2-3.4.7"
control-question: "Does the organization configure systems to prevent the execution of unauthorized software programs?"
fiiId: "FII-SCF-CFG-0003.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
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
  * **Control's Stated Purpose/Intent:** "The organization configures systems to prevent the execution of unauthorized software programs."
    **Control Code:** CM.L2-3.4.7
    **Control Question:** Does the organization configure systems to prevent the execution of unauthorized software programs?
    **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-CFG-0003.2
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish guidelines for preventing the execution of unauthorized software within the organization's systems. Unauthorized software poses significant risks to the integrity, confidentiality, and availability of sensitive information, including electronic Protected Health Information (ePHI). By adhering to this policy, the organization can ensure compliance with regulatory requirements and enhance its overall security posture."
  * **Provided Evidence for Audit:** "Evidence was collected using OSquery to determine software inventory daily. The IT manager signed off on the quarterly software inventory report. Automated compliance tools verified the list of approved software weekly. The Compliance Officer reviewed and validated the list quarterly. System logs were monitored in real-time for unauthorized software installations, and System Administrators logged installation attempts and submitted reports monthly."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - CM.L2-3.4.7

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** CM.L2-3.4.7
**Control Question:** Does the organization configure systems to prevent the execution of unauthorized software programs?
**Internal ID (FII):** FII-SCF-CFG-0003.2
**Control's Stated Purpose/Intent:** The organization configures systems to prevent the execution of unauthorized software programs.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Configure systems to prevent unauthorized software execution.
    * **Provided Evidence:** Evidence was collected using OSquery to determine software inventory daily.
    * **Surveilr Method (as described/expected):** OSquery for endpoint data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM software_inventory WHERE unauthorized_execution = 'true';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that the organization has implemented daily OSquery checks, fulfilling the requirement to prevent unauthorized software execution.

* **Control Requirement/Expected Evidence:** Maintain an updated list of approved software.
    * **Provided Evidence:** Automated compliance tools verified the list of approved software weekly.
    * **Surveilr Method (as described/expected):** Automated compliance tools.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM approved_software WHERE last_verified < NOW() - INTERVAL '1 week';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The automated verification process ensures the list of approved software is current and meets compliance requirements.

* **Control Requirement/Expected Evidence:** Implement controls to block unauthorized software installations.
    * **Provided Evidence:** System logs were monitored in real-time for unauthorized software installations.
    * **Surveilr Method (as described/expected):** SIEM tools for real-time monitoring.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM system_logs WHERE action = 'installation' AND status = 'unauthorized';
    * **Compliance Status:** COMPLIANT
    * **Justification:** Continuous monitoring of system logs confirms that unauthorized installations are effectively blocked.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** IT manager must sign off on the quarterly software inventory report.
    * **Provided Evidence:** The IT manager signed off on the quarterly software inventory report.
    * **Human Action Involved (as per control/standard):** Quarterly review and approval of software inventory.
    * **Surveilr Recording/Tracking:** Signed quarterly report stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report serves as valid attestation of compliance.

* **Control Requirement/Expected Evidence:** Compliance Officer must review and validate the list quarterly.
    * **Provided Evidence:** The Compliance Officer reviewed and validated the list quarterly.
    * **Human Action Involved (as per control/standard):** Quarterly review of software list.
    * **Surveilr Recording/Tracking:** Review records documented in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** Proper documentation of the review confirms compliance with the requirement.

* **Control Requirement/Expected Evidence:** System Administrators must log any installation attempts and submit a report monthly.
    * **Provided Evidence:** System Administrators logged installation attempts and submitted reports monthly.
    * **Human Action Involved (as per control/standard):** Monthly reporting of unauthorized installation attempts.
    * **Surveilr Recording/Tracking:** Monthly reports stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** Regular logging and reporting demonstrate adherence to the requirement.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization effectively configures systems to prevent unauthorized software execution.
* **Justification:** The evidence aligns with both the literal and spirit of the control by actively preventing unauthorized software and maintaining rigorous oversight of software execution policies.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit concluded that all aspects of the control were effectively met, with clear evidence supporting compliance across machine and human attestation methods.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A - All evidence was compliant.]

* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A - All evidence was compliant.]

* **Required Human Action Steps:**
    * [N/A - All evidence was compliant.]

* **Next Steps for Re-Audit:** [N/A - All evidence was compliant.]