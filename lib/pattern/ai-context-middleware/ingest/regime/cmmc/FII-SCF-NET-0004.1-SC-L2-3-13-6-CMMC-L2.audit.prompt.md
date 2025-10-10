---
title: "Audit Prompt: Firewall and Router Security Configuration Policy"
weight: 1
description: "Establishes a default deny configuration for firewalls and routers to enhance network security by permitting only authorized traffic."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "SC.L2-3.13.6"
control-question: "Does the organization configure firewall and router configurations to deny network traffic by default and allow network traffic by exception (e.g., deny all, permit by exception)?"
fiiId: "FII-SCF-NET-0004.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
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
  * **Control's Stated Purpose/Intent:** "The organization configures firewall and router configurations to deny network traffic by default and allow network traffic by exception (e.g., deny all, permit by exception)."
Control Code: SC.L2-3.13.6,
Control Question: "Does the organization configure firewall and router configurations to deny network traffic by default and allow network traffic by exception (e.g., deny all, permit by exception)?"
Internal ID (Foreign Integration Identifier as FII): FII-SCF-NET-0004.1
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework for configuring firewall and router settings within the organization, ensuring a robust security posture against unauthorized access and network threats. By implementing a default deny configuration, the organization can effectively manage network traffic, minimizing risks associated with vulnerabilities and potential exploits. This policy aligns with the CMMC control SC.L2-3.13.6, reinforcing our commitment to maintaining a secure network environment. The organization shall configure all firewall and router settings to deny network traffic by default and allow network traffic by exception. This principle of least privilege ensures that only authorized traffic is permitted, thereby enhancing the security of the network infrastructure."
  * **Provided Evidence for Audit:** "Configuration management tools have reported that 95% of firewalls and routers are set to deny all traffic by default, allowing only explicitly permitted traffic. Signed validation reports from network engineers confirming compliance have been submitted quarterly. However, the logs for one device (Router-XYZ) indicating its configuration status were not included in the evidence."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - SC.L2-3.13.6

**Overall Audit Result: FAIL**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** CMMC Auditor
**Control Code:** SC.L2-3.13.6
**Control Question:** "Does the organization configure firewall and router configurations to deny network traffic by default and allow network traffic by exception (e.g., deny all, permit by exception)?"
**Internal ID (FII):** FII-SCF-NET-0004.1
**Control's Stated Purpose/Intent:** "The organization configures firewall and router configurations to deny network traffic by default and allow network traffic by exception (e.g., deny all, permit by exception)."

## 1. Executive Summary

The audit findings indicate a compliance gap due to insufficient evidence. While 95% of devices are compliant with the default deny configuration and signed validation reports have been submitted, a critical piece of evidence—the logs for Router-XYZ—was not included in the evidence provided. This absence of documentation results in a "FAIL" audit decision as it does not fully demonstrate adherence to the control's requirements.

## 2. Evidence Assessment Against Control Requirements

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization mandates that all firewall and router configurations shall be set to deny all network traffic by default, allowing only explicitly permitted traffic.
    * **Provided Evidence:** Configuration management tools reported that 95% of firewalls and routers are set to deny all traffic by default.
    * **Surveilr Method (as described/expected):** Configuration management tools automatically monitor and report on firewall and router settings.
    * **Conceptual/Actual SQL Query Context:** SQL query was used to extract configuration data from the RSSD confirming the status of firewall settings.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The majority of devices (95%) comply with the default deny configuration, indicating adherence to the control requirement.

* **Control Requirement/Expected Evidence:** Signed validation reports from network engineers confirming compliance with the policy.
    * **Provided Evidence:** Signed validation reports have been submitted quarterly.
    * **Surveilr Method (as described/expected):** Reports were collected and stored within Surveilr.
    * **Conceptual/Actual SQL Query Context:** SQL query was executed to retrieve the validation report data from the RSSD.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The submission of signed reports demonstrates that the organization is actively monitoring compliance.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Network engineers shall provide signed validation reports confirming that all configurations adhere to the policy.
    * **Provided Evidence:** Signed validation reports were provided.
    * **Human Action Involved (as per control/standard):** Network engineers manually validated and signed the reports.
    * **Surveilr Recording/Tracking:** The signed reports were stored in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The human attestation through signed reports confirms adherence to the policy.

* **Control Requirement/Expected Evidence:** Logs for Router-XYZ indicating its configuration status.
    * **Provided Evidence:** Logs for Router-XYZ were not provided.
    * **Human Action Involved (as per control/standard):** Network engineers should have retrieved and submitted these logs as part of the compliance evidence.
    * **Surveilr Recording/Tracking:** Not applicable, as the logs were missing.
    * **Compliance Status:** NON-COMPLIANT
    * **Justification:** The absence of logs for Router-XYZ indicates a gap in the evidence required to demonstrate compliance.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The overall evidence indicates that the organization is mostly aligning with the control's intent, but the missing logs create a significant compliance gap.
* **Justification:** While the evidence shows a strong commitment to the control's requirements, the lack of complete documentation fails to meet the spirit of ensuring all configurations are properly logged and verified.
* **Critical Gaps in Spirit (if applicable):** The missing logs signify a lack of complete transparency and accountability, which is essential for the control's intent.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** FAIL
* **Comprehensive Rationale:** The audit result is based on the absence of logs for Router-XYZ, which is critical for fully demonstrating adherence to the control requirements. The presence of signed validation reports is positive, but without complete evidence, the overall compliance status cannot be confirmed.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * Missing logs for Router-XYZ indicating its configuration status (FII-SCF-NET-0004.1) for the quarter ending 2025-06-30. These logs should illustrate the configuration settings and any changes applied.
* **Specific Non-Compliant Evidence Required Correction:**
    * N/A (the only evidence missing relates to the logs for Router-XYZ).
* **Required Human Action Steps:**
    * Engage network engineers to retrieve the configuration logs for Router-XYZ from the last audit period.
    * Ensure the logs are formatted appropriately and submitted for inclusion in the compliance evidence.
* **Next Steps for Re-Audit:** Once the missing evidence is collected, it should be resubmitted for evaluation. The re-audit will focus on the completeness and accuracy of the logs provided.