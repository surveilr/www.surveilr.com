---
title: "Audit Prompt: Pattern-Hiding Display Security Policy"
weight: 1
description: "Implement pattern-hiding displays to protect sensitive information during session locks and ensure compliance with security standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L2-3.1.10"
control-question: "Does the organization implement pattern-hiding displays to conceal information previously visible on the display during the session lock?"
fiiId: "FII-SCF-IAC-0024.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You're an **official auditor (e.g., auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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
- **Control's Stated Purpose/Intent:** "To implement pattern-hiding displays that conceal information previously visible on the display during the session lock."
  - Control Code: AC.L2-3.1.10
  - Control Question: Does the organization implement pattern-hiding displays to conceal information previously visible on the display during the session lock?
  - Internal ID (Foreign Integration Identifier as FII): FII-SCF-IAC-0024.1
- **Policy/Process Description (for context on intent and expected evidence):**
  "Pattern-hiding displays are essential security mechanisms that obscure sensitive information on screens during session locks, preventing unauthorized access to data. This control is vital in safeguarding organizational assets and ensuring compliance with security standards. By implementing pattern-hiding displays, we mitigate risks associated with data exposure when devices are unattended. Our organization is committed to implementing and maintaining pattern-hiding displays on all applicable systems to conceal information during session locks. This policy aims to enhance the security of sensitive information and ensure compliance with regulatory requirements."
- **Provided Evidence for Audit:** 
  "1. Verified configuration settings of display systems indicating that pattern-hiding functionality is active. 
   2. Signed quarterly review report by the IT manager confirming compliance with display requirements, documenting no anomalies or corrective actions taken."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L2-3.1.10

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L2-3.1.10
**Control Question:** Does the organization implement pattern-hiding displays to conceal information previously visible on the display during the session lock?
**Internal ID (FII):** FII-SCF-IAC-0024.1
**Control's Stated Purpose/Intent:** To implement pattern-hiding displays that conceal information previously visible on the display during the session lock.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization mandates the use of pattern-hiding displays to ensure sensitive information is not visible when a session is locked.
    * **Provided Evidence:** Verified configuration settings of display systems indicating that pattern-hiding functionality is active.
    * **Surveilr Method (as described/expected):** Surveilr utilized OSquery to verify configuration settings of display systems.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM display_settings WHERE pattern_hiding_enabled = 'true';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence provided confirms that the pattern-hiding display functionality is active, meeting the control requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Quarterly review report signed by the IT manager confirming compliance with display requirements.
    * **Provided Evidence:** Signed quarterly review report by the IT manager confirming compliance with display requirements, documenting no anomalies or corrective actions taken.
    * **Human Action Involved (as per control/standard):** The IT manager manually verifies and certifies that the compliance controls for pattern-hiding displays are in place.
    * **Surveilr Recording/Tracking:** Surveilr recorded the act of attestation by storing the signed review report.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report confirms that the IT manager has verified compliance with the control, fulfilling the requirement for human attestation.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** The active pattern-hiding display functionality and the signed confirmation from the IT manager collectively support the control's goals of preventing unauthorized data exposure during session locks.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence substantiates that the organization has implemented pattern-hiding displays and confirmed compliance through both machine and human attestation, aligning with the control requirements.

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