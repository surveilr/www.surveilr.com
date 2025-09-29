---
title: "Audit Prompt: External Data Handling Security Policy"
weight: 1
description: "Establishes governance to ensure secure handling of data by external parties, systems, and services in compliance with CMMC control AC.L1-3.1.20."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L1-3.1.20"
control-question: "Does the organization govern how external parties, systems and services are used to securely store, process and transmit data?"
fiiId: "FII-SCF-DCH-0013"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Data Classification & Handling"
category: ["CMMC", "Level 1", "Compliance"]
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
  * **Control's Stated Purpose/Intent:** "The organization governs how external parties, systems, and services are used to securely store, process, and transmit data."
Control Code: AC.L1-3.1.20,
Control Question: Does the organization govern how external parties, systems and services are used to securely store, process and transmit data?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-DCH-0013
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework for governing how external parties, systems, and services are utilized to securely store, process, and transmit data. This policy ensures compliance with the CMMC control AC.L1-3.1.20, which mandates that organizations implement appropriate measures to safeguard data handled by external entities. The organization will implement strict governance over external parties, systems, and services to ensure that all data is stored, processed, and transmitted securely. This includes defining acceptable use, monitoring compliance, and ensuring that all external engagements meet established security standards."
  * **Provided Evidence for Audit:** "Automated monitoring tools that log access and usage patterns of external systems are in place. API integrations collect data on transactions involving external parties, ensuring that all data transfers are encrypted and logged. Employees have completed a compliance checklist confirming understanding of external data handling procedures, which has been submitted to the Compliance Officer for review. Signed compliance checklists are stored in Surveilr under the 'Compliance Documentation' section."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L1-3.1.20

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L1-3.1.20
**Control Question:** Does the organization govern how external parties, systems and services are used to securely store, process and transmit data?
**Internal ID (FII):** FII-SCF-DCH-0013
**Control's Stated Purpose/Intent:** The organization governs how external parties, systems, and services are used to securely store, process, and transmit data.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must govern how external parties, systems, and services are used to securely store, process, and transmit data.
    * **Provided Evidence:** Automated monitoring tools that log access and usage patterns of external systems are in place.
    * **Surveilr Method (as described/expected):** Automated monitoring tools collect logs of access and usage patterns.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM external_system_logs WHERE action = 'access' AND timestamp >= '2025-01-01';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that the organization has implemented automated monitoring tools to log access and usage patterns, fulfilling the control requirement.

* **Control Requirement/Expected Evidence:** API integrations collect data on transactions involving external parties.
    * **Provided Evidence:** API integrations ensure that all data transfers are encrypted and logged.
    * **Surveilr Method (as described/expected):** API calls collect transaction data and log encryption status.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM api_transaction_logs WHERE encryption_status = 'encrypted';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence shows that the organization uses API integrations to log transactions with external parties, confirming encryption and compliance with the control.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Employees must complete a compliance checklist confirming understanding of external data handling procedures.
    * **Provided Evidence:** Employees have completed a compliance checklist submitted to the Compliance Officer.
    * **Human Action Involved (as per control/standard):** Employees completed a compliance checklist.
    * **Surveilr Recording/Tracking:** Signed compliance checklists are stored in Surveilr under the "Compliance Documentation" section.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence confirms that employees have completed the necessary compliance checklists, fulfilling the human attestation requirement.

## 3. Overall Alignment with Control's Intent Spirit

* **Assessment:** The provided evidence demonstrates that the organization is effectively governing how external parties, systems, and services are used to securely store, process, and transmit data.
* **Justification:** The combination of automated monitoring and human attestation shows a comprehensive approach to compliance with the control's intent.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings indicate that the organization meets the requirements of control AC.L1-3.1.20 through both machine and human attestations, demonstrating effective governance over external data handling.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**