---
title: "Audit Prompt: Asset Management Policy for Together.Health Security"
weight: 1
description: "Establishes a framework for effective management and real-time updating of asset inventories to ensure compliance and operational efficiency."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-AST-0002.1"
control-question: "Does the organization update asset inventories as part of component installations, removals and asset upgrades?"
fiiId: "FII-SCF-AST-0002.1"
regimeType: "THSA"
category: ["THSA", "Compliance"]
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

  * **Audit Standard/Framework:** Together.Health Security Assessment (THSA)
  * **Control's Stated Purpose/Intent:** "To ensure that the organization updates asset inventories as part of component installations, removals, and asset upgrades."
  * **Control Code:** FII-SCF-AST-0002.1
  * **Control Question:** "Does the organization update asset inventories as part of component installations, removals, and asset upgrades?"
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework for managing the organization’s asset inventories effectively. This includes ensuring that asset inventories are updated during component installations, removals, and upgrades. Accurate asset inventories are critical for maintaining compliance, security, and operational efficiency. The organization is committed to maintaining an accurate and up-to-date asset inventory that reflects all components within its infrastructure."
  * **Provided Evidence for Audit:** "OSquery results showing daily asset inventory updates, automated scripts that trigger updates upon installation/removal events, signed monthly asset inventory report by the IT manager for the last quarter."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: Together.Health Security Assessment (THSA) - FII-SCF-AST-0002.1

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., HIPAA Auditor]
**Control Code:** FII-SCF-AST-0002.1
**Control Question:** "Does the organization update asset inventories as part of component installations, removals, and asset upgrades?"
**Internal ID (FII):** FII-SCF-AST-0002.1
**Control's Stated Purpose/Intent:** "To ensure that the organization updates asset inventories as part of component installations, removals, and asset upgrades."

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** "Daily asset inventory updates via OSquery."
    * **Provided Evidence:** "OSquery results showing daily asset inventory updates."
    * **Surveilr Method (as described/expected):** "Evidence collected using OSquery for endpoint data."
    * **Conceptual/Actual SQL Query Context:** "SELECT * FROM asset_inventory WHERE updated_at >= CURRENT_DATE - INTERVAL '1 DAY';"
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The evidence confirms that asset inventories are being updated daily as required."

* **Control Requirement/Expected Evidence:** "Automated scripts trigger updates upon installation/removal events."
    * **Provided Evidence:** "Automated scripts that trigger updates to the asset inventory database."
    * **Surveilr Method (as described/expected):** "Scripts integrated with the system log."
    * **Conceptual/Actual SQL Query Context:** "SELECT * FROM asset_updates WHERE event_type IN ('installation', 'removal');"
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The evidence shows automated updates, ensuring compliance with the control."

* **Control Requirement/Expected Evidence:** "Monthly asset inventory report signed by IT manager."
    * **Provided Evidence:** "Signed monthly asset inventory report by the IT manager."
    * **Surveilr Method (as described/expected):** "Retention of signed document."
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The signed report is adequate human attestation of compliance."

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** "IT manager's sign-off on the monthly asset inventory report."
    * **Provided Evidence:** "Signed monthly asset inventory report by the IT manager."
    * **Human Action Involved (as per control/standard):** "IT manager signing off on the report."
    * **Surveilr Recording/Tracking:** "Document stored in Surveilr as evidence."
    * **Compliance Status:** COMPLIANT
    * **Justification:** "The human attestation is complete and properly documented."

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** "The provided evidence demonstrates that the organization is effectively updating asset inventories in line with the control's intent."
* **Justification:** "All aspects of evidence gathered show adherence to the literal requirements and intent of the control."
* **Critical Gaps in Spirit (if applicable):** "None noted."

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** "The organization has successfully demonstrated compliance with the control requirements through both machine and human attestation methods."

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [For each missing piece of evidence identified in Section 2, state *exactly* what is needed.]
* **Specific Non-Compliant Evidence Required Correction:**
    * [For each instance of non-compliant evidence identified in Section 2, clearly state *why* it is non-compliant and what *specific correction* is required.]
* **Required Human Action Steps:**
    * [List precise steps a human auditor or compliance officer needs to take.]
* **Next Steps for Re-Audit:** [Outline the process for re-submission of the corrected/missing evidence for re-evaluation.]