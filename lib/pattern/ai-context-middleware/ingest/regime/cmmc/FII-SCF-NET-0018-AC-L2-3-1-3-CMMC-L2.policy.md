---
title: "Internet Traffic Filtering Policy for Security Compliance"
weight: 1
description: "Enforces routing of all Internet-bound traffic through a proxy for URL and DNS filtering to protect digital assets and ensure compliance."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.3"
control-question: "Does the organization force Internet-bound network traffic through a proxy device (e.g., Policy Enforcement Point (PEP)) for URL content filtering and DNS filtering to limit a user's ability to connect to dangerous or prohibited Internet sites?"
fiiId: "FII-SCF-NET-0018"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# CMMC Compliance Policy Document for Control AC.L2-3.1.3 (FII: FII-SCF-NET-0018)

## Introduction
This policy outlines the framework for enforcing Internet-bound network traffic through a proxy device for URL content filtering and DNS filtering. The aim is to safeguard the organization’s digital assets by limiting users' ability to connect to dangerous or prohibited Internet sites.

## Policy Statement
The organization mandates that all Internet-bound network traffic must be routed through a proxy device. This routing will enforce URL content filtering and DNS filtering to mitigate risks associated with accessing harmful websites and to ensure compliance with applicable regulations and standards.

## Scope
This policy applies to all employees, contractors, and third-party vendors who access the organization's network, including:
- On-premises systems
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit data

## Responsibilities
- **IT Security:** daily log review of proxy device activities.
- **Network Administrators:** weekly maintenance and updates of proxy configurations.
- **Compliance Officer:** monthly audit of filtering policies and procedures.
- **IT Manager:** quarterly review of filtered traffic logs and exceptions.

## Evidence Collection Methods
1. **REQUIREMENT:** All Internet-bound traffic must be routed through an approved proxy device for URL content and DNS filtering.
2. **MACHINE ATTESTATION:** Automated collection of logs from the proxy device will confirm filtering activities, ensuring compliance with the policy.
3. **HUMAN ATTESTATION:** The IT manager must sign off on the monthly review of filtered traffic logs to validate compliance.

## Verification Criteria
Compliance will be validated through the following **KPIs/SLAs**:
- 100% of Internet-bound traffic must pass through the proxy device.
- Review and approval of filtered traffic logs must occur monthly, with documented evidence of compliance.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. Each exception request must include justification and proposed alternative controls to mitigate associated risks.

## Lifecycle Requirements
- Logs and evidence must be retained for a minimum of **6 years**.
- The policy must be reviewed and updated at least **annually** to ensure it remains effective and relevant.

## Formal Documentation and Audit
All workforce members must acknowledge and attest to their understanding and compliance with this policy. Comprehensive audit logs must be maintained for all critical actions taken in relation to the proxy device. Formal documentation must be generated for all exceptions.

## References
- Cybersecurity Maturity Model Certification (CMMC) Framework
- National Institute of Standards and Technology (NIST) Guidelines
- Organizational Security Policies and Procedures