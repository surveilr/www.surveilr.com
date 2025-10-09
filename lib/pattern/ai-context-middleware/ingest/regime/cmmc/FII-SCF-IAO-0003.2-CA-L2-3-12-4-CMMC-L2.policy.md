---
title: "Sensitive Data Protection Compliance Policy"
weight: 1
description: "Establishes comprehensive measures for protecting sensitive data through machine and human attestations across all organizational systems and environments."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "CA.L2-3.12.4"
control-question: "Does the organization protect sensitive / regulated data that is collected, developed, received, transmitted, used or stored in support of the performance of a contract?"
fiiId: "FII-SCF-IAO-0003.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Information Assurance"
category: ["CMMC", "Level 2", "Compliance"]
---

# CMMC Compliance Policy for Control: CA.L2-3.12.4

## Introduction
This policy outlines the requirements for protecting sensitive and regulated data as specified in the CMMC control CA.L2-3.12.4. The organization must ensure that all sensitive data collected, developed, received, transmitted, used, or stored in support of any contract is adequately protected. 

## Policy Statement
The organization commits to implementing appropriate measures for the protection of sensitive and regulated data across all environments, including cloud-hosted systems, SaaS applications, third-party vendor systems, and any channels used to handle such data. Compliance will be achieved through a combination of **machine attestation** and **human attestation** methods.

## Scope
This policy applies to:
- All employees, contractors, and third-party vendors accessing sensitive data.
- All systems and applications that collect, store, process, or transmit sensitive data, including:
  - On-premises servers
  - Cloud-hosted environments
  - SaaS applications
  - Third-party systems
- All data channels used for sensitive data management.

## Responsibilities
- **Data Protection Officer (DPO)**: 
  - Oversee compliance with this policy and report quarterly.
  - Ensure that all systems are compliant with **KPIs/SLAs**.
  
- **IT Security Team**:
  - Conduct monthly reviews of machine attestation data.
  - Remediate any identified compliance gaps within 10 business days.

- **Department Managers**:
  - Validate and sign off on quarterly reports regarding sensitive data handling.
  - Ensure team members understand and comply with this policy through training sessions held bi-annually.

## Evidence Collection Methods
1. **REQUIREMENT**: Ensure that sensitive data is encrypted during transmission and storage.
   - **MACHINE ATTESTATION**: Use [OSquery](https://osquery.io/) to verify encryption status of sensitive data on a daily basis.
   - **HUMAN ATTESTATION**: The IT Manager must sign the monthly encryption compliance report, which is to be ingested into Surveilr.

2. **REQUIREMENT**: Maintain an inventory of all systems handling sensitive data.
   - **MACHINE ATTESTATION**: Automate asset inventory collection using OSquery, ingesting data into Surveilr daily.
   - **HUMAN ATTESTATION**: Department Managers must validate and sign the quarterly asset inventory report, with artifacts scanned and uploaded to Surveilr.

3. **REQUIREMENT**: Conduct regular security assessments on systems that manage sensitive data.
   - **MACHINE ATTESTATION**: Integrate vulnerability scanning tools that automatically report findings to Surveilr every 30 days.
   - **HUMAN ATTESTATION**: Security team leads must submit a signed assessment report after each quarterly security assessment to Surveilr.

## Verification Criteria
- Compliance validation will be assessed monthly, utilizing the following **KPIs/SLAs**:
  - 100% of sensitive data must be encrypted as confirmed by daily OSquery compliance reports.
  - 95% of systems must be included in the asset inventory within the quarterly report.
  - Security assessments must be completed and reported within 30 days of the scheduled date.

## Exceptions
Any exceptions to this policy must be documented and formally approved by the Data Protection Officer. Exceptions will be logged in Surveilr, and all stakeholders must be notified. 

## Lifecycle Requirements
- **Data Retention**: Evidence logs must be retained for a minimum of 3 years.
- **Annual Review**: This policy will be reviewed and updated annually to ensure continued compliance with CMMC requirements.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy through digital signatures in Surveilr. Comprehensive audit logs will be maintained for all critical actions related to sensitive data handling, including human attestations and exceptions.

## References
None