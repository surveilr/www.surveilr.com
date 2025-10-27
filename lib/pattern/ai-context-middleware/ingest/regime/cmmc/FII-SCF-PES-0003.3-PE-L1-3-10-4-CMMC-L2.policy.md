---
title: "Access Logging Policy for ePHI Security"
weight: 1
description: "Establishes guidelines for logging all access attempts to ensure the security of ePHI and compliance with CMMC requirements."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "PE.L1-3.10.4"
control-question: "Does the organization generate a log entry for each access attempt through controlled ingress and egress points?"
fiiId: "FII-SCF-PES-0003.3"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# CMMC Policy for Control: PE.L1-3.10.4 (FII: FII-SCF-PES-0003.3)

## Introduction
The purpose of this policy is to establish guidelines for generating log entries for all access attempts through controlled ingress and egress points. This is essential for safeguarding electronic Protected Health Information (ePHI) and ensuring compliance with the Cybersecurity Maturity Model Certification (CMMC) requirements. 

## Policy Statement
All access attempts to physical locations containing ePHI shall be logged to maintain a comprehensive audit trail. This policy requires the generation of log entries for both successful and unsuccessful access attempts at controlled ingress and egress points. 

## Scope
This policy applies to all systems and channels that create, receive, maintain, or transmit ePHI, including:
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems
- Physical access points to facilities where ePHI is stored

## Responsibilities
- **IT Security Team**: 
  - Implement and maintain logging mechanisms for access attempts **(Daily)**.
  - Review logs for anomalies and report findings **(Weekly)**.
- **Compliance Officer**: 
  - Ensure adherence to this policy and conduct internal audits **(Quarterly)**.
- **All Workforce Members**: 
  - Acknowledge and attest to understanding and compliance with this policy **(Annually)**.

## Evidence Collection Methods

### 1. REQUIREMENT:
Generate a log entry for each access attempt through controlled ingress and egress points.

### 2. MACHINE ATTESTATION:
- Utilize logging features in access control systems to automatically generate logs for each access attempt.
- Use OSquery to collect and validate logs daily, ensuring that they reflect all access attempts, both successful and unsuccessful.

### 3. HUMAN ATTESTATION:
- Compliance Officer reviews log entries monthly and documents findings.
- Managers sign off on quarterly inventory validation reports, confirming that logs are reviewed and any discrepancies are addressed.

## Verification Criteria
- **SMART** objectives are defined as follows:
  - 100% of access attempts logged with a maximum time to resolution of discrepancies set at **24 hours** after initial detection.
  - **KPIs/SLAs** include:
    - Monthly audit of access logs with a target of zero missed access attempts.
    - Quarterly manager sign-off on validation reports within **5 business days** of the end of each quarter.

## Exceptions
Any exceptions to this policy must be formally documented and require approval from the Compliance Officer. Workforce members must acknowledge exceptions to ensure compliance.

## Lifecycle Requirements
- **Data Retention**: Access logs must be retained for a minimum of **3 years**.
- Mandatory **Annual Review** of this policy to ensure its relevance and effectiveness.

## Formal Documentation and Audit
All critical actions must be logged, and audit trails must be maintained for compliance verification. The Compliance Officer will conduct formal audits annually.

## References
None