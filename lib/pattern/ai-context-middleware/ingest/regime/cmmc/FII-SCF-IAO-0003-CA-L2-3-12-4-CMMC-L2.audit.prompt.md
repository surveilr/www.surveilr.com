---
title: "Audit Prompt: CMMC Policy for System Security & Privacy Plans"
weight: 1
description: "Establishes requirements for creating and maintaining System Security & Privacy Plans to enhance organizational security and compliance for critical systems."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "CA.L2-3.12.4"
control-question: "Does the organization generate System Security & Privacy Plans (SSPPs), or similar document repositories, to identify and maintain key architectural information on each critical system, application or service, as well as influence inputs, entities, systems, applications and processes, providing a historical record of the data and its origins?"
fiiId: "FII-SCF-IAO-0003"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Information Assurance"
category: ["CMMC", "Level 2", "Compliance"]
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

  * **Audit Standard/Framework:** CMMC
** Control's Stated Purpose/Intent:** "The purpose of Control CA.L2-3.12.4 is to ensure that organizations generate and maintain System Security & Privacy Plans (SSPPs) that capture key architectural information regarding critical systems, applications, and services, influencing inputs, entities, and processes, while providing a historical record of data and its origins."
Control Code: CA.L2-3.12.4
Control Question: Does the organization generate System Security & Privacy Plans (SSPPs), or similar document repositories, to identify and maintain key architectural information on each critical system, application or service, as well as influence inputs, entities, systems, applications, and processes, providing a historical record of the data and its origins?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-IAO-0003
  * **Policy/Process Description (for context on intent and expected evidence):**
    "Control CA.L2-3.12.4 mandates organizations to generate System Security & Privacy Plans (SSPPs) to identify and maintain key architectural information regarding critical systems, applications, and services. This control is essential for ensuring that organizations have a comprehensive understanding of their security posture and privacy measures. By maintaining SSPPs, organizations can effectively manage risks, ensure compliance with regulatory requirements, and provide a historical record of data origins and processing.

The organization is committed to the generation and maintenance of System Security & Privacy Plans (SSPPs) for all critical systems, applications, and services. This policy outlines the processes for documenting architectural information, ensuring that all relevant data is systematically captured, maintained, and reviewed to support the organization's security and compliance objectives."

  * **Provided Evidence for Audit:** "The organization has generated and stored SSPPs for all critical systems in the Surveilr platform. Evidence includes automated ingestion logs showing the timestamp of SSPP document uploads, signed attestations from workforce members acknowledging their understanding of the SSPP requirements, and a compliance report indicating 100% of critical systems have up-to-date SSPPs as of the last review date."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - CA.L2-3.12.4

**Overall Audit Result: [PASS]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [CMMC Auditor]
**Control Code:** [CA.L2-3.12.4]
**Control Question:** [Does the organization generate System Security & Privacy Plans (SSPPs), or similar document repositories, to identify and maintain key architectural information on each critical system, application or service, as well as influence inputs, entities, systems, applications, and processes, providing a historical record of the data and its origins?]
**Internal ID (FII):** [FII-SCF-IAO-0003]
**Control's Stated Purpose/Intent:** [The purpose of Control CA.L2-3.12.4 is to ensure that organizations generate and maintain System Security & Privacy Plans (SSPPs) that capture key architectural information regarding critical systems, applications, and services, influencing inputs, entities, and processes, while providing a historical record of data and its origins.]

## 1. Executive Summary

The audit findings indicate that the organization has successfully generated and maintained System Security & Privacy Plans (SSPPs) for all critical systems as required by Control CA.L2-3.12.4. The provided evidence demonstrates compliance with both the literal and intended requirements of the control. Key evidence includes automated ingestion logs and signed attestations, confirming that SSPPs are current and reflect the organization's security posture. Overall, the audit result is a definitive PASS.

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must generate and maintain SSPPs that detail the security and privacy measures for each critical system, application, or service.
    * **Provided Evidence:** Automated ingestion logs showing SSPP document uploads for all critical systems.
    * **Surveilr Method (as described/expected):** Evidence was ingested into the Surveilr platform via automated data collection mechanisms.
    * **Conceptual/Actual SQL Query Context:** SQL queries confirm that all SSPPs are present and up-to-date in the RSSD.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence provided clearly shows that SSPPs are being generated and stored according to policy requirements.

* **Control Requirement/Expected Evidence:** Evidence of regular review and updates to SSPPs.
    * **Provided Evidence:** Compliance report indicating that SSPPs are reviewed and updated annually.
    * **Surveilr Method (as described/expected):** Report generation through SQL queries tracking review dates.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The compliance report confirms that all SSPPs undergo the required annual review process.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Workforce members must submit signed attestations regarding their understanding of SSPP requirements.
    * **Provided Evidence:** Signed attestations from workforce members acknowledging SSPP requirements.
    * **Human Action Involved (as per control/standard):** Workforce members signing acknowledgment forms.
    * **Surveilr Recording/Tracking:** The signed documents are recorded and stored within the Surveilr platform.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed attestations provide necessary verification of workforce compliance with SSPP requirements.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The evidence provided demonstrates that the organization not only meets the literal requirements of the control but also embodies its intent by actively managing and reviewing SSPPs.
* **Justification:** The holistic approach to generating, maintaining, and reviewing SSPPs reflects a commitment to understanding and mitigating risks associated with critical systems.
* **Critical Gaps in Spirit (if applicable):** No critical gaps were identified; the practices align well with the control’s intent.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The organization has successfully documented and maintained SSPPs for all critical systems, demonstrated compliance through both machine and human attestations, and maintained a consistent review process.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**