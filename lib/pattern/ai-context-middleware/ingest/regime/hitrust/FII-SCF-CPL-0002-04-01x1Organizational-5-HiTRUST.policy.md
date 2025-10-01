---
title: "Mobile Device Encryption Policy"
weight: 1
description: "Implement measures to identify and encrypt mobile devices handling sensitive information, ensuring compliance and safeguarding data integrity."
publishDate: "2025-09-30"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "04.01x1Organizational.5"
control-question: "The organization identifies and encrypts mobile devices and mobile computing platforms that process, store, or transmit sensitive information."
fiiId: "FII-SCF-CPL-0002"
regimeType: "HiTRUST"
category: ["HiTRUST", "Compliance"]
---

# HiTRUST Policy Document for Control: 04.01x1Organizational (FII: FII-SCF-CPL-0002)

## Introduction
The purpose of this policy is to ensure the identification and encryption of mobile devices and mobile computing platforms that process, store, or transmit sensitive information. This policy is critical for protecting the organization's data integrity and safeguarding sensitive information from unauthorized access.

## Policy Statement
The organization shall implement measures to identify and encrypt all mobile devices and computing platforms that handle sensitive information. All mobile devices must be verified for encryption compliance, and mechanisms must be established for regular monitoring and reporting.

## Scope
This policy applies to all employees, contractors, and third-party vendors who use mobile devices and computing platforms to create, receive, maintain, or transmit sensitive information. It encompasses cloud-hosted systems, SaaS applications, and any mobile device used in connection with organizational data.

## Responsibilities
- **IT Security Team**: Responsible for the implementation of encryption solutions and monitoring compliance.
- **IT Managers**: Tasked with signing off on encryption reports and ensuring policy adherence.
- **Employees**: Required to comply with mobile device encryption requirements and report any non-compliance.

## Evidence Collection Methods
1. **REQUIREMENT**: Identification and encryption of mobile devices.
   - **MACHINE ATTESTATION**: Use OSquery to collect mobile device inventory daily and check for compliance with encryption protocols.
   - **HUMAN ATTESTATION**: The IT manager must sign off on the annual mobile device encryption report, which will be uploaded to Surveilr with appropriate metadata.

2. **REQUIREMENT**: Regular monitoring of device compliance.
   - **MACHINE ATTESTATION**: Automate reports to be generated weekly showing compliance status for all mobile devices.
   - **HUMAN ATTESTATION**: IT Security Team will perform quarterly reviews of compliance reports and upload findings to Surveilr.

## Verification Criteria
- Compliance will be validated against the **SMART** goal of achieving 100% encryption compliance for all identified mobile devices within a **30-day period** from device identification.
- KPIs/SLAs include the completion of encryption checks and reporting within specified timelines.

## Exceptions
Any exceptions to this policy must be formally documented and approved by the IT Security Team. Exception requests must specify the reason for the exception and the duration for which it is valid.

## Lifecycle Requirements
- **Data Retention**: Evidence and logs related to mobile device compliance must be retained for a minimum of **3 years**.
- **Mandatory Frequency for Policy Review and Update**: This policy must undergo an **Annual Review** to ensure it remains effective and compliant with current standards.

## Formal Documentation and Audit
- All workforce members must acknowledge and attest to the understanding of this policy annually.
- Comprehensive audit logging for critical actions must be maintained, and formal documentation must be available for any exceptions granted.

## References
None