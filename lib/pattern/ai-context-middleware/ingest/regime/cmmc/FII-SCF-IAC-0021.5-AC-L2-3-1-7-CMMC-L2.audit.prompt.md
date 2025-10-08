---
title: "Audit Prompt: Privileged Access Control Policy for Non-Privileged Users"
weight: 1
description: "Establishes restrictions preventing non-privileged users from executing privileged functions to enhance security and protect sensitive information."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L2-3.1.7"
control-question: "Does the organization prevent non-privileged users from executing privileged functions to include disabling, circumventing or altering implemented security safeguards / countermeasures?"
fiiId: "FII-SCF-IAC-0021.5"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
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
  * **Control's Stated Purpose/Intent:** "To prevent non-privileged users from executing privileged functions to include disabling, circumventing or altering implemented security safeguards / countermeasures."
Control Code: AC.L2-3.1.7,
Control Question: Does the organization prevent non-privileged users from executing privileged functions to include disabling, circumventing or altering implemented security safeguards / countermeasures?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-IAC-0021.5
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy aims to establish a framework for preventing non-privileged users from executing privileged functions, including disabling, circumventing, or altering security safeguards. The significance of this policy lies in maintaining the integrity and security of sensitive information and systems by ensuring that only authorized personnel have the capacity to perform actions that could compromise security. By adhering to this policy, the organization can better protect against unauthorized access and potential data breaches."
  * **Provided Evidence for Audit:** "1. Automated collection of access logs and system configurations through Surveilr to ensure that access permissions are set correctly. 2. Reports on attempted access to privileged functions generated by automated tools and ingested into Surveilr. 3. Acknowledgment forms completed by users confirming their understanding of access limitations, stored in Surveilr. 4. Logs of incidents where users report security safeguard failures, submitted to Surveilr."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L2-3.1.7

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L2-3.1.7
**Control Question:** Does the organization prevent non-privileged users from executing privileged functions to include disabling, circumventing or altering implemented security safeguards / countermeasures?
**Internal ID (FII):** FII-SCF-IAC-0021.5
**Control's Stated Purpose/Intent:** To prevent non-privileged users from executing privileged functions to include disabling, circumventing or altering implemented security safeguards / countermeasures.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Control requires that non-privileged users cannot execute privileged functions.
    * **Provided Evidence:** Automated collection of access logs and system configurations through Surveilr.
    * **Surveilr Method (as described/expected):** OSquery for endpoint data and configurations.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_logs WHERE user_role = 'non-privileged' AND action_type = 'privileged';
    * **Compliance Status:** COMPLIANT
    * **Justification:** Evidence shows that access logs are collected automatically, demonstrating compliance with the requirement that non-privileged users cannot execute privileged functions.

* **Control Requirement/Expected Evidence:** Alteration or circumvention of security measures must be restricted.
    * **Provided Evidence:** Reports on attempted access to privileged functions generated by automated tools.
    * **Surveilr Method (as described/expected):** API calls for generating access reports.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_attempts WHERE status = 'failed' AND function = 'privileged';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The automated reports indicate that unauthorized access attempts are logged, supporting the restriction on altering security measures.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Users must acknowledge their understanding of access limitations.
    * **Provided Evidence:** Acknowledgment forms completed by users and stored in Surveilr.
    * **Human Action Involved (as per control/standard):** Completion of acknowledgment forms by users.
    * **Surveilr Recording/Tracking:** Stored signed acknowledgment forms in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The presence of completed acknowledgment forms demonstrates that users are aware of their access limitations.

* **Control Requirement/Expected Evidence:** Logs of incidents where users report security safeguard failures.
    * **Provided Evidence:** Logs of incidents submitted to Surveilr.
    * **Human Action Involved (as per control/standard):** Users report security failures.
    * **Surveilr Recording/Tracking:** Incident logs recorded in Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The logs show that incidents are documented and processed, meeting the requirement for human attestation.

## 3. Overall Alignment with Control's Intent Spirit

* **Assessment:** The evidence provided demonstrates that the organization effectively prevents non-privileged users from executing privileged functions, aligning with the control's intent.
* **Justification:** The automated and manual evidence collectively supports the control's underlying purpose of safeguarding sensitive information.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The organization has provided sufficient evidence demonstrating compliance with the control requirements and intent.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A as the overall result is PASS, but if there were missing pieces, specify what is needed.]
* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A as the overall result is PASS.]
* **Required Human Action Steps:**
    * [N/A as the overall result is PASS.]
* **Next Steps for Re-Audit:** [N/A as the overall result is PASS.]

**[END OF GENERATED PROMPT CONTENT]**