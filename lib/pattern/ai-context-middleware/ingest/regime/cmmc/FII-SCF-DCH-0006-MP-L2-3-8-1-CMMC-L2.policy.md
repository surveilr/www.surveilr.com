---
title: "Media Control and Secure Storage Policy"
weight: 1
description: "Establishes secure protocols for the physical control and storage of digital and non-digital media to comply with CMMC requirements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "MP.L2-3.8.1"
control-question: "Does the organization: 
 ▪ Physically control and securely store digital and non-digital media within controlled areas using organization-defined security measures; and
 ▪ Protect system media until the media are destroyed or sanitized using approved equipment, techniques and procedures?"
fiiId: "FII-SCF-DCH-0006"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

# CMMC Compliance Policy for Control MP.L2-3.8.1

## Introduction
In alignment with the Cybersecurity Maturity Model Certification (CMMC) requirements, this policy outlines the controls necessary for the physical control and secure storage of digital and non-digital media. It ensures that all media is adequately protected until destruction or sanitization using organization-defined security measures. This policy aims to enhance data classification and handling practices across the organization.

## Policy Statement
The organization shall physically control and securely store digital and non-digital media within controlled areas. It shall implement approved equipment, techniques, and procedures to protect system media until it is destroyed or sanitized, thereby ensuring compliance with CMMC control MP.L2-3.8.1.

## Scope
This policy applies to:
- All organizational facilities.
- Digital media (e.g., hard drives, USB drives, cloud storage).
- Non-digital media (e.g., printed documents, tapes).
- Cloud-hosted systems.
- Software as a Service (SaaS) applications.
- Third-party vendor systems.

## Responsibilities
- **Security Team**: 
  - Conduct **monthly** assessments of media storage practices.
  - Implement and update security measures as needed.
  
- **IT Department**: 
  - Ensure that all media is stored in controlled areas **weekly**.
  - Document and maintain an inventory of all stored media.

- **Compliance Officer**: 
  - Review policy adherence and report findings **quarterly**.
  - Facilitate **annual reviews** of the policy to ensure its effectiveness.

## Evidence Collection Methods

1. **REQUIREMENT**: Physical control and secure storage of media.
   - **MACHINE ATTESTATION**: Utilize OSquery to monitor storage locations and access logs for digital media. Automate alerts for unauthorized access attempts.
   - **HUMAN ATTESTATION**: Security personnel will conduct and document physical inspections of storage areas, logging findings in Surveilr. Inspection reports must be submitted within 24 hours of the inspection.

2. **REQUIREMENT**: Protection of media until destruction or sanitization.
   - **MACHINE ATTESTATION**: Implement automated logging of media handling activities through API integrations with security hardware that tracks access and modifications.
   - **HUMAN ATTESTATION**: Staff responsible for handling media must complete a checklist of approved equipment and techniques used for sanitization or destruction. This checklist must be submitted to Surveilr within 48 hours post-activity.

## Verification Criteria
Compliance will be validated through:
- **Monthly** reports generated from OSquery data.
- Timely submission of inspection and handling checklists.
- Completeness of media inventory, verified against physical counts.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. Documentation of exceptions will be reviewed during **annual audits** to determine if adjustments to the policy are necessary.

## Lifecycle Requirements
- Evidence and logs must be retained for a minimum of **three years**.
- This policy will undergo a formal review and update **annually**, or as required by changes in regulations or operational procedures.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding of this policy and their commitment to compliance. Comprehensive audit logs will be maintained for all critical actions related to media control and protection. Documentation of exceptions must be formally recorded and reviewed as part of the audit process.

## References
None