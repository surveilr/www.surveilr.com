---
title: "Unauthorized Software Installation Control Policy"
weight: 1
description: "Enforces restrictions on unauthorized software installations to protect ePHI and ensure compliance with regulatory standards across the organization."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "CM.L2-3.4.9"
control-question: "Does the organization restrict the ability of non-privileged users to install unauthorized software?"
fiiId: "FII-SCF-CFG-0005"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

# CMMC Policy for Control: CM.L2-3.4.9 (FII: FII-SCF-CFG-0005)

## Introduction
The purpose of this policy is to establish guidelines for restricting unauthorized software installations across the organization. This is crucial for maintaining the integrity of information systems and protecting sensitive data, including electronic Protected Health Information (ePHI). Unauthorized software can introduce vulnerabilities, leading to potential data breaches and compliance violations. This policy aims to minimize these risks by enforcing strict control over software installations.

## Policy Statement
The organization strictly prohibits non-privileged users from installing unauthorized software on any system that processes, stores, or transmits ePHI. Only authorized personnel are permitted to install software after following established procedures to ensure compliance with regulatory and organizational standards.

## Scope
This policy applies to all employees, contractors, and third-party vendors who access or manage systems that create, receive, maintain, or transmit ePHI. It encompasses:
- On-premises systems
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems (Business Associates)
- All communication channels used for ePHI

## Responsibilities
- **Compliance Officer**: 
  - **Quarterly** policy review and approval.
- **IT Security**: 
  - **Daily** review of software installation logs.
- **System Administrators**: 
  - **Weekly** audits of authorized software lists.
- **End Users**: 
  - **Immediate** reporting of unauthorized software attempts.
  
All roles must adhere to the **Incident Response Plan** for escalation and recovery actions, and the **Disaster Recovery Plan** for addressing related incidents.

## Evidence Collection Methods

1. **REQUIREMENT**: 
   - All software installations must be logged, and unauthorized installations must be prevented.
  
2. **MACHINE ATTESTATION**: 
   - Utilize `OSquery` to collect software installation logs **daily** and generate compliance reports.
  
3. **HUMAN ATTESTATION**: 
   - The IT manager must sign off on the quarterly software installation review report, documenting compliance with this policy.

## Verification Criteria
Compliance will be validated through the following measurable criteria:
- **KPI**: 100% of unauthorized software installation attempts logged.
- **SLA**: Software installation logs must be reviewed within **48 hours** of collection.
- **KPI**: 0 instances of unauthorized software installations per quarter.

## Exceptions
Exceptions to this policy may be granted under specific circumstances. The procedure for requesting exceptions includes:
- Submitting a formal request to the Compliance Officer.
- Documenting the rationale and potential risks associated with the exception.
- Obtaining written approval from the Compliance Officer.

## Lifecycle Requirements
- **Data Retention**: Logs of software installations must be retained for a minimum of **6 years**.
- **Policy Review**: This policy will be reviewed at least **annually** and updated as required.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logging will be maintained for all critical actions related to software installations. Formal documentation of all exceptions must be retained for audit purposes.

### References
None