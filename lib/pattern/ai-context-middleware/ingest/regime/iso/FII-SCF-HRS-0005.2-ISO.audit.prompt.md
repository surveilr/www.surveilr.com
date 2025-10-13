---
title: "Audit Prompt: Social Media Use and Compliance Policy"
weight: 1
description: "Establishes guidelines for responsible social media use to protect the organization's reputation and sensitive information."
publishDate: "2025-10-11"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "FII-SCF-HRS-0005.2"
control-question: "Does the organization define rules of behavior that contain explicit restrictions on the use of social media and networking sites, posting information on commercial websites and sharing account information?"
fiiId: "FII-SCF-HRS-0005.2"
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

  * **Audit Standard/Framework:** ISO
  * **Control's Stated Purpose/Intent:** "The organization defines rules of behavior that contain explicit restrictions on the use of social media and networking sites, posting information on commercial websites, and sharing account information."
  * **Control Code:** [ISO-SOC-001]
  * **Control Question:** "Does the organization define rules of behavior that contain explicit restrictions on the use of social media and networking sites, posting information on commercial websites and sharing account information?"
  * **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-HRS-0005.2
  * **Policy/Process Description (for context on intent and expected evidence):**
    "The organization has established a Social Media Use and Networking Policy that outlines explicit rules of behavior regarding the use of social media and networking sites. This policy applies to all employees, contractors, and third-party vendors, ensuring that the organization’s reputation and sensitive information are protected. The policy prohibits the unauthorized use of these platforms in a way that could compromise security. Employees are required to acknowledge and comply with this policy upon onboarding and whenever updates occur."
  * **Provided Evidence for Audit:** "1. Evidence of automated monitoring tools tracking employee social media activity. 2. Logs capturing access and modifications to the Acceptable Use Policy and Social Media Policy documentation. 3. Records of employee training completion and signed acknowledgment forms for Security Awareness Training regarding social media use."

**Requirements for Your Audit Report (Structured format):**


# Official Audit Report: ISO - ISO-SOC-001

**Overall Audit Result: [PASS/FAIL]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., ISO Compliance Auditor]
**Control Code:** [ISO-SOC-001]
**Control Question:** [Does the organization define rules of behavior that contain explicit restrictions on the use of social media and networking sites, posting information on commercial websites and sharing account information?]
**Internal ID (FII):** [FII-SCF-HRS-0005.2]
**Control's Stated Purpose/Intent:** [The organization defines rules of behavior that contain explicit restrictions on the use of social media and networking sites, posting information on commercial websites, and sharing account information.]

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must define rules of behavior that contain explicit restrictions on the use of social media and networking sites, posting information on commercial websites, and sharing account information.
    * **Provided Evidence:** Evidence of automated monitoring tools tracking employee social media activity is available.
    * **Surveilr Method (as described/expected):** Automated monitoring tools were implemented to track employee social media activity and flag violations.
    * **Conceptual/Actual SQL Query Context:** SQL queries are used to analyze logs generated by the monitoring tools for compliance verification.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The automated monitoring tools effectively track and flag violations, demonstrating adherence to the control's requirements.

* **Control Requirement/Expected Evidence:** The organization must maintain logs capturing access and modifications to the Acceptable Use Policy and Social Media Policy documentation.
    * **Provided Evidence:** Logs capturing access and modifications are available.
    * **Surveilr Method (as described/expected):** Logging systems are used to capture modifications to policy documentation.
    * **Conceptual/Actual SQL Query Context:** SQL queries are executed to verify log integrity and modification history.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The organization maintains comprehensive logs that demonstrate compliance with the control requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Employees must complete a Security Awareness Training that includes a section on social media use and sign an acknowledgment form.
    * **Provided Evidence:** Records of employee training completion and signed acknowledgment forms are available.
    * **Human Action Involved (as per control/standard):** Employees completed training and signed acknowledgment forms.
    * **Surveilr Recording/Tracking:** Digital signatures are stored in the Surveilr compliance platform.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The records show that all employees have completed the required training and acknowledged the policy, demonstrating adherence to the control.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The provided evidence collectively demonstrates that the organization meets the underlying purpose and intent of the control.
* **Justification:** The combination of machine attestable evidence and human attestation confirms that rules of behavior regarding social media use are well-defined and adhered to.
* **Critical Gaps in Spirit (if applicable):** None noted.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The organization has effectively established and enforced rules of behavior regarding social media and networking sites, as evidenced by the compliance of machine and human attestations.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:**
    * [N/A]
* **Specific Non-Compliant Evidence Required Correction:**
    * [N/A]
* **Required Human Action Steps:**
    * [N/A]
* **Next Steps for Re-Audit:** [N/A]