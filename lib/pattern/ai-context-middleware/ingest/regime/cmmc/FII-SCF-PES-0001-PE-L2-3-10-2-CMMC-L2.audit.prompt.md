---
title: "Audit Prompt: Physical and Environmental Security Policy"
weight: 1
description: "Establishes and enforces controls to protect sensitive information and assets from unauthorized access and environmental hazards."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "PE.L2-3.10.2"
control-question: "Does the organization facilitate the operation of physical and environmental protection controls?"
fiiId: "FII-SCF-PES-0001"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Physical & Environmental Security"
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
- **Control's Stated Purpose/Intent:** "Facilitate the operation of physical and environmental protection controls."
  - **Control Code:** PE.L2-3.10.2
  - **Control Question:** Does the organization facilitate the operation of physical and environmental protection controls?
  - **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-PES-0001
- **Policy/Process Description (for context on intent and expected evidence):**
  "The purpose of this policy is to establish and enforce physical and environmental protection controls as required by CMMC control PE.L2-3.10.2. This control mandates that organizations facilitate the operation of such controls to safeguard sensitive information and assets from unauthorized access and environmental hazards. As organizations increasingly rely on technology and third-party services, it is essential to create a structured approach for maintaining compliance while ensuring the security of physical environments."
- **Provided Evidence for Audit:** "Automated logging systems track access to secure areas. Environmental monitoring systems provide real-time alerts for temperature and humidity. Surveillance cameras log access events automatically. Quarterly physical security audits document findings in Surveilr. Access logs for physical entry points are reviewed monthly. Incident reports regarding breaches or environmental concerns are submitted through Surveilr."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - PE.L2-3.10.2

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** PE.L2-3.10.2
**Control Question:** Does the organization facilitate the operation of physical and environmental protection controls?
**Internal ID (FII):** FII-SCF-PES-0001
**Control's Stated Purpose/Intent:** Facilitate the operation of physical and environmental protection controls.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Facilitate the operation of physical and environmental protection controls through automated logging systems.
    * **Provided Evidence:** Automated logging systems track access to secure areas.
    * **Surveilr Method (as described/expected):** Automated logging via system integration.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_logs WHERE location = 'secure_area';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The automated logging system provides accurate tracking of access events, meeting the control's requirement.

* **Control Requirement/Expected Evidence:** Environmental monitoring systems that provide real-time alerts.
    * **Provided Evidence:** Environmental monitoring systems provide real-time alerts for temperature and humidity.
    * **Surveilr Method (as described/expected):** Integration with environmental monitoring sensors.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM environmental_monitoring WHERE alert_triggered = true;
    * **Compliance Status:** COMPLIANT
    * **Justification:** The environmental monitoring system effectively tracks and alerts for any deviations, fulfilling the control's requirements.

* **Control Requirement/Expected Evidence:** Surveillance camera logging access events.
    * **Provided Evidence:** Surveillance cameras log access events automatically.
    * **Surveilr Method (as described/expected):** Video surveillance system logs integrated with Surveilr.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM camera_logs WHERE event_type = 'access';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The surveillance camera system provides reliable access logging, which is crucial for physical security compliance.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Conduct quarterly physical security audits.
    * **Provided Evidence:** Quarterly physical security audits document findings in Surveilr.
    * **Human Action Involved (as per control/standard):** Auditors conduct physical inspections and record findings.
    * **Surveilr Recording/Tracking:** Audit findings are stored in the Surveilr system.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The documentation of quarterly audits meets the requirement for human attestation of physical security.

* **Control Requirement/Expected Evidence:** Maintain access logs for physical entry points.
    * **Provided Evidence:** Access logs for physical entry points are reviewed monthly.
    * **Human Action Involved (as per control/standard):** Monthly review of logs by security personnel.
    * **Surveilr Recording/Tracking:** Access logs are recorded in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** Regular reviews of access logs demonstrate compliance with the control's human attestation requirement.

* **Control Requirement/Expected Evidence:** Collect incident reports from employees regarding breaches or environmental concerns.
    * **Provided Evidence:** Incident reports regarding breaches or environmental concerns are submitted through Surveilr.
    * **Human Action Involved (as per control/standard):** Employees report incidents and document findings.
    * **Surveilr Recording/Tracking:** Incident reports are stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The process for incident reporting aligns with the control's requirements.

## 3. Overall Alignment with Control's Intent and Spirit

* **Assessment:** Based on the totality of the provided evidence, it genuinely demonstrates that the control's underlying purpose and intent are being met in practice.
* **Justification:** The evidence provided through automated systems and human attestation illustrates a robust framework for maintaining physical and environmental protection controls.
* **Critical Gaps in Spirit (if applicable):** N/A

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit findings indicate that all aspects of the control have been met through both machine and human evidence, demonstrating a commitment to the security and integrity of physical environments.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * N/A (as the audit result is PASS)
* **Specific Non-Compliant Evidence Required Correction:**
    * N/A (as the audit result is PASS)
* **Required Human Action Steps:**
    * N/A (as the audit result is PASS)
* **Next Steps for Re-Audit:** 
    * N/A (as the audit result is PASS)

**[END OF GENERATED PROMPT CONTENT]**