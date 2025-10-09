---
title: "Audit Prompt: Incident Response Training and Compliance Policy"
weight: 1
description: "Establishes comprehensive training protocols to ensure personnel are prepared to effectively respond to security incidents and maintain compliance with regulatory requirements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "IR.L2-3.6.1"
control-question: "Does the organization train personnel in their incident response roles and responsibilities?"
fiiId: "FII-SCF-IRO-0005"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Incident Response"
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
- **Control's Stated Purpose/Intent:** "The organization trains personnel in their incident response roles and responsibilities to ensure effective management and mitigation of security incidents."
  - Control Code: IR.L2-3.6.1
  - Control Question: Does the organization train personnel in their incident response roles and responsibilities?
  - Internal ID (Foreign Integration Identifier as FII): FII-SCF-IRO-0005
- **Policy/Process Description (for context on intent and expected evidence):**
  "Training personnel in their incident response roles and responsibilities is critical to ensuring the organization can effectively manage and mitigate security incidents. Well-trained staff can respond swiftly to threats, minimize damage, and maintain the trust of stakeholders. Furthermore, consistent and relevant training fosters a culture of security awareness and preparedness, which is essential for protecting sensitive information and maintaining compliance with regulatory requirements."
- **Provided Evidence for Audit:** "Evidence includes LMS tracking reports indicating that all incident response personnel completed initial training within 30 days of assignment and participated in refresher training sessions within the last six months. Signed training completion logs are also available, showing documented attendance for training sessions."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - IR.L2-3.6.1

**Overall Audit Result: [PASS]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** IR.L2-3.6.1
**Control Question:** Does the organization train personnel in their incident response roles and responsibilities?
**Internal ID (FII):** FII-SCF-IRO-0005
**Control's Stated Purpose/Intent:** The organization trains personnel in their incident response roles and responsibilities to ensure effective management and mitigation of security incidents.

## 1. Executive Summary

The audit determined that the organization successfully meets the requirements of Control IR.L2-3.6.1. All incident response personnel have completed the necessary training within the specified timeframes, as evidenced by automated tracking from the Learning Management System (LMS) and documented signed training completion logs. Therefore, the overall audit result is a "PASS."

## 2. Evidence Assessment Against Control Requirements

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** All personnel in incident response roles must complete initial training within 30 days of assignment and participate in refresher training at least once every six months.
    * **Provided Evidence:** LMS tracking reports indicating compliance with training requirements.
    * **Surveilr Method (as described/expected):** Integration with the LMS for tracking training completion.
    * **Conceptual/Actual SQL Query Context:** SQL queries used to extract training completion data from the RSSD.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that all incident response personnel completed their training as required, satisfying the control's requirements.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Personnel must sign a training completion log after each training session.
    * **Provided Evidence:** Signed training completion logs uploaded to Surveilr, including metadata.
    * **Human Action Involved (as per control/standard):** Personnel signed logs after each training session.
    * **Surveilr Recording/Tracking:** Evidence of signed logs stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed logs provide adequate human attestation of training completion, supporting compliance with the control.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization effectively trains personnel in their incident response roles, fulfilling both the letter and the spirit of the control.
* **Justification:** The comprehensive training program aligns with the intent of ensuring personnel are prepared to manage security incidents effectively.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings indicate full compliance with the control requirements. All critical aspects of training have been met, with both machine and human attestations confirming that personnel are adequately trained in their incident response roles.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A - All required evidence present]
* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A - No non-compliant evidence identified]
* **Required Human Action Steps:**
    * [N/A - No action steps required]
* **Next Steps for Re-Audit:** [N/A - No re-audit necessary]