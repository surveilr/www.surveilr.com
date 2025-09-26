---
title: "Organizational Chart Policy"
weight: 1
description: "Establishes guidelines for maintaining an organizational chart with a detailed revision history for transparency and accountability."
publishDate: "2025-09-26"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "CC1-0003"
control-question: "Organizational chart with revision history"
fiiId: "FII-SCF-HRS-0003"
regimeType: "SOC2-TypeII"
category: ["SOC2-TypeII", "Compliance"]
---

# Organizational Chart with Revision History Policy

## Introduction
This policy establishes the framework for maintaining an organizational chart with a detailed revision history to ensure transparency, clarity of roles, and accountability within the organization. The organizational chart serves as a critical resource for understanding the structure and reporting lines of the organization, as well as facilitating compliance with regulatory requirements. The policy outlines both **machine attestation** and **human attestation** methods to validate compliance with this control.

## Policy Statement
All organizational charts must be maintained with a comprehensive revision history to document changes in structure and personnel. The organizational chart must be accessible, updated regularly, and stored in a manner that allows for both **machine attestation** and **human attestation**.

## Scope
This policy applies to all employees, departments, and third-party vendors across all environments, including:
- On-premises systems
- Cloud-hosted systems
- SaaS applications
- External vendor systems

## Responsibilities
- **HR Department**: Responsible for creating and updating the organizational chart and its revision history.
- **IT Department**: Responsible for implementing automated evidence collection methods and ensuring the chart is stored securely.
- **Compliance Officer**: Responsible for conducting annual reviews and audits of the organizational chart and its revision history.

## Evidence Collection Methods
- **Machine Attestation**:
  - Use **OSquery** to collect configuration details related to the organizational chart storage and access logs.
  - Implement **API integrations** to validate access controls and ensure only authorized personnel can modify the chart.
  - Schedule automated scripts to check for updates to the chart every **quarter**.

- **Human Attestation**:
  - HR personnel must sign off on changes to the organizational chart and document the date and outcome of the review within **Surveilr**.

## Verification Criteria
- Compliance will be validated based on:
  - **Audit logs** showing updates to the organizational chart.
  - Signed attestations from HR personnel on changes, reviewed **quarterly**.
  - Accessibility audits confirming that authorized personnel can access the latest version of the chart.

## Exceptions
Exceptions to this policy must be documented formally, including the rationale and approval from the Compliance Officer. A record of exceptions must be retained for a minimum of **five years**.

## Lifecycle Requirements
- **Data Retention**: All evidence and logs related to organizational chart changes must be retained for a minimum of **five years**.
- **Annual Review**: This policy and the organizational chart must be reviewed annually to ensure relevance and compliance.

## Formal Documentation and Audit
- All workforce members must acknowledge their understanding of this policy through signed documentation.
- Comprehensive audit logging must occur for all critical actions related to the organizational chart.
- Documentation of any exceptions must be maintained and reviewed during audits.

## References
None