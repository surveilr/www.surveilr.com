---
title: "Audit Prompt: Third-Party Cybersecurity Compliance Policy"
weight: 1
description: "Establishes cybersecurity and data privacy requirements in contracts with subcontractors and suppliers to protect sensitive information and ensure compliance."
publishDate: "2025-10-06"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L1-3.1.1"
control-question: "Does the organization ensure cybersecurity & data privacy requirements are included in contracts that flow-down to applicable sub-contractors and suppliers?"
fiiId: "FII-SCF-TPM-0005.2"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Third-Party Management"
category: ["CMMC", "Level 1", "Compliance"]
---

You're an **official auditor (e.g., CMMC Auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

**Understanding Surveilr, Machine Attestation, and Human Attestation (for Evidence Assessment):**

- **Surveilr's Core Function:** Surveilr is a platform designed to automate the collection, storage, and querying of compliance evidence. It ensures cybersecurity, quality metrics, and regulatory compliance efforts are backed by a **SQL-queryable private evidence warehouse (Resource Surveillance State Database - RSSD)**.
- **Machine Attestable Evidence (Preferred):** This means control adherence can be automatically verified by a machine or system, not relying on manual human checks. Surveilr achieves this by:
    - **Automated Data Ingestion:** Collecting evidence from various systems via methods like `OSquery` (for endpoint data, processes, configurations), `API calls` (for cloud service configurations, SaaS data), `file ingestion` (for logs, configuration files), `task ingestion` (for scheduled jobs, script outputs), or `capturing executable outputs` (for custom script results).
    - **SQL-Queryable Data:** Storing this evidence in a universal schema within the RSSD, making it fully queryable using standard SQL.
    - **Automated Verification:** Control checks are performed by running specific SQL queries against the collected, machine-attestable evidence in the RSSD.
- **Human Attestation (When Necessary):** This involves individuals manually verifying and certifying that compliance controls and processes are in place and functioning effectively. It relies on human judgment, review, or direct declaration.
    - **Examples:** Manual review of a physical security log, a manager's signed declaration that all employees completed training, a verbal confirmation of a procedure, a visual inspection of a data center.
    - **Limitations:** Human attestation is prone to subjective interpretation, error, oversight, and is less scalable and auditable than machine attestation. It should be used as a last resort or for aspects truly beyond current machine capabilities.
    - **Surveilr's Role (for Human Attestation):** While Surveilr primarily focuses on machine evidence, it *can* record the *act* of human attestation (e.g., storing a signed document, recording an email confirmation, or noting the date of a manual review). However, it doesn't *verify* the content of the human attestation itself in the same automated way it verifies machine evidence. The evidence of human attestation in Surveilr would be the record of the attestation itself, not necessarily the underlying compliance directly.
- **Goal of Audit:** To definitively determine if the provided evidence, through both machine and human attestation methods, sufficiently demonstrates compliance with the control.

**Audit Context:**

- **Audit Standard/Framework:** CMMC
  - **Control's Stated Purpose/Intent:** "The organization ensures cybersecurity & data privacy requirements are included in contracts that flow-down to applicable sub-contractors and suppliers."
  - Control Code: AC.L1-3.1.1
  - Control Question: Does the organization ensure cybersecurity & data privacy requirements are included in contracts that flow-down to applicable sub-contractors and suppliers?
  - Internal ID (Foreign Integration Identifier as FII): FII-SCF-TPM-0005.2
- **Policy/Process Description (for context on intent and expected evidence):**
  "This policy establishes the framework for ensuring that cybersecurity and data privacy requirements are systematically included in all contracts with subcontractors and suppliers. It is essential for safeguarding sensitive information, especially electronic Protected Health Information (ePHI), and maintaining compliance with relevant regulations. By enforcing these requirements, the organization enhances its cybersecurity posture and promotes trust with stakeholders."
- **Provided Evidence for Audit:** "The organization utilizes contract management software to track the inclusion of cybersecurity clauses, scheduling automated alerts for contract reviews, and implementing a digital signature system to validate contract agreements. Additionally, the Contract Manager maintains a checklist of required cybersecurity clauses for each contract, and there are signed acknowledgments of compliance stored securely in Surveilr."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: CMMC - AC.L1-3.1.1

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [CMMC Auditor]
**Control Code:** AC.L1-3.1.1
**Control Question:** Does the organization ensure cybersecurity & data privacy requirements are included in contracts that flow-down to applicable sub-contractors and suppliers?
**Internal ID (FII):** FII-SCF-TPM-0005.2
**Control's Stated Purpose/Intent:** The organization ensures cybersecurity & data privacy requirements are included in contracts that flow-down to applicable sub-contractors and suppliers.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must ensure cybersecurity and data privacy requirements are included in contracts with subcontractors and suppliers.
    * **Provided Evidence:** The organization utilizes contract management software to track the inclusion of cybersecurity clauses.
    * **Surveilr Method (as described/expected):** Automated tracking through contract management software.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM contracts WHERE cybersecurity_clauses IN (true);
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that the organization is actively tracking the inclusion of cybersecurity clauses in contracts, fulfilling the control requirement.

* **Control Requirement/Expected Evidence:** Timeliness of contract reviews.
    * **Provided Evidence:** Automated alerts are scheduled to notify the Compliance Officer of contract reviews.
    * **Surveilr Method (as described/expected):** Automated alert scheduling.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM contract_reviews WHERE alert_status = 'pending';
    * **Compliance Status:** COMPLIANT
    * **Justification:** Evidence shows that alerts are in place for timely contract reviews, indicating compliance with established review timelines.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Signed acknowledgment of compliance from relevant parties.
    * **Provided Evidence:** Signed acknowledgments of compliance stored securely in Surveilr.
    * **Human Action Involved (as per control/standard):** The Contract Manager must compile a checklist of required cybersecurity clauses for each contract.
    * **Surveilr Recording/Tracking:** Signed documents stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The presence of signed acknowledgments indicates that relevant parties have acknowledged compliance with cybersecurity requirements.

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** The provided evidence demonstrates that the organization is actively ensuring cybersecurity and data privacy requirements are included in contracts, aligning with the control's intent.
* **Justification:** The evidence reflects proactive measures taken to safeguard sensitive information and maintain compliance, fulfilling both the letter and spirit of the control.

## 4. Audit Conclusion and  Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided demonstrates adherence to the control requirements, fulfilling the intent of ensuring cybersecurity and data privacy in contracts with subcontractors and suppliers.

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