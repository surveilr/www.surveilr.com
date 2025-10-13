---
title: "Audit Prompt: Employee and Contractor Training Policy"
weight: 1
description: "Establishes mandatory training and awareness programs for employees and contractors to enhance security knowledge and compliance within the organization."
publishDate: "2025-10-11"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-SAT-0002"
control-question: "Does the organization provide all employees and contractors appropriate awareness education and training that is relevant for their job function?"
fiiId: "FII-SCF-SAT-0002"
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
  * **Control's Stated Purpose/Intent:** "The organization provides all employees and contractors appropriate awareness education and training that is relevant for their job function."
     - Control Code: FII-SCF-SAT-0002
     - Control Question: Does the organization provide all employees and contractors appropriate awareness education and training that is relevant for their job function?
     - Internal ID (Foreign Integration Identifier as FII): FII-SCF-SAT-0002
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to ensure that all employees and contractors receive appropriate awareness education and training relevant to their job functions. This is essential not only for individual performance but also for the overall security posture of the organization. Proper training enhances awareness of security risks and compliance requirements, fostering a culture of security and responsibility. The organization is committed to providing necessary training and awareness programs for all employees and contractors. This commitment ensures that all personnel are equipped with the knowledge and skills required to perform their roles effectively and securely."
  * **Provided Evidence for Audit:** 
    "Training attendance records for all employees for the past year, automated completion reports from the Learning Management System (LMS) indicating 100% completion of role-specific training within 30 days of hire, and signed policy acknowledgment forms from all employees."

**Requirements for Your Audit Report  (Structured format):**

# Official Audit Report: ISO 27001 - FII-SCF-SAT-0002

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., ISO Auditor]
**Control Code:** FII-SCF-SAT-0002
**Control Question:** Does the organization provide all employees and contractors appropriate awareness education and training that is relevant for their job function?
**Internal ID (FII):** FII-SCF-SAT-0002
**Control's Stated Purpose/Intent:** The organization provides all employees and contractors appropriate awareness education and training that is relevant for their job function.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** 100% of employees must complete role-specific training within 30 days of hire.
    * **Provided Evidence:** Automated completion reports from the Learning Management System (LMS) indicating 100% completion.
    * **Surveilr Method (as described/expected):** Utilized automated systems to track training completion through the LMS.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM TrainingRecords WHERE CompletionDate <= '30 days post-hire';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The LMS reports indicate that all employees completed their training within the required timeframe, demonstrating adherence to the control requirement.

* **Control Requirement/Expected Evidence:** Training attendance records must be signed off by supervisors.
    * **Provided Evidence:** Training attendance records for all employees with supervisor signatures.
    * **Surveilr Method (as described/expected):** Evidence collected from LMS and stored in Surveilr.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM AttendanceRecords WHERE SupervisorSignature IS NOT NULL;
    * **Compliance Status:** COMPLIANT
    * **Justification:** All training sessions have corresponding attendance records signed by supervisors, meeting the evidence requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Acknowledgment of understanding and compliance with the training policy.
    * **Provided Evidence:** Signed policy acknowledgment forms from all employees.
    * **Human Action Involved (as per control/standard):** Employees signed off on their understanding of the training policy.
    * **Surveilr Recording/Tracking:** Signed forms uploaded to Surveilr for record-keeping.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The presence of signed acknowledgment forms indicates that all employees are aware of and comply with the training requirements.

## 3. Overall Alignment with Control's Intent  Spirit

* **Assessment:** The evidence provided demonstrates that the organization meets the underlying intent of ensuring all employees receive necessary training relevant to their job functions.
* **Justification:** The compliance metrics indicate a proactive approach to training, aligning with the spirit of the control to enhance security awareness and responsibility.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** All evidence assessed met the requirements of the control, showing that the organization not only complied with the literal requirements but also upheld the intent of fostering a culture of security awareness.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** N/A
* **Specific Non-Compliant Evidence Required Correction:** N/A
* **Required Human Action Steps:** N/A
* **Next Steps for Re-Audit:** N/A

**[END OF GENERATED PROMPT CONTENT]**