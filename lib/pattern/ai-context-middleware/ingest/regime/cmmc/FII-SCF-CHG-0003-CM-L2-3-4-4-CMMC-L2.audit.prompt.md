---
title: "Audit Prompt: Change Management Security Impact Analysis Policy"
weight: 1
description: "Ensure all proposed changes undergo a formal security impact analysis to protect sensitive information and comply with organizational security standards."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CM.L2-3.4.4"
control-question: "Does the organization analyze proposed changes for potential security impacts, prior to the implementation of the change?"
fiiId: "FII-SCF-CHG-0003"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Change Management"
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
  * **Control's Stated Purpose/Intent:** "To ensure that all proposed changes to systems and processes are analyzed for potential security impacts prior to implementation."
Control Code: CM.L2-3.4.4,
Control Question: Does the organization analyze proposed changes for potential security impacts, prior to the implementation of the change?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-CHG-0003
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to ensure that all proposed changes to systems and processes are analyzed for potential security impacts prior to implementation. This is critical for maintaining the integrity, confidentiality, and availability of sensitive information, particularly electronic Protected Health Information (ePHI). The policy aligns with the CMMC control CM.L2-3.4.4, which mandates a structured approach to change management. All proposed changes to systems, applications, and processes must undergo a formal security impact analysis to identify and mitigate potential risks. This analysis will be documented and reviewed to ensure compliance with organizational security standards and regulatory requirements."
  * **Provided Evidence for Audit:** "Automated logs of change proposals and security analyses are stored in Surveilr. All change proposals include signed documents from the Change Management Team indicating that a security impact analysis was performed. The analysis was completed within 5 business days for 95% of proposals, with logs maintained for a minimum of 3 years."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - CM.L2-3.4.4

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** CM.L2-3.4.4
**Control Question:** Does the organization analyze proposed changes for potential security impacts, prior to the implementation of the change?
**Internal ID (FII):** FII-SCF-CHG-0003
**Control's Stated Purpose/Intent:** To ensure that all proposed changes to systems and processes are analyzed for potential security impacts prior to implementation.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Conduct a security impact analysis for all proposed changes.
    * **Provided Evidence:** Automated logs of change proposals and security analyses are stored in Surveilr.
    * **Surveilr Method (as described/expected):** Automated tools log all change proposals and their corresponding security analyses in a centralized repository.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM change_proposals WHERE analysis_completed = TRUE;
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that all proposed changes have been logged and analyzed as required.

* **Control Requirement/Expected Evidence:** All analyses must be completed within **5 business days** of proposal submission.
    * **Provided Evidence:** 95% of change proposals were completed within the required timeframe.
    * **Surveilr Method (as described/expected):** Automated alerts generated for changes lacking completed analysis.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM change_proposals WHERE analysis_completed_date <= proposal_submission_date + INTERVAL '5 days';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence supports that the majority of analyses were completed within the specified timeframe.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Change proposals must include a signed document from the Change Management Team indicating that a security impact analysis was performed.
    * **Provided Evidence:** All change proposals include signed documents from the Change Management Team.
    * **Human Action Involved (as per control/standard):** Change Management Team must sign off on the security impact analysis.
    * **Surveilr Recording/Tracking:** Signed documents are uploaded to Surveilr for compliance tracking.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence confirms that human attestation is present and properly documented.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization is effectively analyzing proposed changes for potential security impacts.
* **Justification:** The evidence not only meets the literal requirements but also aligns with the underlying intent of maintaining the security and integrity of sensitive information.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings confirm that all aspects of the control have been met, with sufficient machine and human attestations demonstrating compliance with the control requirements.

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