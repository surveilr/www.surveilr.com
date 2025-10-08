---
title: "Privileged Account Multi-Factor Authentication Policy"
weight: 1
description: "Establishes Multi-Factor Authentication for privileged accounts to enhance security and ensure compliance with CMMC control IA.L2-3.5.3."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "IA.L2-3.5.3"
control-question: "Does the organization utilize Multi-Factor Authentication (MFA) to authenticate network access for privileged accounts?"
fiiId: "FII-SCF-IAC-0006.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

# Multi-Factor Authentication Policy for Privileged Accounts

## Introduction
The purpose of this policy is to establish a comprehensive framework for implementing Multi-Factor Authentication (MFA) for privileged accounts within the organization. This policy aims to enhance the security posture of the organization by ensuring that only authorized personnel can access sensitive information and systems, thereby mitigating the risks associated with unauthorized access.

## Policy Statement
The organization is committed to implementing Multi-Factor Authentication (MFA) for all privileged accounts. This commitment is aimed at safeguarding critical data and systems against unauthorized access and ensuring compliance with CMMC control IA.L2-3.5.3.

## Scope
This policy applies to all employees, contractors, and third-party vendors who have access to privileged accounts across all organizational environments, including but not limited to cloud-hosted systems, Software as a Service (SaaS) applications, and third-party vendor systems.

## Responsibilities
- **IT Security Team**: **Implement** MFA solutions for privileged accounts **quarterly**.
- **System Administrators**: **Monitor** MFA configurations and user compliance **weekly**.
- **Compliance Officer**: **Review** MFA compliance and report findings **monthly**.
- **All Users with Privileged Access**: **Participate** in MFA training sessions **annually**.

## Evidence Collection Methods
1. **REQUIREMENT**: All privileged accounts must utilize Multi-Factor Authentication to ensure secure access.
2. **MACHINE ATTESTATION**: Utilize API integrations to validate MFA configurations and monitor compliance through Surveilr.
3. **HUMAN ATTESTATION**: The IT manager must sign a quarterly report confirming MFA compliance and upload it to Surveilr with metadata.

## Verification Criteria
Compliance with this policy will be validated through the following measurable criteria:
- **100% of privileged accounts** must have MFA enabled as tracked by the system logs.
- **Monthly audits** must show **0% non-compliance** with established **KPIs/SLAs** for MFA usage.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. The process for documenting exceptions includes submitting a request form detailing the rationale for the exception and expected duration. 

## Lifecycle Requirements
- **Data Retention**: Evidence and logs related to MFA compliance must be retained for a period of **five years**.
- **Annual Review**: This policy will undergo an **Annual Review** to ensure its effectiveness and relevance.

## Formal Documentation and Audit
All workforce members must acknowledge understanding and compliance with this policy. Comprehensive audit logging of all actions related to MFA must be maintained. Exceptions to the policy must be documented formally, including the rationale for the exception and any approved durations.

## References
[Cybersecurity Maturity Model Certification (CMMC)](https://www.acq.osd.mil/cmmc/)