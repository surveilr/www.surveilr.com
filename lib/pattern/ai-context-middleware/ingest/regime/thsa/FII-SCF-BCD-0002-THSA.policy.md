---
title: "Critical Systems Documentation and Management Policy"
weight: 1
description: "Establishes requirements for identifying, documenting, and reviewing critical systems to ensure organizational resilience and effective business continuity planning."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "FII-SCF-BCD-0002"
control-question: "Does the organization identify and document the critical systems, applications and services that support essential missions and business functions?"
fiiId: "FII-SCF-BCD-0002"
regimeType: "THSA"
category: ["THSA", "Compliance"]
---

## Introduction
This policy outlines the requirements for identifying and documenting the critical systems, applications, and services that support essential missions and business functions. This is fundamental to ensuring the organization's resilience against disruptions and supports effective Business Continuity and Disaster Recovery (BCDR) planning.

## Policy Statement
The organization is committed to identifying and documenting all critical systems, applications, and services that are essential for the continuity of its operations. This documentation will be regularly reviewed and updated to reflect changes in the organizational landscape and operational requirements. 

## Scope
This policy applies to all organizational units, including but not limited to:
- On-premises systems
- Cloud-hosted environments
- Software as a Service (SaaS) applications
- Third-party vendor systems

All employees, contractors, and third-party service providers who manage or interact with these systems are subject to this policy.

## Responsibilities
- **IT Department**: 
  - **Action Verb + Frequency**: Conduct an inventory of critical systems semi-annually.
  - Ensure that all critical systems are documented and updated in the asset management database.
  
- **Business Unit Leaders**:
  - **Action Verb + Frequency**: Review and validate the critical systems list quarterly.
  - Report any changes in critical systems to the IT Department.

- **Compliance Team**:
  - **Action Verb + Frequency**: Audit critical systems documentation annually.
  - Ensure adherence to this policy and report findings to senior management.

## Evidence Collection Methods
- **Machine Attestation**:
  - Use **OSquery** to collect asset inventories daily and verify that all production systems are documented in the asset management database.
  - Automate the ingestion of OSquery data into Surveilr for real-time attestation of asset status.

- **Human Attestation**:
  - The IT Manager must sign off on the quarterly critical systems validation report, ensuring accuracy and completeness of the documentation.
  - Conduct an annual review meeting with stakeholders to discuss and validate the critical systems list.

## Verification Criteria
- Compliance will be measured against the following **KPIs/SLAs**:
  - 100% of critical systems must be documented within 30 days of identification.
  - Quarterly reviews must show at least 95% accuracy in documentation.
  - Annual audits must verify that no more than 5% of documented systems are outdated or incorrectly classified.

## Exceptions
Exceptions to this policy must be documented and approved by the Compliance Team. A formal request must be submitted, detailing the rationale and the duration for which the exception is sought. Exception requests must be reviewed within 5 business days.

## Lifecycle Requirements
- **Data Retention**: All documentation related to critical systems must be retained for a minimum of **3 years**.
- This policy will undergo an **Annual Review** to ensure its relevance and effectiveness, with updates made as necessary.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy annually. Audit logging will be maintained for all critical actions, including changes to the critical systems list. Documentation for any exceptions must be retained in accordance with the Data Retention policy.

## References
None.