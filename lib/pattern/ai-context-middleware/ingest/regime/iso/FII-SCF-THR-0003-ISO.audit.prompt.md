---
title: "Audit Prompt: Threat Management and Intelligence Integration Policy"
weight: 1
description: "Enhances threat management strategies by integrating threat intelligence to improve organizational defenses and maintain situational awareness of emerging cyber threats."
publishDate: "2025-10-11"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-THR-0003"
control-question: "Does the organization maintain situational awareness of vulnerabilities and evolving threats by leveraging the knowledge of attacker tactics, techniques and procedures to facilitate the implementation of preventative and compensating controls?"
fiiId: "FII-SCF-THR-0003"
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
  * **Control's Stated Purpose/Intent:** "The organization maintains situational awareness of vulnerabilities and evolving threats by leveraging the knowledge of attacker tactics, techniques and procedures to facilitate the implementation of preventative and compensating controls."
Control Code: FII-SCF-THR-0003,
Control Question: Does the organization maintain situational awareness of vulnerabilities and evolving threats by leveraging the knowledge of attacker tactics, techniques and procedures to facilitate the implementation of preventative and compensating controls?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-THR-0003
  * **Policy/Process Description (for context on intent and expected evidence):**
    "In today's rapidly evolving digital landscape, maintaining situational awareness of vulnerabilities and emerging threats is paramount to safeguarding organizational assets. The dynamic nature of cyber threats necessitates proactive monitoring and analysis to protect sensitive information and ensure business continuity. Organizations must remain vigilant and informed about the tactics, techniques, and procedures employed by potential adversaries to effectively defend against these threats. Our organization is committed to leveraging comprehensive knowledge of attacker tactics, techniques, and procedures to enhance our threat management strategies. By integrating threat intelligence into our operational processes, we aim to bolster our defenses, minimize risk, and ensure a resilient security posture. This commitment is essential for preventing and mitigating potential security incidents."
  * **Provided Evidence for Audit:** "Evidence includes integration of threat intelligence feeds into the SIEM system, alerts configured for suspicious activities, and a signed report from the Threat Intelligence Analyst certifying the monthly review of threat intelligence subscriptions. Audit logs indicate successful configuration of alerts on a weekly basis."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: ISO 27001 - FII-SCF-THR-0003

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., ISO Auditor]
**Control Code:** [FII-SCF-THR-0003]
**Control Question:** [Does the organization maintain situational awareness of vulnerabilities and evolving threats by leveraging the knowledge of attacker tactics, techniques and procedures to facilitate the implementation of preventative and compensating controls?]
**Internal ID (FII):** [FII-SCF-THR-0003]
**Control's Stated Purpose/Intent:** [The organization maintains situational awareness of vulnerabilities and evolving threats by leveraging the knowledge of attacker tactics, techniques and procedures to facilitate the implementation of preventative and compensating controls.]

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The timely integration of threat intelligence feeds into SIEM systems (within 48 hours of acquisition).
    * **Provided Evidence:** The evidence indicates integration of threat intelligence feeds into the SIEM system.
    * **Surveilr Method (as described/expected):** Automation through API calls to ingest threat intelligence data into the SIEM.
    * **Conceptual/Actual SQL Query Context:** SQL query verifying the timestamp of threat intelligence feed integration.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence shows timely integration within the set timeframe.

* **Control Requirement/Expected Evidence:** Monthly reports from Threat Intelligence Analysts confirming review completion and insights derived.
    * **Provided Evidence:** Signed report from the Threat Intelligence Analyst certifying review of threat intelligence subscriptions.
    * **Surveilr Method (as described/expected):** Document storage in Surveilr for human attestation.
    * **Conceptual/Actual SQL Query Context:** SQL query to access and verify the existence of the signed report.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The signed report confirms compliance with the monthly review requirement.

* **Control Requirement/Expected Evidence:** Audit logs indicating successful configuration of alerts on a weekly basis.
    * **Provided Evidence:** Audit logs confirming alert configurations.
    * **Surveilr Method (as described/expected):** Automated logging by SIEM system.
    * **Conceptual/Actual SQL Query Context:** SQL query to retrieve and confirm alert configurations.
    * **Compliance Status:** COMPLIANT
    * **Justification:** Audit logs indicate compliance with the alert configuration requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Documentation of significant findings or changes in threat landscapes by the Threat Intelligence Analyst.
    * **Provided Evidence:** No evidence was provided documenting significant findings or changes.
    * **Human Action Involved (as per control/standard):** Required documentation of significant findings.
    * **Surveilr Recording/Tracking:** N/A (No documentation provided).
    * **Compliance Status:** NON-COMPLIANT
    * **Justification:** Lack of documentation of significant findings fails to meet the requirement.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The evidence provided demonstrates compliance with several requirements; however, the absence of documentation for significant findings indicates a gap.
* **Justification:** While other aspects are compliant, the lack of human attestation documentation undermines the overall effectiveness of situational awareness.
* **Critical Gaps in Spirit (if applicable):** The absence of documented significant findings fails to reflect the proactive stance intended by the control.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** FAIL
* **Comprehensive Rationale:** Despite compliance with several machine attestable items, the failure to provide documentation of significant findings results in an overall non-compliant status.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * Missing documentation of significant findings or changes in threat landscapes from the Threat Intelligence Analyst.
    * Required format/type: Provide a signed report detailing any significant findings or changes.

* **Specific Non-Compliant Evidence Required Correction:**
    * Non-compliance due to lack of documentation for significant findings. Required corrective action: Document and provide a report of significant findings.

* **Required Human Action Steps:**
    * Engage the Threat Intelligence Analyst to prepare and submit documentation of significant findings.
    * Ensure the signed report is uploaded to Surveilr for compliance records.

* **Next Steps for Re-Audit:** Once the missing documentation is provided, submit for re-evaluation through Surveilr's audit submission process.