---
title: "Access Control for Privileged Users Policy"
weight: 1
description: "Limit access to security functions to authorized privileged users while ensuring documentation, monitoring, and regular reviews to maintain compliance and security."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.5"
control-question: "Does the organization limit access to security functions to explicitly-authorized privileged users?"
fiiId: "FII-SCF-IAC-0021.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction

This policy establishes guidelines for limiting access to security functions within the organization to explicitly authorized privileged users, as mandated by CMMC Control AC.L2-3.1.5. Proper management of access to security functions is vital to maintain the integrity, confidentiality, and availability of sensitive data, including electronic protected health information (ePHI). This policy outlines the methods for machine and human attestation to ensure compliance and security.

## Policy Statement

The organization shall limit access to security functions to authorized privileged users only. All access must be documented, monitored, and reviewed regularly to prevent unauthorized access and to ensure accountability.

## Scope

This policy applies to all organizational entities and environments, including:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities

- **IT Security Team**: 
  - **Monitor** access controls **daily**.
  - **Review** access logs for anomalies **weekly**.
  - **Implement** access control measures **as needed**.
  
- **Compliance Officer**:
  - **Conduct** quarterly audits of access controls.
  - **Review** and update policies **annually**.
  
- **Department Managers**:
  - **Authorize** access requests **within 24 hours**.
  - **Sign** access control review reports **quarterly**.

## Evidence Collection Methods

1. **REQUIREMENT**: Limit access to security functions to authorized privileged users.
   
   2. **MACHINE ATTESTATION**:
   - Utilize **OSquery** to automatically collect access logs daily and identify access attempts by unauthorized users.
   - Implement **identity and access management (IAM)** tools to enforce multi-factor authentication (MFA) for all privileged access.
   
   3. **HUMAN ATTESTATION**:
   - Department Managers must **review** and **sign** quarterly access control review reports, detailing privileged access and any anomalies found. These documents will be ingested into Surveilr as part of the compliance evidence.

## Verification Criteria

- **Successful** access control audits must result in no unauthorized access attempts logged over a **30-day period**.
- Quarterly access review reports must be signed and submitted by all Department Managers within **5 business days** after the end of the quarter.
- Compliance with access control measures must be validated during annual audits.

## Exceptions

Any exceptions to this policy must be documented and approved by the Compliance Officer. Such exceptions will be formally recorded and reviewed during the annual policy review.

## Lifecycle Requirements

- **Data Retention**: All access logs must be retained for a minimum of **3 years**.
- The policy must undergo an **Annual Review** to ensure relevance and effectiveness.

## Formal Documentation and Audit

All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logging must capture critical actions related to access control. Any exceptions to this policy must be formally documented and reviewed.

## References

None