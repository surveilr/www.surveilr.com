---
title: "Audit Prompt: Together.Health Asset Inventory Management Policy"
weight: 1
description: "Establishes and maintains a comprehensive inventory of all system components to ensure effective asset management and compliance with THSA control FII-SCF-AST-0002."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-AST-0002"
control-question: "Does the organization inventory system components that:
 ▪ Accurately reflects the current system; 
 ▪ Is at the level of granularity deemed necessary for tracking and reporting;
 ▪ Includes organization-defined information deemed necessary to achieve effective property accountability; and
 ▪ Is available for review and audit by designated organizational officials?"
fiiId: "FII-SCF-AST-0002"
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
  * **Control's Stated Purpose/Intent:** "The organization inventories system components that accurately reflect the current system; is at the level of granularity deemed necessary for tracking and reporting; includes organization-defined information deemed necessary to achieve effective property accountability; and is available for review and audit by designated organizational officials."
  * **Control Code:** FII-SCF-AST-0002
  * **Control Question:** Does the organization inventory system components that accurately reflect the current system; is at the level of granularity deemed necessary for tracking and reporting; includes organization-defined information deemed necessary to achieve effective property accountability; and is available for review and audit by designated organizational officials?
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-AST-0002
  * **Policy/Process Description (for context on intent and expected evidence):** "The organization will inventory all system components to maintain an up-to-date and accurate record that reflects the current state of assets. This inventory will be detailed enough to support accountability and will be subject to regular reviews and audits as mandated by organizational requirements."
  * **Provided Evidence for Audit:** "Daily asset inventory collected via OSquery, quarterly signed inventory reports submitted to Surveilr, and automated alerts configured for discrepancies." 

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: Together.Health Security Assessment (THSA) - FII-SCF-AST-0002

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., THSA Auditor]
**Control Code:** FII-SCF-AST-0002
**Control Question:** Does the organization inventory system components that accurately reflect the current system; is at the level of granularity deemed necessary for tracking and reporting; includes organization-defined information deemed necessary to achieve effective property accountability; and is available for review and audit by designated organizational officials?
**Internal ID (FII):** FII-SCF-AST-0002
**Control's Stated Purpose/Intent:** The organization inventories system components that accurately reflect the current system; is at the level of granularity deemed necessary for tracking and reporting; includes organization-defined information deemed necessary to achieve effective property accountability; and is available for review and audit by designated organizational officials.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must maintain an accurate inventory of system components that reflects the current system status.
    * **Provided Evidence:** Daily asset inventory collected via OSquery.
    * **Surveilr Method (as described/expected):** OSquery used to automate daily collection of asset data.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM assets WHERE last_updated >= NOW() - INTERVAL '1 DAY';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence indicates daily updates to the asset inventory, matching the control requirement for accuracy and timeliness.

* **Control Requirement/Expected Evidence:** Inventory detail must support accountability and granularity.
    * **Provided Evidence:** Daily asset inventory includes necessary details for effective property accountability.
    * **Surveilr Method (as described/expected):** Data stored in RSSD is structured to reflect the required granularity.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM assets WHERE detailed_info IS NOT NULL;
    * **Compliance Status:** COMPLIANT
    * **Justification:** Inventory includes sufficient detail, demonstrating the necessary granularity for property accountability.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Quarterly review of the asset inventory by the IT manager with a signed report.
    * **Provided Evidence:** Quarterly signed inventory reports submitted to Surveilr.
    * **Human Action Involved (as per control/standard):** IT manager's signature confirming accuracy of the inventory.
    * **Surveilr Recording/Tracking:** Signed reports stored in Surveilr for compliance tracking.
    * **Compliance Status:** COMPLIANT
    * **Justification:** Signed quarterly reports confirm the required human attestation, aligning with control requirements.

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** The provided evidence demonstrates that the organization is effectively maintaining an inventory that meets both the letter and spirit of the control.
* **Justification:** All evidence collected supports the control's purpose of achieving accountability and accurate representation of system components.
* **Critical Gaps in Spirit (if applicable):** None noted; evidence supports compliance fully.

## 4. Audit Conclusion and  Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence assessed meets all stated control requirements, demonstrating adherence to both the literal and intended purposes of the control.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [For each missing piece of evidence identified in Section 2, state *exactly* what is needed. E.g., "Missing current firewall rule sets from production firewalls (FII-XYZ-001) for the quarter ending 2025-06-30."]
    * [Specify the required format/type for each missing piece: e.g., "Obtain OSquery results for network interface configurations on all servers tagged 'production_web'.", "Provide a signed PDF of the latest incident response plan approval."]
* **Specific Non-Compliant Evidence  Required Correction:**
    * [For each instance of non-compliant evidence identified in Section 2, clearly state *why* it is non-compliant and what *specific correction* is required. E.g., "Provided access logs show unapproved access event on 2025-07-15 by UserID 123; requires an associated incident ticket (IR-2025-005) or justification."]
    * [Specify the action needed: e.g., "Remediate firewall rule CC6-0010-005 to correctly block traffic from IP range X.Y.Z.0/24.", "Provide evidence of user access review completion for Q2 2025 for all critical systems."]
* **Required Human Action Steps:**
    * [List precise steps a human auditor or compliance officer needs to take. E.g., "Engage IT Operations to retrieve the specific logs for server X from date Y.", "Contact system owner Z to obtain management attestation for policy P."]
    * [Specify which teams or individuals are responsible for producing or correcting the evidence.]
* **Next Steps for Re-Audit:** [Outline the process for re-submission of the corrected/missing evidence for re-evaluation.]