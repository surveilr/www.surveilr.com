---
title: "Session Lock Policy for ePHI Security Compliance"
weight: 1
description: "Establishes guidelines for implementing session locks to protect ePHI and ensure compliance with CMMC Control AC.L2-3.1.10."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.10"
control-question: "Does the organization initiate a session lock after an organization-defined time period of inactivity, or upon receiving a request from a user and retain the session lock until the user reestablishes access using established identification and authentication methods?"
fiiId: "FII-SCF-IAC-0024"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

# Session Lock Policy

## Introduction
The purpose of this policy is to establish guidelines for implementing session locks to protect sensitive information and ensure compliance with the CMMC Control AC.L2-3.1.10. Session locks help mitigate unauthorized access to systems that handle electronic Protected Health Information (ePHI) by automatically securing user sessions after a defined period of inactivity or upon user request.

## Policy Statement
Our organization is committed to implementing session locks in accordance with defined inactivity periods or user requests. All systems that handle ePHI will initiate a session lock to prevent unauthorized access until the user reestablishes access through recognized identification and authentication methods.

## Scope
This policy applies to all employees, contractors, and third-party vendors who access systems that handle ePHI. It encompasses all relevant environments, including:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities
- **IT Security**: Implement and monitor session lock mechanisms **monthly**.
- **Compliance Officer**: Conduct policy reviews and compliance checks **annually**.
- **End-Users**: Acknowledge understanding of session lock requirements during training **upon onboarding** and **annually thereafter**.

## Evidence Collection Methods
1. **REQUIREMENT**:
   The session lock requirement mandates that all systems must automatically lock after a period of inactivity defined by the organization (e.g., 15 minutes) or upon a user's request. The session lock must remain active until the user successfully authenticates to regain access.

2. **MACHINE ATTESTATION**:
   Automatable methods for validating session lock implementation include:
   - Use API integrations with identity management systems to verify session lock status.
   - Implement logging mechanisms to track session lock events triggered by inactivity or user requests.

3. **HUMAN ATTESTATION**:
   Human attestation will require:
   - Users to acknowledge understanding of the session lock policy in training logs.
   - Documentation of user compliance after each training session.

## Verification Criteria
Compliance validation will be based on the following criteria:
- Session locks must be initiated within 5 minutes of user inactivity.
- All session locks must be documented and verified through logs retained for auditing purposes.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. Requests for exceptions should include justification and a proposed alternative control measure.

## Lifecycle Requirements
- Session lock logs must be retained for a minimum of 6 years.
- This policy shall be reviewed and updated at least **annually** to ensure its effectiveness and compliance with evolving regulations and organizational needs.

## Formal Documentation and Audit
All workforce members must acknowledge and attest to their understanding and compliance with this policy. Comprehensive audit logging will be maintained for all critical actions related to session locks, and formal documentation will be kept for all exceptions granted.

### References
[Cybersecurity Maturity Model Certification (CMMC)](https://www.acq.osd.mil/cmmc/)