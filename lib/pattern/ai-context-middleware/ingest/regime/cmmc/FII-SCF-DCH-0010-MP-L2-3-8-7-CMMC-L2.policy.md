---
title: "Digital Media Security and Usage Policy"
weight: 1
description: "Establish guidelines to restrict unauthorized digital media usage, ensuring the secure handling of sensitive data and compliance with CMMC standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "MP.L2-3.8.7"
control-question: "Does the organization restrict the use of types of digital media on systems or system components?"
fiiId: "FII-SCF-DCH-0010"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

# Digital Media Usage Policy

## Introduction
The purpose of this policy is to establish guidelines for the use of digital media within our organization to ensure the secure handling of sensitive data, particularly electronic Protected Health Information (ePHI). By restricting certain types of digital media on systems and system components, we aim to mitigate risks associated with data breaches, unauthorized access, and potential compliance violations in accordance with the CMMC control MP.L2-3.8.7.

## Policy Statement
Our organization strictly restricts the use of unauthorized types of digital media on all systems and system components. This includes, but is not limited to, external USB drives, portable hard drives, CDs/DVDs, and any other removable storage devices that have not been explicitly approved for use within the organization’s infrastructure. 

## Scope
This policy applies to all employees, contractors, and third-party vendors who access or use our systems, including but not limited to:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities
- **IT Security Team**: 
  - **Monitor** digital media usage logs **weekly**.
  - **Review** compliance with this policy and report findings **monthly**.
  
- **System Administrators**: 
  - **Restrict** access to unauthorized digital media types **continuously**.
  - **Update** inventory of approved digital media options **quarterly**.

- **All Staff**: 
  - **Attend** training on digital media restrictions **annually**.
  - **Report** any unauthorized digital media usage incidents **immediately**.

Links to related organizational plans: Incident Response Plan, Disaster Recovery Plan, Sanction Policy.

## Evidence Collection Methods
1. **REQUIREMENT**: The organization must restrict the use of unauthorized types of digital media on systems or system components.
  
2. **MACHINE ATTESTATION**: Utilize OSquery to collect digital media usage logs **weekly** and generate automated reports on compliance status.

3. **HUMAN ATTESTATION**: The IT manager must sign the digital media usage report **quarterly**, confirming compliance and actions taken regarding unauthorized usage.

## Verification Criteria
Compliance will be validated through:
- Achievement of a **100% compliance rate** in automated digital media usage logs.
- Evidence of **quarterly** signed reports from the IT manager.
- Incident reports of unauthorized digital media usage should be **zero**.

## Exceptions
Exceptions to this policy will only be granted under specific circumstances, which must be documented and approved by the IT Security Team. Requests for exceptions must include a risk assessment and justification for the use of the unauthorized digital media.

## Lifecycle Requirements
- **Data Retention**: All evidence and logs related to digital media usage must be retained for a minimum of **6 years**.
- **Annual Review**: This policy will be reviewed at least **annually** to ensure its effectiveness and relevance.

## Formal Documentation and Audit
All workforce members must acknowledge and attest to their understanding and compliance with this policy. Comprehensive audit logs will be maintained for critical actions related to digital media usage, and formal documentation will be required for all exceptions granted.

## References
CMMC Control Code: MP.L2-3.8.7; CMMC Domain: Data Classification & Handling; FII Identifiers: FII-SCF-DCH-0010.