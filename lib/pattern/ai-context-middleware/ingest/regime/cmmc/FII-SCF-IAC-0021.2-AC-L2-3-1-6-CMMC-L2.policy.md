---
title: "Privileged Account Usage Security Policy"
weight: 1
description: "Enforces the prohibition of privileged users using privileged accounts for non-security functions to protect sensitive data and maintain compliance."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.6"
control-question: "Does the organization prohibit privileged users from using privileged accounts, while performing non-security functions?"
fiiId: "FII-SCF-IAC-0021.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

# CMMC Compliance Policy for Control AC.L2-3.1.6

## Introduction
This policy outlines the requirements for Control AC.L2-3.1.6, which mandates that the organization prohibits privileged users from using privileged accounts while performing non-security functions. Compliance with this policy ensures the integrity and security of sensitive data, specifically electronic Protected Health Information (ePHI).

## Policy Statement
The organization will implement strict protocols to prevent privileged users from engaging in non-security functions using privileged accounts. This includes defining roles, enforcing access controls, and establishing monitoring mechanisms to ensure compliance.

## Scope
This policy applies to all employees, contractors, and third-party service providers who have access to privileged accounts within the organization. It encompasses all environments where ePHI is stored, processed, or transmitted, including on-premises and cloud-based systems.

## Responsibilities
- **IT Security Team**: Implement and enforce access control measures.
- **Compliance Officer**: Monitor adherence to this policy and report violations.
- **All Employees**: Understand and comply with the policy regarding the use of privileged accounts.

## Evidence Collection Methods
### 1. REQUIREMENT:
Privileged users must not use privileged accounts for non-security functions.

### 2. MACHINE ATTESTATION:
- Implement automated logging of access events for privileged accounts.
- Use Security Information and Event Management (SIEM) systems to analyze logs for unauthorized access patterns.
- Employ user behavior analytics tools to identify anomalous activities.

### 3. HUMAN ATTESTATION:
- Conduct quarterly reviews where privileged users must sign an acknowledgment form confirming understanding and compliance with this policy. 
- The signed acknowledgment will be ingested into Surveilr as a PDF document.

## Verification Criteria
- **SMART** criteria will be established to measure compliance:
  - **Specific**: All privileged access must be logged.
  - **Measurable**: A minimum of 95% of all privileged access logs must be generated and reviewed monthly.
  - **Actionable**: Automated alerts for any non-compliance must be configured.
  - **Relevant**: Ensure all relevant privileged accounts are monitored.
  - **Time-bound**: Monthly reports will be generated to assess compliance.

## Exceptions
Any exceptions to this policy must be documented and formally approved by the Compliance Officer. Exceptions will be reviewed annually to determine their necessity.

## Lifecycle Requirements
- **Data Retention**: Logs related to privileged account access must be retained for a minimum of 5 years.
- Policy review and updates will occur on an **Annual Review** basis to ensure continued relevance and compliance.

## Formal Documentation and Audit
- All workforce members must acknowledge their understanding of this policy through documented attestation.
- Comprehensive audit logs will be maintained for all privileged account accesses and any exceptions granted.

## References
None