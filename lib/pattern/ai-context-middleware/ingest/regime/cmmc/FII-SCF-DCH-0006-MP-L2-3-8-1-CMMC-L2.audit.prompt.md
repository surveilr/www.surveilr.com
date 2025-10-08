---
title: "Audit Prompt: Media Control and Secure Storage Policy"
weight: 1
description: "Establishes secure protocols for the physical control and storage of digital and non-digital media to comply with CMMC requirements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "MP.L2-3.8.1"
control-question: "Does the organization: 
 ▪ Physically control and securely store digital and non-digital media within controlled areas using organization-defined security measures; and
 ▪ Protect system media until the media are destroyed or sanitized using approved equipment, techniques and procedures?"
fiiId: "FII-SCF-DCH-0006"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
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
  * **Control's Stated Purpose/Intent:** "The organization shall physically control and securely store digital and non-digital media within controlled areas. It shall implement approved equipment, techniques, and procedures to protect system media until it is destroyed or sanitized, thereby ensuring compliance with CMMC control MP.L2-3.8.1."
  * **Control Code:** MP.L2-3.8.1
  * **Control Question:** "Does the organization: Physically control and securely store digital and non-digital media within controlled areas using organization-defined security measures; and Protect system media until the media are destroyed or sanitized using approved equipment, techniques and procedures?"
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-DCH-0006
  * **Policy/Process Description (for context on intent and expected evidence):**
    "In alignment with the Cybersecurity Maturity Model Certification (CMMC) requirements, this policy outlines the controls necessary for the physical control and secure storage of digital and non-digital media. It ensures that all media is adequately protected until destruction or sanitization using organization-defined security measures. This policy aims to enhance data classification and handling practices across the organization."
  * **Provided Evidence for Audit:** "1. Physical control and secure storage of media: OSquery results showing access logs for digital media storage locations; inspection reports from security personnel documenting physical inspections of storage areas. 2. Protection of media until destruction or sanitization: API logs showing media handling activities and checklists completed by staff for media sanitization and destruction."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - MP.L2-3.8.1

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** MP.L2-3.8.1
**Control Question:** Does the organization: Physically control and securely store digital and non-digital media within controlled areas using organization-defined security measures; and Protect system media until the media are destroyed or sanitized using approved equipment, techniques and procedures?
**Internal ID (FII):** FII-SCF-DCH-0006
**Control's Stated Purpose/Intent:** The organization shall physically control and securely store digital and non-digital media within controlled areas. It shall implement approved equipment, techniques, and procedures to protect system media until it is destroyed or sanitized, thereby ensuring compliance with CMMC control MP.L2-3.8.1.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Physical control and secure storage of media.
    * **Provided Evidence:** OSquery results showing access logs for digital media storage locations; inspection reports from security personnel documenting physical inspections of storage areas.
    * **Surveilr Method (as described/expected):** Utilized OSquery for monitoring storage locations and access logs for digital media; automated alerts for unauthorized access attempts.
    * **Conceptual/Actual SQL Query Context:** SQL query to verify access logs against defined security measures for media storage.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided evidence from OSquery and inspection reports confirms that digital media is being physically controlled and securely stored in compliance with the control requirements.

* **Control Requirement/Expected Evidence:** Protection of media until destruction or sanitization.
    * **Provided Evidence:** API logs showing media handling activities and checklists completed by staff for media sanitization and destruction.
    * **Surveilr Method (as described/expected):** API integrations with security hardware that tracks access and modifications to media.
    * **Conceptual/Actual SQL Query Context:** SQL query to verify media handling logs against sanitization checklists.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The API logs and completed checklists demonstrate that proper equipment and procedures are in place for the protection of media until its destruction or sanitization.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Physical inspections of storage areas.
    * **Provided Evidence:** Inspection reports from security personnel logging findings.
    * **Human Action Involved (as per control/standard):** Security personnel conducted and documented physical inspections of storage areas.
    * **Surveilr Recording/Tracking:** Surveilr recorded the act of inspection and submitted reports.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The inspection reports provide valid human attestation confirming the physical control and secure storage of media as required.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence collectively demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** The combination of machine attestable evidence and human attestation validates that both the physical control and protection of media are effectively implemented.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** All elements of the control were thoroughly assessed against the provided evidence, and there were no compliance gaps identified.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * N/A
* **Specific Non-Compliant Evidence Required Correction:**
    * N/A
* **Required Human Action Steps:**
    * N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**