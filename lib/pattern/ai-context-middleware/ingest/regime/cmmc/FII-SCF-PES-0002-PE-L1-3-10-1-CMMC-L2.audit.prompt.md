---
title: "Audit Prompt: Access Control Policy for Facility Security"
weight: 1
description: "Establishes and maintains a current list of personnel authorized to access organizational facilities to ensure effective security control."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "PE.L1-3.10.1"
control-question: "Does the organization maintain a current list of personnel with authorized access to organizational facilities (except for those areas within the facility officially designated as publicly accessible)?"
fiiId: "FII-SCF-PES-0002"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 2", "Compliance"]
---

You're an **official auditor**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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
- **Control's Stated Purpose/Intent:** "The organization maintains a current list of personnel with authorized access to organizational facilities (except for those areas within the facility officially designated as publicly accessible)."
  - **Control Code:** PE.L1-3.10.1
  - **Control Question:** Does the organization maintain a current list of personnel with authorized access to organizational facilities (except for those areas within the facility officially designated as publicly accessible)?
  - **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-PES-0002
- **Policy/Process Description (for context on intent and expected evidence):**
  "This policy outlines the requirements for maintaining an up-to-date list of personnel with authorized access to organizational facilities, in compliance with the CMMC Physical & Environmental Security domain. The purpose of this document is to ensure that all access to facilities containing sensitive information is controlled and monitored effectively. The organization shall maintain a current list of personnel authorized to access organizational facilities. This list will be reviewed regularly to ensure accuracy and compliance with security requirements."
- **Provided Evidence for Audit:** 
  "OSquery results generated on 2025-07-01 showing authorized personnel list; signed quarterly review report dated 2025-06-30 by Facilities Manager; HR report of personnel changes for June 2025 indicating new hires and terminations."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - PE.L1-3.10.1

**Overall Audit Result: [PASS/FAIL]**  
**Date of Audit:** [Current Date, e.g., 2025-07-28]  
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]  
**Control Code:** PE.L1-3.10.1  
**Control Question:** Does the organization maintain a current list of personnel with authorized access to organizational facilities (except for those areas within the facility officially designated as publicly accessible)?  
**Internal ID (FII):** FII-SCF-PES-0002  
**Control's Stated Purpose/Intent:** The organization maintains a current list of personnel with authorized access to organizational facilities (except for those areas within the facility officially designated as publicly accessible).

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Maintain an updated record of all personnel authorized to access organizational facilities.
    * **Provided Evidence:** OSquery results generated on 2025-07-01 showing authorized personnel list.
    * **Surveilr Method (as described/expected):** OSquery was used to automatically generate the list of authorized personnel.
    * **Conceptual/Actual SQL Query Context:** SQL query executed to extract personnel data from the RSSD.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence provided meets the requirement of maintaining a current list of personnel with authorized access, as demonstrated by the OSquery results.

* **Control Requirement/Expected Evidence:** Documentation of quarterly reviews of the access list.
    * **Provided Evidence:** Signed quarterly review report dated 2025-06-30 by Facilities Manager.
    * **Surveilr Method (as described/expected):** Review report signed off by Facilities Manager stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report confirms that the access list was reviewed and updated, demonstrating adherence to the control requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Monthly report of personnel changes provided by HR.
    * **Provided Evidence:** HR report of personnel changes for June 2025 indicating new hires and terminations.
    * **Human Action Involved (as per control/standard):** HR Department must provide reports to the Facilities Manager.
    * **Surveilr Recording/Tracking:** HR report stored in Surveilr as evidence of compliance.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The HR report confirms that personnel changes are documented and communicated, fulfilling this human attestation requirement.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The evidence collectively demonstrates that the organization is effectively maintaining a current list of personnel with authorized access, aligning with both the letter and spirit of the control.
* **Justification:** The provided evidence shows proactive management of access controls, fulfilling the intent to protect sensitive areas from unauthorized access.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS 
* **Comprehensive Rationale:** All aspects of the control were met with compliant evidence, demonstrating that the necessary policies and procedures are effectively implemented and maintained.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** 
    * [No missing evidence was identified; hence this section is not applicable.]
* **Specific Non-Compliant Evidence Required Correction:** 
    * [No non-compliant evidence was identified; hence this section is not applicable.]
* **Required Human Action Steps:** 
    * [No actions are required; hence this section is not applicable.]
* **Next Steps for Re-Audit:** 
    * [Not applicable; the audit result is PASS.]

**[END OF GENERATED PROMPT CONTENT]**