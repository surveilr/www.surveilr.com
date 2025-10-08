---
title: "Audit Prompt: Media Marking Policy for ePHI Security Compliance"
weight: 1
description: "Establishes guidelines for marking media containing ePHI to ensure compliance with security requirements and protect sensitive data across all relevant systems."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "MP.L2-3.8.4"
control-question: "Does the organization mark media in accordance with data protection requirements so that personnel are alerted to distribution limitations, handling caveats and applicable security requirements?"
fiiId: "FII-SCF-DCH-0004"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
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
  * **Control's Stated Purpose/Intent:** "The organization marks media in accordance with data protection requirements so that personnel are alerted to distribution limitations, handling caveats, and applicable security requirements."
  * **Control Code:** MP.L2-3.8.4
  * **Control Question:** "Does the organization mark media in accordance with data protection requirements so that personnel are alerted to distribution limitations, handling caveats, and applicable security requirements?"
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-DCH-0004
  * **Policy/Process Description (for context on intent and expected evidence):** "This policy outlines the requirements for marking media in accordance with data protection requirements to ensure personnel are alerted to distribution limitations, handling caveats, and applicable security requirements. It is designed to achieve compliance with the CMMC control MP.L2-3.8.4 and to maximize machine attestability. All media containing electronically protected health information (ePHI) must be marked clearly to indicate distribution limitations, handling requirements, and security caveats."
  * **Provided Evidence for Audit:** "Automated logs show that 95% of media marked correctly within 24 hours of creation or modification. A signed acknowledgment form from workforce members indicating understanding of marking policies is stored in Surveilr. However, there are no incident reports regarding unmarked media, and the compliance audit report indicates that only 80% adherence was achieved."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: CMMC - MP.L2-3.8.4

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** MP.L2-3.8.4
**Control Question:** "Does the organization mark media in accordance with data protection requirements so that personnel are alerted to distribution limitations, handling caveats, and applicable security requirements?"
**Internal ID (FII):** FII-SCF-DCH-0004
**Control's Stated Purpose/Intent:** "The organization marks media in accordance with data protection requirements so that personnel are alerted to distribution limitations, handling caveats, and applicable security requirements."

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Media must be marked in accordance with security requirements.
    * **Provided Evidence:** Automated logs show that 95% of media marked correctly within 24 hours of creation or modification.
    * **Surveilr Method (as described/expected):** Automated monitoring tools logged marking events and maintained records of compliance status.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM media_marking_logs WHERE timestamp > NOW() - INTERVAL '24 HOURS' AND status = 'marked' WHERE compliance = 'true';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence provided indicates that the majority of media was marked correctly within the required timeframe, demonstrating adherence to the control requirement.

* **Control Requirement/Expected Evidence:** Compliance audit reports indicating adherence to media marking protocols.
    * **Provided Evidence:** Compliance audit report indicates that only 80% adherence was achieved.
    * **Surveilr Method (as described/expected):** Compliance reports generated from Surveilr's evidence logging.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM media_marking_logs WHERE compliance = 'true';
    * **Compliance Status:** NON-COMPLIANT
    * **Justification:** The compliance audit report indicates that only 80% adherence was achieved, which does not meet the required standard for compliance.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Workforce members must submit a signed acknowledgment form indicating understanding of marking policies.
    * **Provided Evidence:** A signed acknowledgment form is stored in Surveilr.
    * **Human Action Involved (as per control/standard):** Workforce members signed acknowledgment form regarding marking policies.
    * **Surveilr Recording/Tracking:** The signed acknowledgment forms are uploaded and stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed acknowledgment forms demonstrate that workforce members are aware of and understand the marking policies, fulfilling this requirement.

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** The evidence demonstrates that while the organization has made efforts to comply with the media marking control, the overall adherence rate of 80% indicates that there are significant gaps in compliance.
* **Justification:** Although a majority of media is marked correctly and acknowledgment of policies has been obtained, the failure to achieve full compliance indicates that the underlying intent and spirit of the control are not being fully met.
* **Critical Gaps in Spirit (if applicable):** The lack of incident reports regarding unmarked media and the low adherence rate suggests a potential lack of diligence or oversight in enforcing the marking protocols.

## 4. Audit Conclusion and  Final Justification

* **Final Decision:** FAIL
* **Comprehensive Rationale:** The overall audit result is a "FAIL" due to the non-compliance of the mandatory adherence rate, which fell short of the required standard. The provided evidence shows significant gaps in the marking of media, which does not align with the control's intent.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * Evidence of compliance audit reports indicating 100% adherence to media marking protocols.
* **Specific Non-Compliant Evidence Required Correction:**
    * The compliance audit report must be addressed to reflect a full adherence rate of 100%. Corrective actions must be documented and submitted to demonstrate compliance.
* **Required Human Action Steps:**
    * Engage the Compliance Officer to review the marking procedures and identify gaps leading to the 20% non-compliance.
    * Provide training and awareness sessions to workforce members to ensure understanding and adherence to marking requirements.
* **Next Steps for Re-Audit:** The organization must gather the missing evidence and corrections to the compliance audit report, then submit for re-evaluation within 30 days.