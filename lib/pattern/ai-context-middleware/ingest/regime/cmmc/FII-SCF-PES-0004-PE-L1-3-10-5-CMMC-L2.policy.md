---
title: "Physical Access Control and Security Policy"
weight: 1
description: "Establishes guidelines for identifying and implementing restricted physical access controls to protect sensitive data and systems across all organizational facilities and environments."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "PE.L1-3.10.5"
control-question: "Does the organization identify systems, equipment and respective operating environments that require limited physical access so that appropriate physical access controls are designed and implemented for offices, rooms and facilities?"
fiiId: "FII-SCF-PES-0004"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# Physical Access Control Policy

## Introduction
The purpose of this policy is to establish clear guidelines for identifying systems, equipment, and respective operating environments that require limited physical access. This is critical to ensure appropriate physical access controls are designed and implemented across all relevant facilities, including cloud-hosted systems, Software as a Service (SaaS) applications, and third-party vendor systems.

## Policy Statement
It is the policy of the organization to identify and classify all systems and equipment that necessitate restricted physical access. This classification will guide the implementation of appropriate physical access controls to safeguard sensitive data and systems, particularly electronic Protected Health Information (ePHI).

## Scope
This policy applies to:
- All organizational facilities, including offices and rooms that house sensitive equipment.
- Cloud-hosted systems.
- SaaS applications.
- Third-party vendor systems (Business Associates) that handle ePHI.
- All channels used to create, receive, maintain, or transmit ePHI.

## Responsibilities
- **Facility Managers**: **Conduct assessments** of physical access needs **annually** to identify areas requiring restricted access.
- **IT Security Team**: **Implement and monitor** physical access controls and ensure compliance with the policy **quarterly**.
- **Compliance Officer**: **Review** and **update** the policy as part of an **Annual Review** process to ensure alignment with regulatory requirements.

## Evidence Collection Methods

### 1. REQUIREMENT:
Identify systems, equipment, and environments requiring limited physical access.

### 2. MACHINE ATTESTATION:
Utilize automated asset management tools to generate a report of all systems and equipment categorized by access levels. Ensure this report is updated and validated **monthly**.

### 3. HUMAN ATTESTATION:
Facility Managers shall document their assessments in a signed report, which will be ingested into Surveilr as evidence of compliance **within 5 days** of completion.

## Verification Criteria
- **MACHINE ATTESTATION** reports must demonstrate that 100% of identified systems and equipment are accounted for in the access control assessment reports.
- **HUMAN ATTESTATION** must include signatures and dates from Facility Managers, confirming completion within the stipulated **5-day** period.
- All assessments and compliance actions should be completed within the established **KPIs/SLAs** to ensure timely verification.

## Exceptions
Any deviations from this policy must be formally documented and approved by the Compliance Officer. Exceptions should detail the rationale and be reviewed during the **Annual Review**.

## Lifecycle Requirements
- **Data Retention**: All evidence and documentation related to physical access control assessments must be retained for a minimum of **5 years**.
- Mandatory frequency for policy review and update is set at **annual** intervals or sooner if significant changes occur in regulatory requirements or organizational structure.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy through documented attestation. Audit logs must be maintained for all critical actions taken in relation to physical access controls. Documentation for all exceptions must be compiled and made available for review.

## References
- [CMMC Compliance Guidelines](https://www.acq.osd.mil/cmmc/)
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html) 
- [NIST SP 800-53 Controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)