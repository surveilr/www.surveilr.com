---
title: "Multi-Factor Authentication Policy for Network Access"
weight: 1
description: "Implement Multi-Factor Authentication (MFA) to enhance network security and protect non-privileged accounts from unauthorized access."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "IA.L2-3.5.3"
control-question: "Does the organization utilize Multi-Factor Authentication (MFA) to authenticate network access for non-privileged accounts?"
fiiId: "FII-SCF-IAC-0006.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction

The purpose of this policy is to establish guidelines for the implementation and management of Multi-Factor Authentication (MFA) to authenticate network access for non-privileged accounts. This policy aims to enhance security, reduce the risk of unauthorized access, and ensure compliance with the CMMC control IA.L2-3.5.3. The organization recognizes the importance of MFA as a critical component in protecting sensitive information and systems from unauthorized access.

## Policy Statement

The organization shall implement and maintain Multi-Factor Authentication (MFA) for all non-privileged accounts accessing the network. MFA will serve as an additional layer of security to verify the identity of users and prevent unauthorized access. All relevant systems, including cloud-hosted services, SaaS applications, and third-party vendor systems, must comply with this policy.

## Scope

This policy applies to all employees, contractors, and third-party users accessing the organization’s network and systems. It encompasses:
- On-premises systems
- Cloud-hosted environments
- SaaS applications
- Third-party vendor systems

## Responsibilities

- **IT Security Team**: 
  - **Implement** MFA solutions across all applicable systems.
  - **Monitor** compliance with MFA requirements on a **monthly** basis.
  
- **System Administrators**: 
  - **Configure** and **maintain** MFA settings on systems.
  - **Review** MFA configurations for accuracy and effectiveness on a **quarterly** basis.
  
- **End Users**: 
  - **Enroll** in MFA upon initial account setup and **report** any access issues within **24 hours**.

## Evidence Collection Methods

### Machine Attestation
- Utilize **OSquery** to automatically collect MFA configuration details across all systems and validate compliance.
- Implement scripts to verify MFA enforcement logs from authentication systems.

### Human Attestation
- The IT manager must **sign** the MFA configuration review report which is ingested into Surveilr for record-keeping.

## Verification Criteria

Compliance with this policy will be verified through:
- Automated reports demonstrating MFA enforcement on all non-privileged accounts.
- A minimum of **95%** of non-privileged accounts verified to have MFA enabled during each **monthly review**.

## Exceptions

Any exceptions to this policy must be documented and approved by the IT Security Team. Exceptions will be reviewed annually and must include a justification and a risk assessment. Formal documentation of exceptions must be ingested into Surveilr.

## Lifecycle Requirements

- **Data Retention**: Evidence and logs related to MFA must be retained for a minimum of **two years**.
- Policy review and updates must occur on an **annual** basis to ensure relevance and compliance with any regulatory changes.

## Formal Documentation and Audit

All workforce members must acknowledge their understanding and compliance with this policy. Audit logs must document critical actions related to MFA configuration and access attempts, and documentation for all exceptions must be maintained.

## Operational Steps

- **Implement** MFA across all non-privileged accounts within **30 days** of policy enactment.
- **Monitor** MFA compliance on a monthly basis, ensuring that any non-compliant accounts are remediated within **7 days**.
- **Review** MFA configurations quarterly to ensure they meet organizational standards.

## References

None