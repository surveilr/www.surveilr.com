---
title: "Media Sanitization and Data Protection Policy"
weight: 1
description: "Establishes a framework for the sanitization of system media to protect sensitive information and ensure compliance with CMMC requirements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "MA.L2-3.7.3
MP.L1-3.8.3"
control-question: "Does the organization sanitize system media with the strength and integrity commensurate with the classification or sensitivity of the information prior to disposal, release out of organizational control or release for reuse?"
fiiId: "FII-SCF-DCH-0009"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction

The purpose of this policy is to establish a framework for the sanitization of system media within the organization, ensuring compliance with CMMC control MA.L2-3.7.3. This policy outlines the requirements for sanitizing system media with a level of strength and integrity that corresponds to the classification or sensitivity of the information stored on those media. It ensures that sensitive data is protected from unauthorized access during disposal, release, or reuse.

## Policy Statement

The organization mandates the sanitization of all system media containing sensitive information prior to its disposal or release from organizational control. This includes, but is not limited to, physical media such as hard drives, USB devices, and backup tapes. The sanitization process must be documented, and verification methods must confirm compliance with the established **KPIs/SLAs**.

## Scope

This policy applies to all organizational assets that store sensitive information, including:
- On-premises servers and storage devices
- Cloud-hosted systems managed by the organization
- Third-party vendor systems that process or store sensitive information

All employees, contractors, and third-party vendors who access or manage these assets are subject to this policy.

## Responsibilities

- **IT Department**: Responsible for implementing the sanitization processes, maintaining records of sanitization, and ensuring compliance with this policy.
- **Compliance Officer**: Oversees policy implementation and ensures that all sanitization actions are in line with regulatory requirements.
- **Employees**: Must adhere to the procedures outlined in this policy and report any deviations or incidents related to media sanitization.

## Evidence Collection Methods

1. **REQUIREMENT**: Document all sanitization actions performed on media.
2. **MACHINE ATTESTATION**: 
   - Utilize automated tools to log sanitization processes, including timestamps and methods used. 
   - Ensure logs are ingested into Surveilr for real-time compliance monitoring.
3. **HUMAN ATTESTATION**: 
   - Employees must complete a sanitization checklist upon disposal of media, noting the method used and confirming that it meets organizational standards.
   - The checklist must be submitted and documented in Surveilr within 24 hours of the media sanitization.

## Verification Criteria

Compliance will be verified through the following criteria:
- 100% of media sanitization actions must be logged and tagged within Surveilr.
- At least 95% of sanitization checklists must be submitted within the specified **Action Verb + Frequency** of 24 hours post-sanitization.
- An **Annual Review** of sanitization records must show that all actions align with the required practices and standards.

## Exceptions

Exceptions to this policy must be documented and approved by the Compliance Officer. Any approved exceptions must include a justification and a plan for mitigating risks associated with the exception.

## Lifecycle Requirements

All sanitization records must be retained for a minimum of **Data Retention** period of five years. The policy must undergo an **Annual Review** to ensure that it remains current and effective.

## Formal Documentation and Audit

All workforce members involved in media sanitization must acknowledge their understanding of this policy and their responsibilities. Comprehensive audit logs must be maintained for all critical actions related to media sanitization, including access to sanitization records and any deviations from standard processes.

## References

- CMMC Control MA.L2-3.7.3
- FII-SCF-DCH-0009
- MP.L1-3.8.3