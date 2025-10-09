---
title: "Automated Inactive Account Disabling Policy"
weight: 1
description: "Establishes automated processes to disable inactive user accounts, enhancing security and compliance with CMMC control IA.L2-3.5.6."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "IA.L2-3.5.6"
control-question: "Does the organization use automated mechanisms to disable inactive accounts after an organization-defined time period?"
fiiId: "FII-SCF-IAC-0015.3"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction

The purpose of this policy is to establish guidelines for the automated disabling of inactive user accounts as required by the CMMC control IA.L2-3.5.6. This control emphasizes the importance of maintaining an effective identification and authentication process by ensuring that inactive accounts are systematically disabled, thereby minimizing potential security risks.

## Policy Statement

The organization commits to using automated mechanisms to disable inactive accounts within a defined period of inactivity. This policy mandates the implementation of machine attestation methods to ensure compliance and security while defining human attestation where automation is not feasible.

## Scope

This policy applies to all user accounts across the organization, including but not limited to:
- On-premises systems
- Cloud-hosted environments
- Software as a Service (SaaS) applications
- Third-party vendor systems

All employees, contractors, and third-party users with access to the organization's information systems are subject to this policy.

## Responsibilities

- **IT Security Team**: Responsible for implementing and maintaining automated tools for account management, ensuring compliance with this policy.
- **System Administrators**: Tasked with monitoring account activity and executing the disabling of inactive accounts.
- **IT Manager**: Responsible for conducting a quarterly review of user accounts and signing off on the review documentation.
- **Compliance Officer**: Ensures adherence to policy requirements and oversees the **Annual Review** process.

## Evidence Collection Methods

### 1. REQUIREMENT:
The organization must disable inactive accounts after a defined period.

### 2. MACHINE ATTESTATION:
- Use **OSquery** daily to collect and analyze user account activity data.
- Implement scripts that automatically disable accounts after 90 days of inactivity.
- Configure system alerts to notify administrators of accounts approaching the inactivity threshold.

### 3. HUMAN ATTESTATION:
- The IT Manager must sign the quarterly user account review report, documenting the review of all active and inactive accounts.
- Ensure that a record of this signed report is stored in Surveilr for compliance tracking.

## Verification Criteria

Compliance with this policy will be validated through:
- Automated reports generated from OSquery indicating the status of user accounts (active vs. inactive).
- Evidence of account disabling actions logged and monitored by the IT Security Team.
- Signed quarterly reports from the IT Manager confirming the review of accounts, with a target of achieving a 100% completion rate on the **Action Verb + Frequency** of reviews.

## Exceptions

Any exceptions to this policy must be documented and approved by the Compliance Officer. Exceptions will be reviewed during the **Annual Review** process and must include justification and a defined time frame for resolution.

## Lifecycle Requirements

- **Data Retention**: All logs related to user account activity must be retained for a minimum of 2 years.
- **Review Frequency**: This policy must be reviewed at least **annually** to ensure continued compliance and effectiveness.

## Formal Documentation and Audit

All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logs must be maintained to track user account activities and any exceptions that occur.

## References

- [CMMC Framework](https://www.acq.osd.mil/cmmc/)
- [NIST SP 800-53 Security and Privacy Controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [OSquery Documentation](https://osquery.io/docs/)