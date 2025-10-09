---
title: "Audit Prompt: Sensitive Data Protection Compliance Policy"
weight: 1
description: "Establishes comprehensive measures for protecting sensitive data through machine and human attestations across all organizational systems and environments."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CA.L2-3.12.4"
control-question: "Does the organization protect sensitive / regulated data that is collected, developed, received, transmitted, used or stored in support of the performance of a contract?"
fiiId: "FII-SCF-IAO-0003.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Information Assurance"
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
  * **Control's Stated Purpose/Intent:** "Does the organization protect sensitive / regulated data that is collected, developed, received, transmitted, used, or stored in support of the performance of a contract?"
Control Code: CA.L2-3.12.4,
Control Question: Does the organization protect sensitive / regulated data that is collected, developed, received, transmitted, used or stored in support of the performance of a contract?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-IAO-0003.2
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy outlines the requirements for protecting sensitive and regulated data as specified in the CMMC control CA.L2-3.12.4. The organization must ensure that all sensitive data collected, developed, received, transmitted, used, or stored in support of any contract is adequately protected. The organization commits to implementing appropriate measures for the protection of sensitive and regulated data across all environments, including cloud-hosted systems, SaaS applications, third-party vendor systems, and any channels used to handle such data. Compliance will be achieved through a combination of **machine attestation** and **human attestation** methods."
  * **Provided Evidence for Audit:** "1. Machine Attestable Evidence: Daily OSquery results confirming that sensitive data is encrypted during both transmission and storage. 2. Monthly signed encryption compliance report from the IT Manager. 3. Automated asset inventory collection results ingested into Surveilr. 4. Quarterly signed asset inventory report validated by Department Managers. 5. Vulnerability scanning tool reports submitted to Surveilr every 30 days. 6. Signed assessment reports submitted by security team leads after each quarterly security assessment."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - CA.L2-3.12.4

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** CMMC Auditor
**Control Code:** CA.L2-3.12.4
**Control Question:** Does the organization protect sensitive / regulated data that is collected, developed, received, transmitted, used or stored in support of the performance of a contract?
**Internal ID (FII):** FII-SCF-IAO-0003.2
**Control's Stated Purpose/Intent:** Does the organization protect sensitive / regulated data that is collected, developed, received, transmitted, used or stored in support of the performance of a contract?

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Ensure that sensitive data is encrypted during transmission and storage.
    * **Provided Evidence:** Daily OSquery results confirming that sensitive data is encrypted during both transmission and storage.
    * **Surveilr Method (as described/expected):** OSquery to verify encryption status of sensitive data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM sensitive_data WHERE encryption_status = 'ENCRYPTED';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The OSquery results clearly demonstrate that all sensitive data is encrypted as required.

* **Control Requirement/Expected Evidence:** Monthly signed encryption compliance report.
    * **Provided Evidence:** Signed encryption compliance report from the IT Manager.
    * **Surveilr Method (as described/expected):** Ingestion of signed report into Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report provides a valid human attestation confirming compliance with encryption requirements.

* **Control Requirement/Expected Evidence:** Maintain an inventory of all systems handling sensitive data.
    * **Provided Evidence:** Automated asset inventory collection results ingested into Surveilr.
    * **Surveilr Method (as described/expected):** OSquery used for asset inventory collection.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The automated inventory confirms that all systems handling sensitive data are accounted for as required.

* **Control Requirement/Expected Evidence:** Quarterly signed asset inventory report.
    * **Provided Evidence:** Signed asset inventory report from Department Managers.
    * **Surveilr Method (as described/expected):** Scanned documents uploaded to Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report provides a valid human attestation confirming that the asset inventory is accurate.

* **Control Requirement/Expected Evidence:** Conduct regular security assessments.
    * **Provided Evidence:** Vulnerability scanning tool reports submitted to Surveilr every 30 days.
    * **Surveilr Method (as described/expected):** Automated reporting from vulnerability scanning tools.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The automated reports confirm that security assessments are being conducted as required.

* **Control Requirement/Expected Evidence:** Signed assessment report after each quarterly security assessment.
    * **Provided Evidence:** Signed assessment reports submitted by security team leads.
    * **Surveilr Method (as described/expected):** Ingestion of signed reports into Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed reports provide valid human attestations confirming the completion of security assessments.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Monthly encryption compliance report signed by IT Manager.
    * **Provided Evidence:** Signed encryption compliance report from the IT Manager.
    * **Human Action Involved (as per control/standard):** IT Manager’s manual signature on the report.
    * **Surveilr Recording/Tracking:** Scanned report uploaded to Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signature validates the human attestation of encryption compliance.

* **Control Requirement/Expected Evidence:** Quarterly asset inventory report signed by Department Managers.
    * **Provided Evidence:** Signed asset inventory report from Department Managers.
    * **Human Action Involved (as per control/standard):** Manual validation and signing of the report.
    * **Surveilr Recording/Tracking:** Scanned report uploaded to Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report confirms human attestation of the asset inventory.

## 3. Overall Alignment with Control's Intent Spirit

* **Assessment:** The provided evidence demonstrates that the organization adequately protects sensitive/regulated data in accordance with the control’s intent.
* **Justification:** Each piece of evidence aligns with the requirements of the control, confirming both the literal compliance and the spirit of protecting sensitive data.
* **Critical Gaps in Spirit (if applicable):** No critical gaps identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence thoroughly demonstrates compliance with all aspects of the control, showing that sensitive data is protected as required.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A - No evidence missing]
* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A - All evidence compliant]
* **Required Human Action Steps:**
    * [N/A - No action needed]
* **Next Steps for Re-Audit:** [N/A - No re-audit necessary]