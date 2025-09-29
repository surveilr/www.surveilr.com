---
title: "Audit Prompt: IT Asset Management Security Policy"
weight: 1
description: "Establishes a framework for effective management, tracking, and security of IT assets related to electronic Protected Health Information (ePHI)."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CM.L2-3.4.1"
control-question: "Does the organization facilitate an IT Asset Management (ITAM) program to implement and manage asset management controls?"
fiiId: "FII-SCF-AST-0001"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Asset Management"
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
  * **Control's Stated Purpose/Intent:** "The organization facilitates an IT Asset Management (ITAM) program to implement and manage asset management controls."
Control Code: CM.L2-3.4.1,
Control Question: Does the organization facilitate an IT Asset Management (ITAM) program to implement and manage asset management controls?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-AST-0001
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a comprehensive framework for the implementation and management of an IT Asset Management (ITAM) program. This policy aims to ensure that all assets related to electronic Protected Health Information (ePHI) are effectively managed, tracked, and secured in compliance with relevant regulations and standards. The organization shall implement an IT Asset Management program that facilitates the identification, tracking, and management of all IT assets, including hardware, software, and cloud services. This program will utilize both machine and human attestation methods to ensure compliance with the SMART objectives of asset management."
  * **Provided Evidence for Audit:** "Evidence includes daily OSquery results for asset inventories, a quarterly signed inventory validation report by managers uploaded to Surveilr, and documentation of asset management policies reviewed and acknowledged by employees."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - CM.L2-3.4.1

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** CM.L2-3.4.1
**Control Question:** Does the organization facilitate an IT Asset Management (ITAM) program to implement and manage asset management controls?
**Internal ID (FII):** FII-SCF-AST-0001
**Control's Stated Purpose/Intent:** The organization facilitates an IT Asset Management (ITAM) program to implement and manage asset management controls.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Maintain an up-to-date inventory of all IT assets.
    * **Provided Evidence:** Daily OSquery results for asset inventories.
    * **Surveilr Method (as described/expected):** OSquery for endpoint data collection.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM asset_inventory WHERE timestamp >= CURRENT_DATE - INTERVAL '1 day';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The daily OSquery results demonstrate that the organization maintains an up-to-date inventory of IT assets as required.

* **Control Requirement/Expected Evidence:** Quarterly inventory validation by managers.
    * **Provided Evidence:** Signed inventory validation report uploaded to Surveilr.
    * **Surveilr Method (as described/expected):** Human attestation recorded in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report confirms that managers have validated the inventory, fulfilling the requirement for human attestation.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Annual acknowledgment of asset management policies by all employees.
    * **Provided Evidence:** Documentation of employee acknowledgments.
    * **Human Action Involved (as per control/standard):** Employees must sign to confirm understanding of the policy.
    * **Surveilr Recording/Tracking:** Acknowledgment forms stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The documentation shows that all employees have acknowledged the policy, meeting the requirement for human attestation.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization effectively implements and manages its IT Asset Management program.
* **Justification:** The evidence aligns with the control's intent by ensuring all assets are tracked and managed in compliance with established policies.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided meets all requirements of the control, demonstrating compliance with both the letter and the spirit of the control.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [For each missing piece of evidence identified in Section 2, state *exactly* what is needed.]
* **Specific Non-Compliant Evidence Required Correction:**
    * [For each instance of non-compliant evidence identified in Section 2, clearly state *why* it is non-compliant and what *specific correction* is required.]
* **Required Human Action Steps:**
    * [List precise steps a human auditor or compliance officer needs to take.]
* **Next Steps for Re-Audit:** [Outline the process for re-submission of the corrected/missing evidence for re-evaluation.]