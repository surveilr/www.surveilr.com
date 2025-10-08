---
title: "Audit Prompt: Role-Based Access Control Policy for Data Security"
weight: 1
description: "Establishes a Role-Based Access Control framework to ensure authorized access to sensitive data, enhancing security and regulatory compliance."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Audit Prompt"
control-id: "AC.L2-3.1.3"
control-question: "Does the organization enforce a Role-Based Access Control (RBAC) policy over users and resources that applies need-to-know and fine-grained access control for sensitive/regulated data access?"
fiiId: "FII-SCF-IAC-0008"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
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
- **Control's Stated Purpose/Intent:** "To enforce a Role-Based Access Control (RBAC) policy over users and resources that applies need-to-know and fine-grained access control for sensitive/regulated data access."
  - **Control Code:** AC.L2-3.1.3
  - **Control Question:** Does the organization enforce a Role-Based Access Control (RBAC) policy over users and resources that applies need-to-know and fine-grained access control for sensitive/regulated data access?
  - **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-IAC-0008
- **Policy/Process Description (for context on intent and expected evidence):**
  "The purpose of this policy is to establish a comprehensive framework for enforcing Role-Based Access Control (RBAC) for sensitive and regulated data access within our organization. The significance of this policy lies in its ability to safeguard sensitive information and ensure compliance with applicable regulations, thereby protecting the integrity, confidentiality, and availability of sensitive data, including electronic Protected Health Information (ePHI). This policy aligns with the CMMC control AC.L2-3.1.3 and supports our commitment to secure data management practices."
- **Provided Evidence for Audit:** "Evidence includes API logs demonstrating access control enforcement, records of monthly access reviews, and signed access request approval forms. No instances of unauthorized access were reported in the logs."

**Requirements for Your Audit Report (Structured format):**

# Official Audit Report: CMMC - AC.L2-3.1.3

**Overall Audit Result: [PASS]**
**Date of Audit:** [Current Date, e.g., 2025-07-28]
**Auditor Role:** [Your designated auditor role, e.g., CMMC Auditor]
**Control Code:** AC.L2-3.1.3
**Control Question:** Does the organization enforce a Role-Based Access Control (RBAC) policy over users and resources that applies need-to-know and fine-grained access control for sensitive/regulated data access?
**Internal ID (FII):** FII-SCF-IAC-0008
**Control's Stated Purpose/Intent:** "To enforce a Role-Based Access Control (RBAC) policy over users and resources that applies need-to-know and fine-grained access control for sensitive/regulated data access."

## 1. Executive Summary

The audit findings indicate that the organization successfully enforces a Role-Based Access Control (RBAC) policy that aligns with CMMC control AC.L2-3.1.3. Evidence reviewed, including API logs and access approval forms, demonstrates compliance with the control's requirements. As a result, the overall audit decision is a definitive "PASS."

## 2. Evidence Assessment Against Control Requirements

### 2.1 Machine Attestable Evidence Assessment

* **Control Requirement/Expected Evidence:** Evidence of automated enforcement of RBAC policy.
    * **Provided Evidence:** API logs demonstrating enforcement of access controls.
    * **Surveilr Method (as described/expected):** API integration capturing access attempts and actions taken.
    * **Conceptual/Actual SQL Query Context:** SELECT * FROM access_logs WHERE action = 'access_granted' AND resource_type = 'sensitive_data';
    * **Compliance Status:** COMPLIANT
    * **Justification:** The API logs provide a complete record of access attempts and confirm that access is granted only to authorized users, fully supporting the RBAC policy.

* **Control Requirement/Expected Evidence:** Evidence of periodic access reviews.
    * **Provided Evidence:** Records of monthly access reviews by Data Owners.
    * **Surveilr Method (as described/expected):** Automated logging of review actions.
    * **Conceptual/Actual SQL Query Context:** SELECT COUNT(*) FROM access_reviews WHERE review_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
    * **Compliance Status:** COMPLIANT
    * **Justification:** Monthly access reviews have been documented and align with the RBAC policy requirements.

### 2.2 Human Attestation Evidence Assessment

* **Control Requirement/Expected Evidence:** Signed access request approval forms.
    * **Provided Evidence:** Scanned copies of signed access request approval forms.
    * **Human Action Involved (as per control/standard):** Data Owners approving access requests.
    * **Surveilr Recording/Tracking:** Signed documents stored in the Surveilr evidence warehouse.
    * **Compliance Status:** COMPLIANT
    * **Justification:** All access requests are accompanied by signed approvals, demonstrating compliance with the RBAC policy.

## 3. Overall Alignment with Control's Intent & Spirit

* **Assessment:** The evidence provided aligns with the intent of the control, demonstrating that the organization effectively implements RBAC to protect sensitive data.
* **Justification:** The combination of automated logs and human attestations illustrates a robust approach to access control that fulfills both the letter and the spirit of the control.

## 4. Audit Conclusion and Final Justification

* **Final Decision:** PASS
* **Comprehensive Rationale:** The evidence reviewed indicates full compliance with the requirements of control AC.L2-3.1.3, with no gaps identified in the enforcement of the RBAC policy.

## 5. Instructions for Human Intervention (Mandatory if Overall Audit Result is "FAIL")

*Note: No human intervention is required as the overall result is "PASS".*

**[END OF GENERATED PROMPT CONTENT]**