---
title: "Account Management Governance and Security Policy"
weight: 1
description: "Establishes a comprehensive framework for managing accounts to protect sensitive information and ensure compliance with regulatory requirements."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L1-3.1.2"
control-question: "Does the organization proactively govern account management of individual, group, system, service, application, guest and temporary accounts?"
fiiId: "FII-SCF-IAC-0015"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Identification & Authentication"
category: ["CMMC", "Level 1", "Compliance"]
---

# Account Management Governance Policy

## 1. Introduction
The purpose of this policy is to establish a robust framework for account management governance within the organization. Effective account management is critical to safeguarding sensitive information, including electronic Protected Health Information (ePHI), and ensuring compliance with regulatory requirements. By implementing proactive governance measures, the organization can mitigate risks associated with unauthorized access, enhance accountability, and maintain the integrity of its systems and data.

## 2. Policy Statement
The organization is committed to proactive account management for all types of accounts, including individual, group, system, service, application, guest, and temporary accounts. This commitment ensures that access to sensitive information is controlled, monitored, and reviewed regularly, thereby protecting the organization’s assets and maintaining compliance with applicable regulations.

## 3. Scope
This policy applies to all entities and environments within the organization, including but not limited to cloud-hosted systems, Software as a Service (SaaS) applications, third-party vendor systems (Business Associates), and all channels used to create, receive, maintain, or transmit ePHI. All workforce members, contractors, and third-party service providers are subject to this policy.

## 4. Responsibilities
- **Compliance Officer**: Conducts **quarterly** reviews of account management policies and practices to ensure compliance.
- **IT Security**: Monitors account activity **daily** and generates reports on any anomalies or unauthorized access attempts.
- **System Administrators**: Perform **monthly** audits of user accounts to ensure appropriate access levels and remove inactive accounts.

## 5. Evidence Collection Methods
1. **REQUIREMENT**: All accounts must be created, modified, and deactivated following established protocols, ensuring that access is granted based on the principle of least privilege.
2. **MACHINE ATTESTATION**: Utilize API integrations to validate access controls and generate automated reports on account status and access levels.
3. **HUMAN ATTESTATION**: The IT manager must sign off on the quarterly account review report, which is then ingested into Surveilr for compliance tracking.

## 6. Verification Criteria
Compliance validation will be measured against the following criteria:
- **Specific**: All accounts must be reviewed for access appropriateness at least **quarterly**.
- **Measurable**: 100% of accounts must have documented access reviews.
- **Achievable**: Compliance with access control requirements must be met by all staff.
- **Relevant**: All accounts must align with the organization’s access control policies.
- **Time-bound**: Reviews must be completed within 30 days of the end of each quarter.

## 7. Exceptions
Any exceptions to this policy must be documented, including a justification for the exception, the duration for which the exception is valid, and approval from the Compliance Officer. Exceptions must be reviewed **annually** to determine if they are still necessary.

## 8. Lifecycle Requirements
Evidence and logs related to account management must be retained for a period of **6 years**. This policy will be reviewed and updated at least **annually** to ensure its effectiveness and relevance to current practices and regulatory requirements.

## 9. Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy through formal attestation. Comprehensive audit logging must be maintained for all critical actions related to account management, and formal documentation must be created for all exceptions, ensuring transparency and accountability.

## 10. References
[Cybersecurity Maturity Model Certification (CMMC)](https://www.acq.osd.mil/cmmc/)  
[Health Insurance Portability and Accountability Act (HIPAA)](https://www.hhs.gov/hipaa/index.html)  
[National Institute of Standards and Technology (NIST) Special Publication 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)