---
title: "Audit Prompt: ISO Risk Assessment and Management Policy"
weight: 1
description: "Establishes a framework for conducting regular risk assessments to safeguard the organization's systems and data against unauthorized access and potential threats."
publishDate: "2025-10-11"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-RSK-0004"
control-question: "Does the organization conduct recurring assessments of risk that includes the likelihood and magnitude of harm, from unauthorized access, use, disclosure, disruption, modification or destruction of its systems and data?"
fiiId: "FII-SCF-RSK-0004"
regimeType: "ISO"
category: ["ISO", "Compliance"]
---

You're an **official auditor (e.g., auditor)**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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

  * **Audit Standard/Framework:** ISO 27001:2022
  * **Control's Stated Purpose/Intent:** "The organization conducts recurring assessments of risk that includes the likelihood and magnitude of harm, from unauthorized access, use, disclosure, disruption, modification or destruction of its systems and data."
Control Code: FII-SCF-RSK-0004,
Control Question: Does the organization conduct recurring assessments of risk that includes the likelihood and magnitude of harm, from unauthorized access, use, disclosure, disruption, modification or destruction of its systems and data?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-RSK-0004
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The purpose of this policy is to establish a framework for the recurring assessment of risks associated with unauthorized access, use, disclosure, disruption, modification, or destruction of the organization's systems and data. This policy is significant in the context of risk management as it helps protect the integrity, confidentiality, and availability of sensitive information, ensuring compliance with applicable regulations and standards. The organization is committed to conducting recurring assessments of risk to evaluate the likelihood and magnitude of harm resulting from unauthorized access, use, disclosure, disruption, modification, or destruction of its systems and data. These assessments will be integral to our risk management strategy and will help mitigate potential threats and vulnerabilities."
  * **Provided Evidence for Audit:** "The organization conducts quarterly risk assessments as evidenced by the signed risk assessment reports uploaded into Surveilr for the last four quarters. The reports include details of identified risks, assessment processes, and mitigation strategies. Automated evidence collection is integrated with risk management tools to ensure consistency and accuracy in reporting."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: ISO 27001:2022 - FII-SCF-RSK-0004

**Overall Audit Result: [PASS]**
**Date of Audit:** [Current Date, e.g., 2023-10-05]
**Auditor Role:** [Surveilr Auditor]
**Control Code:** FII-SCF-RSK-0004
**Control Question:** Does the organization conduct recurring assessments of risk that includes the likelihood and magnitude of harm, from unauthorized access, use, disclosure, disruption, modification or destruction of its systems and data?
**Internal ID (FII):** FII-SCF-RSK-0004
**Control's Stated Purpose/Intent:** The organization conducts recurring assessments of risk that includes the likelihood and magnitude of harm, from unauthorized access, use, disclosure, disruption, modification or destruction of its systems and data.

## 1. Executive Summary

The audit findings indicate that the organization successfully conducts quarterly risk assessments as required by the control. The evidence provided, including signed risk assessment reports and automated data collection, demonstrates compliance with the control's requirements. No significant evidence gaps were identified.

## 2. Evidence Assessment Against Control Requirements

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Conduct recurring risk assessments at least **quarterly** to evaluate potential risks associated with unauthorized activities.
    * **Provided Evidence:** Signed risk assessment reports for the last four quarters.
    * **Surveilr Method (as described/expected):** Automated evidence collection integrated with risk management tools.
    * **Conceptual/Actual SQL Query Context:** SQL queries verifying the existence of quarterly reports in the RSSD.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The provided risk assessment reports confirm that assessments were performed quarterly, meeting the control's requirements.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Signed risk assessment reports to be uploaded into Surveilr, including documentation of the assessment process and findings.
    * **Provided Evidence:** Risk assessment reports uploaded into Surveilr with signatures of the responsible personnel.
    * **Human Action Involved (as per control/standard):** Manual signing and uploading of risk assessment reports.
    * **Surveilr Recording/Tracking:** Signed PDFs stored within Surveilr.
    * **Compliance Status:** COMPLIANT
    * **Justification:** All risk assessment reports are properly signed and documented, fulfilling the human attestation requirement.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence demonstrates that the organization not only meets the literal requirements of the control but also aligns with the underlying intent of proactive risk management.
* **Justification:** The organization has established a robust framework for risk assessment, ensuring that potential threats are identified and mitigated effectively.
* **Critical Gaps in Spirit (if applicable):** Not applicable, as all requirements are satisfactorily met.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The audit demonstrates full compliance with the control requirements. The organization effectively conducts quarterly risk assessments and maintains proper documentation, as evidenced by signed reports and automated data collection.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * Not applicable, as all required evidence is present.
* **Specific Non-Compliant Evidence Required Correction:**
    * Not applicable, as there are no non-compliant pieces of evidence.
* **Required Human Action Steps:**
    * Not applicable, as no actions are required.
* **Next Steps for Re-Audit:** Not applicable, as the audit concluded with a PASS.

**[END OF GENERATED PROMPT CONTENT]**