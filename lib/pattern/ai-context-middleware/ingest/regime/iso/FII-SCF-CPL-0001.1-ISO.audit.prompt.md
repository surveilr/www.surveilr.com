---
title: "Audit Prompt: ISO Compliance and Non-Compliance Management Policy"
weight: 1
description: "Establishes mechanisms for documenting, reviewing, and mitigating non-compliance with statutory, regulatory, and contractual obligations to protect ePHI."
publishDate: "2025-10-01"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-CPL-0001.1"
control-question: "Does the organization document and review instances of non-compliance with statutory, regulatory and/or contractual obligations to develop appropriate risk mitigation actions?"
fiiId: "FII-SCF-CPL-0001.1"
regimeType: "ISO"
category: ["ISO", "Compliance"]
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

  * **Audit Standard/Framework:** ISO 27001:2022
  * **Control's Stated Purpose/Intent:** "To ensure that the organization documents and reviews instances of non-compliance with statutory, regulatory, and/or contractual obligations to develop appropriate risk mitigation actions."
    - Control Code: FII-SCF-CPL-0001.1
    - Control Question: Does the organization document and review instances of non-compliance with statutory, regulatory and/or contractual obligations to develop appropriate risk mitigation actions?
    - Internal ID (Foreign Integration Identifier as FII): FII-SCF-CPL-0001.1
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy establishes the framework for documenting and reviewing instances of non-compliance with statutory, regulatory, and contractual obligations to develop appropriate risk mitigation actions. It ensures that the organization maintains compliance while protecting ePHI across all relevant systems and channels. The organization commits to maintaining comprehensive mechanisms for documenting and reviewing instances of non-compliance with statutory, regulatory, and contractual obligations. This includes the development of risk mitigation strategies based on these reviews."
  * **Provided Evidence for Audit:** "Automated compliance audit logs generated by monitoring tools, manually submitted signed report summarizing non-compliance incidents, automated logging of incidents in the compliance management system, and signed report from the IT Security Team documenting non-compliance incidents."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: ISO 27001:2022 - FII-SCF-CPL-0001.1

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., ISO Compliance Auditor]
**Control Code:** FII-SCF-CPL-0001.1
**Control Question:** Does the organization document and review instances of non-compliance with statutory, regulatory and/or contractual obligations to develop appropriate risk mitigation actions?
**Internal ID (FII):** FII-SCF-CPL-0001.1
**Control's Stated Purpose/Intent:** To ensure that the organization documents and reviews instances of non-compliance with statutory, regulatory, and/or contractual obligations to develop appropriate risk mitigation actions.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Document and review instances of non-compliance.
    * **Provided Evidence:** Automated compliance audit logs generated by monitoring tools.
    * **Surveilr Method (as described/expected):** Automated data ingestion from compliance audit tools.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM compliance_logs WHERE compliance_status = 'non-compliant';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that the organization maintains an automated log of non-compliance incidents, aligning with the control's requirement to document and review such instances.

* **Control Requirement/Expected Evidence:** Maintain a log of non-compliance incidents.
    * **Provided Evidence:** Automated logging of incidents in the compliance management system.
    * **Surveilr Method (as described/expected):** Automated data ingestion from the compliance management system.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM incidents WHERE logged_date >= DATE_SUB(CURDATE(), INTERVAL 5 DAY);
    * **Compliance Status:** COMPLIANT
    * **Justification:** The logs show documented non-compliance incidents as required, providing a reliable basis for risk mitigation actions.

* **Control Requirement/Expected Evidence:** Update the risk register.
    * **Provided Evidence:** The Compliance Officer will provide a quarterly summary of risk register updates to be reviewed by management.
    * **Surveilr Method (as described/expected):** Manual submission of signed report summarizing risk register updates.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM risk_register_updates WHERE update_date >= LAST_QUARTER();
    * **Compliance Status:** NON-COMPLIANT
    * **Justification:** There is no evidence of a timely update to the risk register within the stipulated 10 business days post-audit review findings.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Compliance Officer submits a signed report summarizing non-compliance incidents.
    * **Provided Evidence:** Signed report summarizing non-compliance incidents submitted manually.
    * **Human Action Involved (as per control/standard):** The Compliance Officer has manually verified and documented incidents.
    * **Surveilr Recording/Tracking:** The signed report is stored as an attachment in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The submission and storage of the signed report demonstrate compliance with the human attestation requirements for documenting non-compliance.

## 3. Overall Alignment with Control's Intent and Spirit

* **Assessment:** The provided evidence demonstrates a strong alignment with the control's intent to document and review instances of non-compliance.
* **Justification:** The automated logging mechanisms and manual attestations substantiate the organization's commitment to compliance, although the failure to update the risk register timely represents a significant gap.
* **Critical Gaps in Spirit (if applicable):** The lack of timely updates to the risk register undermines the spirit of proactive risk management as intended by the control.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** FAIL
* **Comprehensive Rationale:** While most evidence supports compliance, the failure to update the risk register within the specified timeframe indicates a significant non-compliance, leading to the overall failure of the audit.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * Provide the updated risk register reflecting the latest compliance audit findings and ensure it is submitted within 10 business days.
* **Specific Non-Compliant Evidence Required Correction:**
    * The submitted risk register is outdated. It must include all updates from the most recent compliance audit conducted, with a timestamp confirming its update within the required timeframe.
* **Required Human Action Steps:**
    * Engage the Compliance Officer to expedite the collection and update of the risk register.
    * Ensure the documentation reflects compliance audit findings and is submitted to the management for review.
* **Next Steps for Re-Audit:** Upon correction of the risk register and submission of the updated documentation, a re-audit will be scheduled to reassess compliance.