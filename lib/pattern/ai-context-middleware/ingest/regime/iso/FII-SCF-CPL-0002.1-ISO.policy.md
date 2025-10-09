---
title: "Internal Audit Function Compliance Policy"
weight: 1
description: "Establishes an internal audit function to ensure compliance with ISO 27001:2022 standards for technology and information governance processes."
publishDate: "2025-10-01"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "FII-SCF-CPL-0002.1"
control-question: "Does the organization implement an internal audit function that is capable of providing senior organization management with insights into the appropriateness of its technology and information governance processes?"
fiiId: "FII-SCF-CPL-0002.1"
regimeType: "ISO"
category: ["ISO", "Compliance"]
---

## Internal Audit Function Policy

### Introduction
This policy outlines the mechanisms for implementing an internal audit function capable of providing senior management with insights into the appropriateness of the organization's technology and information governance processes. The policy aims to ensure compliance with ISO 27001:2022 standards, specifically focusing on the **Compliance** domain.

### Policy Statement
The organization commits to establishing and maintaining an effective internal audit function that regularly assesses technology and information governance processes, ensuring they align with both regulatory requirements and organizational objectives.

### Scope
This policy applies to:
- All **cloud-hosted systems**
- **SaaS applications**
- **Third-party vendor systems**
- All channels used to create, receive, maintain, or transmit information within the organization

### Responsibilities
- **Compliance Officer**: 
  - Conducts audits **quarterly** and ensures findings are documented and reviewed.
  
- **Internal Audit Team**: 
  - Prepares internal audit program documentation **annually**.
  
- **Senior Management**: 
  - Reviews audit findings and action plans **monthly**.
  
- **IT Department**: 
  - Provides necessary access to systems and logs **upon request** for audit purposes.

### Evidence Collection Methods

1. **REQUIREMENT**: Establish an internal audit function that assesses technology and information governance.
   
2. **MACHINE ATTESTATION**: 
   - Use **OSquery** to collect system configuration details and logs related to internal audits **weekly**.
   - Automate the generation of audit reports from internal systems for review **monthly**.

3. **HUMAN ATTESTATION**: 
   - The Compliance Officer must sign the quarterly internal audit report. The signed report is uploaded to Surveilr with metadata (review date, reviewer name) **within one week** of completion.

### Verification Criteria
- Compliance will be validated through:
  - Quarterly audit reports submitted to senior management.
  - Evidence of signed compliance attestations from the Compliance Officer.
- **KPIs/SLAs**: 
  - 100% of audit findings addressed within **30 days** of report issuance.
  - Audit program documentation must be completed and reviewed **annually**.

### Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer and reported to senior management within **five business days** of occurrence.

### Lifecycle Requirements
- **Data Retention**: All audit logs and related documentation must be retained for a minimum of **three years**.
- **Annual Review**: This policy will be reviewed and updated **annually** to ensure continued relevance and compliance with applicable standards.

### Formal Documentation and Audit
All workforce members must acknowledge and attest to their understanding of this policy. Comprehensive audit logging of all critical actions must be maintained to ensure accountability and compliance.

### References
- ISO/IEC 27001:2022 Standard
- [ISO 27001 Documentation](https://www.iso.org/isoiec-27001-information-security.html)