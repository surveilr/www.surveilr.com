---
title: "Audit Prompt: Personnel Security Risk Management Policy"
weight: 1
description: "Establishes a framework for managing personnel security risks through designated risk assessments and comprehensive screening criteria for all organizational positions."
publishDate: "2025-10-11"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-HRS-0002"
control-question: "Does the organization manage personnel security risk by assigning a risk designation to all positions and establishing screening criteria for individuals filling those positions?"
fiiId: "FII-SCF-HRS-0002"
regimeType: "ISO"
category: ["ISO", "Compliance"]
---

You're an **official auditor (e.g., ISO Auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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

  * **Audit Standard/Framework:** ISO 27001
  * **Control's Stated Purpose/Intent:** "The organization manages personnel security risk by assigning a risk designation to all positions and establishing screening criteria for individuals filling those positions."
Control Code: HRS-001
Control Question: Does the organization manage personnel security risk by assigning a risk designation to all positions and establishing screening criteria for individuals filling those positions?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-HRS-0002
  * **Policy/Process Description (for context on intent and expected evidence):**
    "Managing personnel security risk is essential to safeguarding sensitive information and maintaining the integrity of organizational operations. By assigning risk designations to all positions, the organization can identify potential vulnerabilities and implement appropriate screening criteria for individuals filling those positions. This proactive approach not only enhances security but also fosters a culture of accountability and trust within the workforce. The organization is committed to effectively managing personnel security risk through the assignment of risk designations to all positions and the establishment of comprehensive screening criteria for individuals occupying those positions."
  * **Provided Evidence for Audit:** "1. Background check logs confirming completion of required screenings for all new hires as of the last fiscal quarter. 2. HR information system reports indicating that risk designations have been assigned to all positions. 3. Certification records from managers confirming that risk designations have been reviewed and documented on a quarterly basis."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: ISO 27001 - HRS-001

**Overall Audit Result: [PASS]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [ISO Auditor]
**Control Code:** [HRS-001]
**Control Question:** [Does the organization manage personnel security risk by assigning a risk designation to all positions and establishing screening criteria for individuals filling those positions?]
**Internal ID (FII):** [FII-SCF-HRS-0002]
**Control's Stated Purpose/Intent:** [The organization manages personnel security risk by assigning a risk designation to all positions and establishing screening criteria for individuals filling those positions.]

## 1. Executive Summary

The audit findings indicate that the organization has effectively managed personnel security risks by assigning risk designations to all positions and establishing screening criteria for individuals filling those positions. The evidence provided demonstrates compliance with the control's requirements, including background check logs, HR system reports, and certification records from managers. No significant evidence gaps were identified, and all required actions have been substantiated.

## 2. Evidence Assessment Against Control Requirements

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** 100% of all positions will have a documented risk designation assigned.
    * **Provided Evidence:** HR information system reports confirming risk designations assigned to all positions.
    * **Surveilr Method (as described/expected):** Automated data ingestion from the HR information system.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM RSSD WHERE position_status = 'assigned';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided HR system reports confirm that all positions have documented risk designations assigned, fulfilling the control requirement.

* **Control Requirement/Expected Evidence:** 95% of personnel will have completed the required screening criteria prior to assuming their roles.
    * **Provided Evidence:** Background check logs confirming completion of screenings.
    * **Surveilr Method (as described/expected):** Data ingestion from background check systems.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM screenings WHERE status = 'completed' AND date > '2025-01-01';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The background check logs indicate that all new hires have completed the required screenings, meeting the control's compliance criteria.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Managers certifying on a quarterly basis that risk designations have been reviewed and properly documented.
    * **Provided Evidence:** Certification records from managers confirming compliance.
    * **Human Action Involved (as per control/standard):** Managerial review and documentation of risk designations.
    * **Surveilr Recording/Tracking:** Records of certification documents stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The certification records confirm that managers have completed the quarterly reviews and documentation as required.

## 3. Overall Alignment with Control's Intent Spirit

* **Assessment:** The provided evidence clearly demonstrates that the organization is actively managing personnel security risks in alignment with the control's intent.
* **Justification:** The comprehensive approach to assigning risk designations and conducting screenings aligns with the overall goals of enhancing security and accountability within the workforce.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided thoroughly meets the control's requirements, demonstrating compliance with the necessary risk management practices. All evidence aligns with both the letter and spirit of the control, confirming that personnel security risks are effectively managed.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** 
    * N/A (All evidence is present)
* **Specific Non-Compliant Evidence Required Correction:** 
    * N/A (All evidence is compliant)
* **Required Human Action Steps:** 
    * N/A (All required actions have been completed)
* **Next Steps for Re-Audit:** 
    * N/A (No re-audit necessary due to successful compliance)

**[END OF GENERATED PROMPT CONTENT]**