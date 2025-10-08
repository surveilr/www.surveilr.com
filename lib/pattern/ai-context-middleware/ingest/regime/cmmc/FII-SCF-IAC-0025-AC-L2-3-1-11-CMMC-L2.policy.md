---
title: "Automated User Session Logout Policy"
weight: 1
description: "Implement automated logout mechanisms to enhance security and compliance by preventing unauthorized access after user inactivity across all organizational systems."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.11"
control-question: "Does the organization use automated mechanisms to log out users, both locally on the network and for remote sessions, at the end of the session or after an organization-defined period of inactivity?"
fiiId: "FII-SCF-IAC-0025"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction

The purpose of this policy is to ensure compliance with the CMMC control AC.L2-3.1.11, which mandates the implementation of automated mechanisms to log out users after the completion of their sessions or after a predefined period of inactivity. This policy provides guidelines for the effective management of user sessions, ensuring security and compliance across all organizational environments.

## Policy Statement

The organization shall utilize automated mechanisms to log out users at the end of their session or after a defined period of inactivity. This policy applies to all user accounts across on-premises, cloud-hosted systems, SaaS applications, and third-party vendor systems to protect against unauthorized access and data breaches.

## Scope

This policy applies to all employees, contractors, and third-party users who access organizational information systems, including:

- On-premises networks
- Cloud-hosted environments
- SaaS applications
- Third-party vendor systems

The policy encompasses all user sessions and inactivity logout requirements.

## Responsibilities

- **IT Security Team**: 
  - **Action Verb + Frequency**: Configure and maintain automated logout mechanisms **monthly**.
  
- **System Administrators**:
  - **Action Verb + Frequency**: Monitor session activity logs **weekly** and report anomalies.
  
- **Compliance Officer**:
  - **Action Verb + Frequency**: Review policy compliance and effectiveness **quarterly**.

- **End Users**:
  - **Action Verb + Frequency**: Ensure they log out of systems when not in use **daily**.

These roles are linked to related organizational plans, including the Incident Response Plan and Access Control Policy.

## Evidence Collection Methods

1. **REQUIREMENT**: Implement automated logout mechanisms for user sessions.
   
2. **MACHINE ATTESTATION**: 
   - Utilize **OSquery** to collect session activity logs daily, which should include timestamps of user logins and logouts.
   - Automatically log user session end times and ingest this data into Surveilr for compliance verification.

3. **HUMAN ATTESTATION**: 
   - The IT manager must sign off on the quarterly review report of user logout compliance and submit it to Surveilr for audit purposes.

## Verification Criteria

- Compliance will be validated through the following **KPIs/SLAs**:
  - 100% of user sessions must be logged out automatically after 15 minutes of inactivity.
  - Session logs must be reviewed for compliance at least **monthly** with a target of a maximum of 3 non-compliance incidents identified per quarter.

## Exceptions

Any exceptions to this policy must be documented and require the approval of the Compliance Officer. Exception documentation must include:

- The rationale for the exception
- Duration of the exception period
- Mitigation measures to be taken during the exception period

All exception documentation must be ingested into Surveilr for tracking and auditing purposes.

## Lifecycle Requirements

- **Data Retention**: Session logs must be retained for a minimum of **one year**.
- Policy reviews and updates must occur on an **annual basis**, ensuring relevance and compliance with current standards and practices.

## Formal Documentation and Audit

All workforce members must acknowledge their understanding of this policy through electronic attestation. Comprehensive audit logging must be maintained for all user sessions, including:

- Login and logout timestamps
- Exception requests and approvals
- Compliance review reports

Formal documentation of all exceptions must also be maintained for auditing purposes.

## References

### References
None