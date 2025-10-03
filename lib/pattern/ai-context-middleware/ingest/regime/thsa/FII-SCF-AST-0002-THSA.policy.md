---
title: "Together.Health Asset Inventory Management Policy"
weight: 1
description: "Establishes and maintains a comprehensive inventory of all system components to ensure effective asset management and compliance with THSA control FII-SCF-AST-0002."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "FII-SCF-AST-0002"
control-question: "Does the organization inventory system components that:
 ▪ Accurately reflects the current system; 
 ▪ Is at the level of granularity deemed necessary for tracking and reporting;
 ▪ Includes organization-defined information deemed necessary to achieve effective property accountability; and
 ▪ Is available for review and audit by designated organizational officials?"
fiiId: "FII-SCF-AST-0002"
regimeType: "THSA"
category: ["THSA", "Compliance"]
---

# Together.Health Security Assessment (THSA) Compliance Policy for Control: FII-SCF-AST-0002

## Introduction
The purpose of this policy is to ensure that the organization maintains an accurate and comprehensive inventory of all system components. This inventory is critical for effective asset management and property accountability, aligning with the requirements of the Together.Health Security Assessment (THSA) control FII-SCF-AST-0002. This policy outlines the methods for inventory management, focusing on both machine and human attestation.

## Policy Statement
The organization will inventory all system components to maintain an up-to-date and accurate record that reflects the current state of assets. This inventory will be detailed enough to support accountability and will be subject to regular reviews and audits as mandated by organizational requirements.

## Scope
This policy applies to all organizational entities, environments, and systems, including but not limited to:
- On-premises servers and devices
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems

## Responsibilities
- **IT Security Team**: Responsible for the implementation and maintenance of the inventory system, including regular updates and audits.
- **System Owners**: Required to ensure their systems are accurately represented in the inventory.
- **Compliance Officer**: Oversees adherence to this policy and ensures periodic reviews and updates.

## Evidence Collection Methods

### 1. REQUIREMENT:
The organization must maintain an accurate inventory of system components that reflects the current system status.

### 2. MACHINE ATTESTATION:
- **Daily Collection**: Utilize OSquery to collect and update asset inventories daily.
- **Automated Alerts**: Configure alerts for any discrepancies detected in the asset inventory.

### 3. HUMAN ATTESTATION:
- **Quarterly Review**: The IT manager must sign off on the quarterly asset inventory report, confirming its accuracy.
- **Documentation Submission**: Submit signed reports into Surveilr for compliance tracking.

## Verification Criteria
- Inventory must be updated daily with no discrepancies exceeding 24 hours.
- Quarterly reviews must result in a signed document available in Surveilr within 5 business days post-review.
- Any outstanding discrepancies must be resolved within a 14-day resolution period.

## Exceptions
Any exceptions to this policy must be documented and formally approved by the Compliance Officer. All exceptions must be logged in Surveilr with supporting justification.

## Lifecycle Requirements
- **Data Retention**: All inventory logs and reports must be retained for a minimum of 3 years.
- **Annual Review**: This policy must be reviewed and updated annually to ensure compliance with evolving organizational needs and standards.

## Formal Documentation and Audit
All workforce members must acknowledge understanding and compliance with this policy. Comprehensive audit logging must be maintained for all critical actions related to inventory management. Formal documentation of any exceptions must be preserved and reviewed during audits.

## References
- [NIST SP 800-53](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r5.pdf)
- [ISO/IEC 27001](https://www.iso.org/isoiec-27001-information-security.html)
- [SANS Institute](https://www.sans.org/)
- [CIS Controls](https://www.cisecurity.org/controls/)
- [Surveilr Documentation](https://surveilr.com/docs)