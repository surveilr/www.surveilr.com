---
title: "Access Control Policy for Facility Security"
weight: 1
description: "Establishes and maintains a current list of personnel authorized to access organizational facilities to ensure effective security control."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "PE.L1-3.10.1"
control-question: "Does the organization maintain a current list of personnel with authorized access to organizational facilities (except for those areas within the facility officially designated as publicly accessible)?"
fiiId: "FII-SCF-PES-0002"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# Policy for Physical & Environmental Security Control

## Introduction
This policy outlines the requirements for maintaining an up-to-date list of personnel with authorized access to organizational facilities, in compliance with the CMMC Physical & Environmental Security domain. The purpose of this document is to ensure that all access to facilities containing sensitive information is controlled and monitored effectively.

## Policy Statement
The organization shall maintain a current list of personnel authorized to access organizational facilities. This list will be reviewed regularly to ensure accuracy and compliance with security requirements.

## Scope
This policy applies to:
- All employees and contractors with access to organizational facilities.
- Cloud-hosted systems, SaaS applications, and third-party vendor systems.
- All channels used to create, receive, maintain, or transmit electronic protected health information (ePHI).

## Responsibilities
- **Facilities Manager**: Responsible for maintaining the list of authorized personnel and ensuring access controls are enforced.
- **IT Security Officer**: Responsible for conducting regular audits of access controls and ensuring compliance with this policy.
- **HR Department**: Responsible for notifying the Facilities Manager of any personnel changes affecting access rights.

## Evidence Collection Methods
### 1. REQUIREMENT:
Maintain an updated record of all personnel authorized to access organizational facilities.

### 2. MACHINE ATTESTATION:
- Use **OSquery** to automatically generate a list of authorized personnel with access to facilities every **30 days**.
- Implement an automated alert system to notify the Facilities Manager of any unauthorized access attempts.

### 3. HUMAN ATTESTATION:
- The Facilities Manager must review and update the access list quarterly, documenting changes in a report that must be signed off by the IT Security Officer.
- The HR Department must provide a monthly report of new hires and terminations to the Facilities Manager.

## Verification Criteria
- Compliance with this policy will be measured by:
  - The existence of an updated access list reviewed **quarterly**.
  - Successful completion of automated evidence collection via OSquery with a **100%** success rate.
  - Documentation of personnel changes reported by HR every month.

## Exceptions
Any exceptions to this policy must be documented and approved by the IT Security Officer. Documentation must include the reason for the exception and the duration for which it is valid.

## Lifecycle Requirements
- **Data Retention**: Access logs and personnel lists must be retained for a minimum of **five years**.
- Policies must be reviewed and updated at least **annually** to ensure compliance with current security standards and practices.

## Formal Documentation and Audit
- All workforce members must acknowledge their understanding of this policy via a documented signature.
- Comprehensive audit logs of all access control changes must be maintained.
- Any exceptions must be formally documented and reviewed.

## References
None