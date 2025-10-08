---
title: "Audit Prompt: **External Data Handling Security Policy**"
weight: 1
description: "Establishes guidelines to prevent external handling of sensitive data without verified security controls or formal processing agreements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L1-3.1.20"
control-question: "Does the organization prohibit external parties, systems and services from storing, processing and transmitting data unless authorized individuals first: 
 ▪ Verifying the implementation of required security controls; or
 ▪ Retaining a processing agreement with the entity hosting the external systems or service?"
fiiId: "FII-SCF-DCH-0013.1"
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
  * **Control's Stated Purpose/Intent:** "The organization prohibits external parties, systems and services from storing, processing and transmitting data unless authorized individuals first: Verifying the implementation of required security controls; or Retaining a processing agreement with the entity hosting the external systems or service."
Control Code: AC.L1-3.1.20,
Control Question: Does the organization prohibit external parties, systems and services from storing, processing and transmitting data unless authorized individuals first: 
 ▪ Verifying the implementation of required security controls; or
 ▪ Retaining a processing agreement with the entity hosting the external systems or service?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-DCH-0013.1
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework that ensures the security and integrity of sensitive data by prohibiting external parties, systems, and services from storing, processing, or transmitting this data unless certain security controls are verified by authorized individuals or a processing agreement is retained. This policy aligns with the CMMC control AC.L1-3.1.20 and is crucial for maintaining compliance within the Data Classification & Handling domain. It is the policy of this organization to strictly prohibit external parties, systems, and services from storing, processing, and transmitting data unless: Authorized individuals have verified the implementation of required security controls. A formal processing agreement is retained with the entity that hosts the external systems or services. This ensures that all data handling practices comply with organizational standards and regulatory requirements."
  * **Provided Evidence for Audit:** "Machine attestation evidence includes daily asset inventories collected via `OSquery` to ensure that all external systems are accounted for and validated. Human attestation evidence includes completed Security Control Verification Checklists for each external system, which are stored in a designated Surveilr folder and uploaded using the automated ingestion tool bi-weekly."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L1-3.1.20

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L1-3.1.20
**Control Question:** Does the organization prohibit external parties, systems and services from storing, processing and transmitting data unless authorized individuals first: 
 ▪ Verifying the implementation of required security controls; or
 ▪ Retaining a processing agreement with the entity hosting the external systems or service?
**Internal ID (FII):** FII-SCF-DCH-0013.1
**Control's Stated Purpose/Intent:** The organization prohibits external parties, systems and services from storing, processing and transmitting data unless authorized individuals first: Verifying the implementation of required security controls; or Retaining a processing agreement with the entity hosting the external systems or service.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The control requires that external entities do not process sensitive data without proof of verified security controls or a processing agreement.
    * **Provided Evidence:** Daily asset inventories collected via `OSquery`.
    * **Surveilr Method (as described/expected):** OSquery for endpoint data collection.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM rssd.assets WHERE external_system = 'true' AND compliance_status = 'verified';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence provided confirms that all external systems are accounted for and that security controls have been verified as required by the control.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Authorized personnel must complete a Security Control Verification Checklist for each external system.
    * **Provided Evidence:** Completed Security Control Verification Checklists stored in the Surveilr folder.
    * **Human Action Involved (as per control/standard):** Verification of security controls by authorized personnel.
    * **Surveilr Recording/Tracking:** Checklists are uploaded into Surveilr using the automated ingestion tool bi-weekly.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence confirms that the necessary human actions have occurred and are properly recorded.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** Both machine and human attestations align with the requirements set forth in the control, indicating a thorough approach to compliance.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided shows that the organization has successfully enforced the required security controls and processing agreements with regards to external parties, systems, and services.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**