---
title: "Secure Remote Access Policy for ePHI Protection"
weight: 1
description: "Establishes secure remote access methods to protect ePHI, ensuring compliance through defined approval processes and regular audits."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.12"
control-question: "Does the organization define, control and review organization-approved, secure remote access methods?"
fiiId: "FII-SCF-NET-0014"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# Policy Document for Control: AC.L2-3.1.12 (FII: FII-SCF-NET-0014)

## Introduction
The purpose of this policy is to establish the requirements for defining, controlling, and reviewing organization-approved secure remote access methods to ensure the confidentiality, integrity, and availability of sensitive information, including electronic Protected Health Information (ePHI). This policy aligns with the CMMC control AC.L2-3.1.12 and establishes a framework for machine and human attestation of compliance.

## Policy Statement
The organization shall define, implement, and review secure remote access methods that protect ePHI from unauthorized access. All remote access methods must be approved by the designated authority and must adhere to the organization’s security standards. This includes ensuring that remote access is both **SMART** and validated through automated and human attestation processes.

## Scope
This policy applies to all employees, contractors, and third-party vendors with access to organization systems. It covers:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities
- **IT Security Manager + Annually**: Review and approve secure remote access methods.
- **Network Administrators + Monthly**: Monitor remote access logs and report anomalies.
- **All Workforce Members + Upon Hire**: Complete training on remote access security requirements.
- **Compliance Officer + Quarterly**: Conduct audits of remote access methods and report findings.

## Evidence Collection Methods
1. **REQUIREMENT:** Define and control secure remote access methods.
   
2. **MACHINE ATTESTATION:** 
   - Use **OSquery** to collect endpoint configuration data to validate approved remote access tools.
   - Implement automated log collection from remote access servers to ensure compliance with security configurations.

3. **HUMAN ATTESTATION:** 
   - Workforce members shall submit a signed acknowledgment form upon approval of remote access methods.
   - Conduct quarterly reviews of access logs by designated personnel to compare against approved methods.

## Verification Criteria
Compliance with this policy will be validated based on the following **KPIs/SLAs**:
- 100% of remote access methods must be documented and approved annually.
- 95% of remote access logs must be reviewed within 48 hours of access.
- 100% completion of training for all workforce members within one month of hiring.

## Exceptions
Exceptions to this policy may be granted on a case-by-case basis. Requests for exceptions must be documented and submitted to the IT Security Manager for approval. All exceptions will be reviewed during the **Annual Review** cycle.

## Lifecycle Requirements
- **Data Retention**: All logs and evidence related to remote access methods must be retained for **6 years** to comply with regulatory requirements.
- **Policy Review Frequency**: This policy must be reviewed at least **annually** to ensure it remains relevant and effective.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logs will be maintained for all critical actions related to remote access methods. Any exceptions must be documented formally and reviewed during audits.

### References
None