---
title: "Network Segmentation Policy for ePHI Security"
weight: 1
description: "Establishes robust network segmentation practices to protect ePHI and ensure compliance with regulatory standards."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "SC.L1-3.13.5"
control-question: "Does the organization ensure network architecture utilizes network segmentation to isolate systems, applications and services that protections from other network resources?"
fiiId: "FII-SCF-NET-0006"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# Network Segmentation Policy for Control SC.L1-3.13.5 (FII: FII-SCF-NET-0006)

## Introduction
This policy establishes the framework for network segmentation within the organization to ensure the isolation of systems, applications, and services that handle electronic Protected Health Information (ePHI). Effective network segmentation is crucial for enhancing security posture, mitigating risks associated with unauthorized access, and ensuring compliance with regulatory requirements. By implementing stringent segmentation practices, the organization can safeguard sensitive data and maintain trust with stakeholders.

## Policy Statement
The organization is committed to implementing robust network segmentation strategies to isolate and protect systems, applications, and services that process, store, or transmit ePHI. This commitment includes adhering to best practices and regulatory standards to ensure the integrity and confidentiality of sensitive information.

## Scope
This policy applies to all organizational assets, including:
- Cloud-hosted systems
- Software-as-a-Service (SaaS) applications
- Third-party vendor systems (Business Associates)
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities
- **Compliance Officer: Review and approve the policy quarterly.**
- **IT Security: Review network logs daily for unauthorized access attempts.**
- **Network Architect: Validate network segmentation configurations semi-annually.**
- **System Administrators: Implement segmentation changes as required, upon identification of risks.**

## Evidence Collection Methods
1. **REQUIREMENT:**
   The organization requires that network architecture is designed to utilize segmentation effectively, isolating systems, applications, and services that handle ePHI from other network resources.

2. **MACHINE ATTESTATION:**
   Utilize OSquery to validate network configurations and segmentation settings daily. Automated scripts must be developed and scheduled to run daily, with outputs logged.

3. **HUMAN ATTESTATION:**
   The Network Architect must sign the quarterly segmentation validation report. This report must be uploaded to Surveilr with appropriate metadata, including the date, author, and scope of validation.

## Verification Criteria
Compliance will be validated based on the following measurable criteria:
- Daily machine attestations confirming correct network segmentation configurations.
- Quarterly human attestations submitted and logged in Surveilr.
- No unauthorized access attempts detected in daily log reviews.

## Exceptions
Any exceptions to this policy must be documented in writing and approved by the Compliance Officer. The documentation must include the rationale for the exception and an expiration date. Exception requests must be submitted at least 30 days prior to the anticipated need for an exception.

## Lifecycle Requirements
- **Data Retention:** Evidence and logs related to network segmentation must be retained for a minimum of six years.
- **Annual Review:** This policy and associated evidence must be reviewed at least annually to ensure ongoing compliance and relevance.

## Formal Documentation and Audit
All workforce members must acknowledge and attest to their understanding of this policy. Comprehensive audit logs must be maintained for all critical actions, including changes to network segmentation. Documentation for all exceptions must be formally recorded and accessible for audit.

### References
None