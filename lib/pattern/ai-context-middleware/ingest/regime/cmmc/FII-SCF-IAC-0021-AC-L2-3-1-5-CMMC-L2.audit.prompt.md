---
title: "Audit Prompt: Least Privilege Access Control Policy"
weight: 1
description: "Implement least privilege access controls to minimize security risks and ensure compliance with CMMC control AC.L2-3.1.5 across all organizational systems."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L2-3.1.5"
control-question: "Does the organization utilize the concept of least privilege, allowing only authorized access to processes necessary to accomplish assigned tasks in accordance with organizational business functions?"
fiiId: "FII-SCF-IAC-0021"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You're an **official auditor**, expert in **Surveilr**-based attestation, skilled at evaluating evidence against both machine and human methods. Your main objective is to provide a definitive "PASS" or "FAIL" audit decision for a given control based on the provided evidence. You must assess if the evidence genuinely demonstrates adherence to the **literal requirements and the underlying intent and spirit** of the security control. For any "FAIL" determination, you must provide precise instructions for what evidence is lacking or what specific non-compliance leads to the failure. Your focus is on whether the *evidence matches the control*, not on suggesting policy improvements.

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
  * **Control's Stated Purpose/Intent:** "The organization utilizes the concept of least privilege, allowing only authorized access to processes necessary to accomplish assigned tasks in accordance with organizational business functions."
Control Code: AC.L2-3.1.5,
Control Question: Does the organization utilize the concept of least privilege, allowing only authorized access to processes necessary to accomplish assigned tasks in accordance with organizational business functions?
Internal ID (Foreign Integration Identifier as FII): FII-SCF-IAC-0021
  * **Policy/Process Description (for context on intent and expected evidence):**
    "This policy outlines the requirements and procedures necessary to implement the principle of least privilege within the organization. Adopting this principle is crucial for minimizing security risks, ensuring that individuals have only the access necessary to perform their job functions, thereby supporting compliance with CMMC control AC.L2-3.1.5. The organization is committed to implementing the principle of least privilege by allowing only authorized access to processes that are essential for accomplishing assigned tasks."
  * **Provided Evidence for Audit:** "Surveilr logs show user access levels within systems, changes in access permissions, and automated alerts for unauthorized access attempts. Managers have validated access levels for their team members, documented the review process, and submitted this documentation into Surveilr for compliance tracking."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L2-3.1.5

**Overall Audit Result: [PASS/FAIL]**  
**Date of Audit:** [Current Date, e.g., 2025-07-28]  
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]  
**Control Code:** AC.L2-3.1.5  
**Control Question:** Does the organization utilize the concept of least privilege, allowing only authorized access to processes necessary to accomplish assigned tasks in accordance with organizational business functions?  
**Internal ID (FII):** FII-SCF-IAC-0021  
**Control's Stated Purpose/Intent:** The organization utilizes the concept of least privilege, allowing only authorized access to processes necessary to accomplish assigned tasks in accordance with organizational business functions.

## 1. Executive Summary

[Provide a concise summary of the audit findings, the overall pass/fail rationale, and critical evidence gaps or compliance achievements. This section should clearly state the audit decision and the primary reasons.]

## 2. Evidence Assessment Against Control Requirements

For each identifiable part of the control's "Expected Evidence" and the stated "Purpose/Intent," assess the provided evidence directly.

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** The organization must enforce least privilege access controls, ensuring that users are granted the minimum level of access required for their roles.
    * **Provided Evidence:** Surveilr logs show user access levels within systems, changes in access permissions, and automated alerts for unauthorized access attempts.
    * **Surveilr Method (as described/expected):** Automated data ingestion through Surveilr capturing user access logs and permission changes.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM user_access_logs WHERE access_level < required_level;
    * **Compliance Status:** COMPLIANT
    * **Justification:** The evidence demonstrates that the organization actively logs and monitors user access levels, which aligns with the control requirement.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Conduct regular reviews where managers validate access levels for their team members.
    * **Provided Evidence:** Managers have validated access levels for their team members, documented the review process, and submitted this documentation into Surveilr for compliance tracking.
    * **Human Action Involved (as per control/standard):** Managers performing access reviews and documenting their findings.
    * **Surveilr Recording/Tracking:** Surveilr records the submission of review documentation.
    * **Compliance Status:** COMPLIANT
    * **Justification:** The human attestation process is documented and compliant with the requirement, demonstrating that access levels are regularly reviewed.

## 3. Overall Alignment with Control's Intent Spirit

* **Assessment:** The provided evidence demonstrates that the organization upholds the principle of least privilege, effectively managing access controls.
* **Justification:** The combination of machine and human attestation indicates a robust approach to maintaining compliance with the control's intent.
* **Critical Gaps in Spirit (if applicable):** None identified.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence provided meets both the literal requirements and the underlying intent of the control, showing effective implementation of least privilege access controls.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

**If the Overall Audit Result is "FAIL", provide clear, actionable, and precise instructions for human intervention to achieve compliance. This section is an auditor's directive.**

* **Specific Missing Evidence Required:** 
    * [For each missing piece of evidence identified in Section 2, state *exactly* what is needed. E.g., "Missing current firewall rule sets from production firewalls (FII-XYZ-001) for the quarter ending 2025-06-30."]
    * [Specify the required format/type for each missing piece: e.g., "Obtain OSquery results for network interface configurations on all servers tagged 'production_web'.", "Provide a signed PDF of the latest incident response plan approval."]
* **Specific Non-Compliant Evidence Required Correction:**
    * [For each instance of non-compliant evidence identified in Section 2, clearly state *why* it is non-compliant and what *specific correction* is required. E.g., "Provided access logs show unapproved access event on 2025-07-15 by UserID 123; requires an associated incident ticket (IR-2025-005) or justification."]
    * [Specify the action needed: e.g., "Remediate firewall rule CC6-0010-005 to correctly block traffic from IP range X.Y.Z.0/24.", "Provide evidence of user access review completion for Q2 2025 for all critical systems."]
* **Required Human Action Steps:**
    * [List precise steps a human auditor or compliance officer needs to take. E.g., "Engage IT Operations to retrieve the specific logs for server X from date Y.", "Contact system owner Z to obtain management attestation for policy P."]
    * [Specify which teams or individuals are responsible for producing or correcting the evidence.]
* **Next Steps for Re-Audit:** [Outline the process for re-submission of the corrected/missing evidence for re-evaluation.]