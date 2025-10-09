---
title: "Consecutive Invalid Login Attempts Policy"
weight: 1
description: "Enforces account lockout procedures to limit consecutive invalid login attempts, enhancing security and preventing unauthorized access to sensitive information."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.8"
control-question: "Does the organization enforce a limit for consecutive invalid login attempts by a user during an organization-defined time period and automatically locks the account when the maximum number of unsuccessful attempts is exceeded?"
fiiId: "FII-SCF-IAC-0022"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

# Policy for Control: AC.L2-3.1.8 (FII: FII-SCF-IAC-0022)

## Introduction
This policy outlines the requirements for limiting consecutive invalid login attempts and implementing account lockout procedures to enhance security within the organization. It is designed to comply with the CMMC control AC.L2-3.1.8 and ensure that user authentication processes are robust, minimizing the risk of unauthorized access.

## Policy Statement
The organization enforces a strict limit on consecutive invalid login attempts by a user. Accounts will be automatically locked after a specified number of unsuccessful attempts within a defined time period. This policy aims to mitigate the risk of brute force attacks and unauthorized access to sensitive information.

## Scope
This policy applies to all user accounts across all relevant environments, including:
- On-premises systems
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems related to user authentication

## Responsibilities
- **Compliance Officer**: 
  - Review and ensure adherence to the account lockout policy **annually**.
  - **Action Verb + Frequency**: Conduct policy training sessions **biannually**.
  
- **IT Security Personnel**: 
  - Configure account lockout settings and monitor compliance **weekly**.
  - **Action Verb + Frequency**: Generate and review account lockout reports **monthly**.

- **System Administrators**: 
  - Implement technical controls for account lockout enforcement **immediately** upon policy enforcement.
  - **Action Verb + Frequency**: Address any identified security vulnerabilities **within 24 hours**.

## Evidence Collection Methods
### MACHINE ATTESTATION
- Utilize **OSquery** to automate monitoring of account lockouts and generate reports of invalid login attempts.
- Configure alerts for multiple failed login attempts to enable real-time response.

### HUMAN ATTESTATION
- Require managerial approval of user account lockout logs when automation is impractical.
- Perform manual reviews of account lockout incidents **monthly** to ensure compliance and detect anomalies.

## Verification Criteria
- The system must lock accounts after **5 unsuccessful login attempts** within a **15-minute period**.
- Compliance will be measured against the following **KPIs/SLAs**:
  - 100% of accounts must adhere to the lockout policy.
  - All account lockouts must be logged and reviewed **within 24 hours**.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. Exception documentation must include:
- The reason for the exception
- Duration of the exception
- Remedial measures to be implemented

## Lifecycle Requirements
- **Data Retention**: All account lockout evidence must be retained for a minimum of **6 years**.
- The policy must be reviewed and updated at least **annually** to ensure it remains effective and compliant with relevant regulations.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding of this policy through a documented attestation. Additionally, comprehensive audit logs must be maintained for all critical actions related to account lockouts, including:
- Account lockout incidents
- Manual reviews and managerial approvals
- Any exceptions granted

## References
None