---
title: "Cybersecurity Control Assessment Policy"
weight: 1
description: "Establishes a framework for assessing cybersecurity and data privacy controls to protect sensitive information and ensure compliance with CMMC requirements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "CA.L2-3.12.1"
control-question: "Does the organization formally assess the cybersecurity & data privacy controls in systems, applications and services through Information Assurance Program (IAP) activities to determine the extent to which the controls are implemented correctly, operating as intended and producing the desired outcome with respect to meeting expected requirements?"
fiiId: "FII-SCF-IAO-0002"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Information Assurance"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction

The purpose of this policy is to establish a framework for the formal assessment of cybersecurity and data privacy controls across the organization. This assessment is critical to ensuring that controls are not only implemented correctly but also operating as intended to protect sensitive data, particularly electronic Protected Health Information (ePHI). By adhering to this policy, the organization demonstrates its commitment to maintaining a robust Information Assurance Program (IAP) that aligns with the CMMC control CA.L2-3.12.1.

## Policy Statement

The organization is committed to formally assessing its cybersecurity and data privacy controls within all systems, applications, and services through the activities outlined in the Information Assurance Program (IAP). This assessment aims to ensure that controls meet expected requirements and effectively safeguard sensitive information.

## Scope

This policy applies to all organizational entities and environments, including but not limited to:
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities

- **Compliance Officer**: **Conduct** formal assessments of controls **quarterly** and **report** findings to senior management.
- **IT Security**: **Implement** automated evidence collection methods **monthly** and **review** system configurations for compliance **bi-weekly**.
- **Managers**: **Sign off** on assessment reports **within 5 business days** of receipt and **ensure** documentation is submitted to Surveilr.

## Evidence Collection Methods

1. **REQUIREMENT**: Formal assessments of controls must be conducted to validate effectiveness in securing data and ensuring privacy.
  
2. **MACHINE ATTESTATION**: Utilize tools such as OSquery to automate the collection of system data and validate configuration settings. Automated reports should be generated **monthly** and reviewed for accuracy.

3. **HUMAN ATTESTATION**: Managers must **sign off** on assessment reports within **5 business days** to confirm their accuracy. All signed reports and documentation must be ingested into Surveilr for compliance tracking.

## Verification Criteria

Compliance validation will be measured against the following **SMART** criteria:
- **KPIs/SLAs**: 
  - 95% of formal assessments must be completed within the scheduled timelines.
  - 100% of critical findings must be remediated within **30 days** of identification.

## Exceptions

Any exceptions to this policy must be documented and submitted for approval to the Compliance Officer. An exception request form must be completed, detailing the reason for the exception, along with any supporting documentation.

## Lifecycle Requirements

- **Data Retention**: All evidence and logs must be retained for a minimum of **3 years** to ensure traceability and accountability.
- **Mandatory frequency for policy review and update**: This policy shall be reviewed and updated at least **annually** to reflect any changes in regulatory requirements or organizational practices.

## Formal Documentation and Audit

All workforce members must acknowledge their understanding and compliance with this policy by signing a formal acknowledgment document. Comprehensive audit logging must be maintained for all critical actions, ensuring accountability and traceability within the organization.

## References

[Cybersecurity Maturity Model Certification (CMMC)](https://www.acq.osd.mil/cmmc/)  
[HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)  
[National Institute of Standards and Technology (NIST) Cybersecurity Framework](https://www.nist.gov/cyberframework)