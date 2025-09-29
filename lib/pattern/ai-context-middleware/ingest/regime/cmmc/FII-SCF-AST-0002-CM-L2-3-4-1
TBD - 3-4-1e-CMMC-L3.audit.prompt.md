---
title: "Audit Prompt: Technology Asset Inventory Management Policy"
weight: 1
description: "Establishes a comprehensive framework for accurately inventorying and managing technology assets to ensure compliance and protect sensitive information."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CM.L2-3.4.1
TBD - 3.4.1e"
control-question: "Does the organization perform inventories of technology assets that:
 ▪ Accurately reflects the current systems, applications and services in use; 
 ▪ Identifies authorized software products, including business justification details;
 ▪ Is at the level of granularity deemed necessary for tracking and reporting;
 ▪ Includes organization-defined information deemed necessary to achieve effective property accountability; and
 ▪ Is available for review and audit by designated organizational personnel?"
fiiId: "FII-SCF-AST-0002"
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
  * **Control's Stated Purpose/Intent:** "The organization performs inventories of technology assets that accurately reflects the current systems, applications and services in use; identifies authorized software products, including business justification details; is at the level of granularity deemed necessary for tracking and reporting; includes organization-defined information deemed necessary to achieve effective property accountability; and is available for review and audit by designated organizational personnel."
  * **Control Code:** CM.L2-3.4.1
  * **Control Question:** "Does the organization perform inventories of technology assets that: accurately reflects the current systems, applications and services in use; identifies authorized software products, including business justification details; is at the level of granularity deemed necessary for tracking and reporting; includes organization-defined information deemed necessary to achieve effective property accountability; and is available for review and audit by designated organizational personnel?"
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-AST-0002
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework for the accurate inventorying of technology assets within the organization. Effective asset management is crucial for maintaining the integrity, confidentiality, and availability of information systems and data, particularly electronic Protected Health Information (ePHI). This policy ensures that all technology assets are accounted for, authorized, and managed in compliance with applicable regulations and standards. The organization is committed to maintaining an accurate and comprehensive inventory of all technology assets. This includes documenting all systems, applications, and services in use, ensuring that only authorized software products are deployed, and maintaining the necessary level of granularity for effective tracking and reporting. The organization will utilize automated methods for inventory management wherever possible, supplemented by human attestation when necessary."
  * **Provided Evidence for Audit:** "Automated tools will be employed to collect data on technology assets, including system configurations, installed software, and usage metrics. These tools will generate reports that reflect the current state of assets. Machine attestations will be gathered through automated inventory management systems that regularly scan networks and devices. These systems will log changes in real-time, ensuring that the inventory is always up-to-date and verifiable. When automation is impractical, designated personnel will manually verify asset inventories. This will involve conducting physical audits of technology assets Semi-Annually and completing attestation forms that confirm the accuracy of the inventory Post-Audit."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - CM.L2-3.4.1

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** CM.L2-3.4.1
**Control Question:** "Does the organization perform inventories of technology assets that: accurately reflects the current systems, applications and services in use; identifies authorized software products, including business justification details; is at the level of granularity deemed necessary for tracking and reporting; includes organization-defined information deemed necessary to achieve effective property accountability; and is available for review and audit by designated organizational personnel?"
**Internal ID (FII):** FII-SCF-AST-0002
**Control's Stated Purpose/Intent:** "The organization performs inventories of technology assets that accurately reflects the current systems, applications and services in use; identifies authorized software products, including business justification details; is at the level of granularity deemed necessary for tracking and reporting; includes organization-defined information deemed necessary to achieve effective property accountability; and is available for review and audit by designated organizational personnel."

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** "Accurate reflection of current systems, applications, and services in use."
    * **Provided Evidence:** "Automated tools will be employed to collect data on technology assets, including system configurations, installed software, and usage metrics."
    * **Surveilr Method (as described/expected):** "Automated data ingestion using inventory management systems."
    * **Conceptual/Actual SQL Query Context:** "SELECT * FROM assets WHERE status = 'active';"
    * **Compliance Status:** [COMPLIANT / NON-COMPLIANT / INSUFFICIENT EVIDENCE]
    * **Justification:** [Detailed explanation of why the evidence is compliant, non-compliant, or insufficient, directly correlating the *provided evidence* to the *control requirement*. If non-compliant, specify the exact deviation.]

* **Control Requirement/Expected Evidence:** "Identification of authorized software products, including business justification details."
    * **Provided Evidence:** [Reference to the specific machine-attestable evidence provided in the input for this requirement, or clear statement of its absence.]
    * **Surveilr Method (as described/expected):** [How Surveilr *would* or *did* collect this specific piece of evidence.]
    * **Conceptual/Actual SQL Query Context:** [Conceptual SQL query relevant to verifying this requirement against RSSD.]
    * **Compliance Status:** [COMPLIANT / NON-COMPLIANT / INSUFFICIENT EVIDENCE]
    * **Justification:** [Detailed explanation of why the evidence is compliant, non-compliant, or insufficient.]

