---
title: "Secure Public Key Infrastructure Policy"
weight: 1
description: "Establishes secure PKI infrastructure or services to protect sensitive data and ensure compliance with cybersecurity standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "SC.L2-3.13.10"
control-question: "Does the organization securely implement an internal Public Key Infrastructure (PKI) infrastructure or obtain PKI services from a reputable PKI service provider?"
fiiId: "FII-SCF-CRY-0008"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Cryptographic Protections"
category: ["CMMC", "Level 2", "Compliance"]
---

# PKI Infrastructure Policy for Control: SC.L2-3.13.10 (FII: FII-SCF-CRY-0008)

## 1. Introduction
The control SC.L2-3.13.10 is essential for ensuring that organizations maintain a secure Public Key Infrastructure (PKI). This control mandates that organizations either implement their own PKI infrastructure securely or engage with a reputable PKI service provider. Secure PKI is critical for protecting sensitive information, enabling secure communications, and ensuring the integrity and authenticity of data through cryptographic measures. Compliance with this control supports the organization's overall cybersecurity posture and fosters trust among stakeholders.

## 2. Policy Statement
The organization is committed to securely implementing PKI infrastructure or obtaining PKI services from a reputable provider. This commitment ensures that all cryptographic operations are performed within a controlled and secure environment, safeguarding sensitive data and maintaining compliance with regulatory requirements.

## 3. Scope
This policy applies to all relevant entities and environments within the organization, including but not limited to:
- On-premises PKI systems
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems providing PKI services

## 4. Responsibilities
- **Compliance Officer**: quarterly policy approval
- **IT Security Team**: monthly security audits of PKI systems
- **System Administrators**: daily monitoring of PKI configurations
- **PKI Manager**: biannual review of PKI service providers
- **All Employees**: immediate reporting of any PKI-related security incidents

## 5. Evidence Collection Methods
### 1. REQUIREMENT
The control requires that organizations securely implement an internal PKI infrastructure or acquire services from a reputable PKI provider. This includes ensuring that all cryptographic keys are generated, stored, and managed securely.

### 2. MACHINE ATTESTATION
To validate compliance, practical, automatable methods for collecting and validating evidence include:
- Use **OSquery** to collect PKI configuration details **daily**.
- Implement automated alerts for unauthorized changes to PKI configurations.

### 3. HUMAN ATTESTATION
When automation is impractical, the following actions and artifacts are required:
- The **IT Manager** must sign off on the PKI review report, which is then uploaded to **Surveilr** with metadata **monthly**.
- Document and upload any changes in PKI service providers or configurations to **Surveilr** upon occurrence.

## 6. Verification Criteria
Compliance validation will be based on the following measurable criteria linked to the **KPIs/SLAs**:
- 100% of PKI configurations reviewed and documented **monthly**.
- All security incidents related to PKI reported within 24 hours.

## 7. Exceptions
Any exceptions to this policy must be documented with justifications and submitted for approval. Exceptions will be reviewed by the **Compliance Officer** and must include:
- A detailed risk assessment.
- The planned duration of the exception.
- A timeline for compliance restoration.

## 8. Lifecycle Requirements
All evidence and logs must be retained for a minimum of **6 years**. This policy will be subject to an **Annual Review** to ensure continued relevance and compliance with current standards and practices.

## 9. Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logging must be maintained for all PKI-related activities, and formal documentation is required for all exceptions to ensure accountability and traceability.

## 10. References
[CMMC Model](https://www.acq.osd.mil/cmmc)