* **Control Requirement/Expected Evidence:** "Level of granularity deemed necessary for tracking and reporting."
    * **Provided Evidence:** [Reference to the specific machine-attestable evidence provided in the input for this requirement, or clear statement of its absence.]
    * **Surveilr Method (as described/expected):** [How Surveilr *would* or *did* collect this specific piece of evidence.]
    * **Conceptual/Actual SQL Query Context:** [Conceptual SQL query relevant to verifying this requirement against RSSD.]
    * **Compliance Status:** [COMPLIANT / NON-COMPLIANT / INSUFFICIENT EVIDENCE]
    * **Justification:** [Detailed explanation of why the evidence is compliant, non-compliant, or insufficient.]

* **Control Requirement/Expected Evidence:** "Includes organization-defined information for effective property accountability."
    * **Provided Evidence:** [Reference to the specific machine-attestable evidence provided in the input for this requirement, or clear statement of its absence.]
    * **Surveilr Method (as described/expected):** [How Surveilr *would* or *did* collect this specific piece of evidence.]
    * **Conceptual/Actual SQL Query Context:** [Conceptual SQL query relevant to verifying this requirement against RSSD.]
    * **Compliance Status:** [COMPLIANT / NON-COMPLIANT / INSUFFICIENT EVIDENCE]
    * **Justification:** [Detailed explanation of why the evidence is compliant, non-compliant, or insufficient.]

* **Control Requirement/Expected Evidence:** "Available for review and audit by designated organizational personnel."
    * **Provided Evidence:** [Reference to the specific machine-attestable evidence provided in the input for this requirement, or clear statement of its absence.]
    * **Surveilr Method (as described/expected):** [How Surveilr *would* or *did* collect this specific piece of evidence.]
    * **Conceptual/Actual SQL Query Context:** [Conceptual SQL query relevant to verifying this requirement against RSSD.]
    * **Compliance Status:** [COMPLIANT / NON-COMPLIANT / INSUFFICIENT EVIDENCE]
    * **Justification:** [Detailed explanation of why the evidence is compliant, non-compliant, or insufficient.]

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** "Manual verification of asset inventories when automation is impractical."
    * **Provided Evidence:** "Designated personnel will manually verify asset inventories through physical audits of technology assets Semi-Annually."
    * **Human Action Involved (as per control/standard):** "Conducting physical audits and completing attestation forms."
    * **Surveilr Recording/Tracking:** "Surveilr records the act of human attestation through stored signed forms."
    * **Compliance Status:** [COMPLIANT / NON-COMPLIANT / INSUFFICIENT EVIDENCE]
    * **Justification:** [Detailed explanation of why the evidence is compliant, non-compliant, or insufficient.]

* **Control Requirement/Expected Evidence:** "Completion of attestation forms that confirm the accuracy of the inventory."
    * **Provided Evidence:** [Reference to the specific human-attestable evidence provided in the input for this requirement, or clear statement of its absence.]
    * **Human Action Involved (as per control/standard):** [Description of the manual action that *should* have occurred as per the control or standard.]
    * **Surveilr Recording/Tracking:** [How Surveilr *would* or *did* record the *act* or *output* of this human attestation.]
    * **Compliance Status:** [COMPLIANT / NON-COMPLIANT / INSUFFICIENT EVIDENCE]
    * **Justification:** [Detailed explanation of why the evidence is compliant, non-compliant, or insufficient.]

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** [Based on the totality of the provided evidence, does it genuinely demonstrate that the control's underlying purpose and intent are being met in practice?]
* **Justification:** [Explain why or why not, considering the broader objectives of the control beyond just literal checklist items. This is a holistic assessment of the evidence's effectiveness.]
* **Critical Gaps in Spirit (if applicable):** [If certain evidence is present but still fails to meet the *spirit* of the control, explain this with specific examples from the evidence.]

## 4. Audit Conclusion and Final Justification

* **Final Decision:** [Reiterate the "PASS" or "FAIL" decision, which must be based *solely* on the provided evidence's direct compliance with the control requirements and intent.]
* **Comprehensive Rationale:** [Provide a concise but comprehensive justification for the final decision, summarizing the most critical points of compliance or non-compliance identified during the evidence assessment.]

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [For each missing piece of evidence identified in Section 2, state *exactly* what is needed.]
    * [Specify the required format/type for each missing piece.]
* **Specific Non-Compliant Evidence Required Correction:**
    * [For each instance of non-compliant evidence identified in Section 2, clearly state *why* it is non-compliant and what *specific correction* is required.]
    * [Specify the action needed.]
* **Required Human Action Steps:**
    * [List precise steps a human auditor or compliance officer needs to take.]
    * [Specify which teams or individuals are responsible for producing or correcting the evidence.]
* **Next Steps for Re-Audit:** [Outline the process for re-submission of the corrected/missing evidence for re-evaluation.]