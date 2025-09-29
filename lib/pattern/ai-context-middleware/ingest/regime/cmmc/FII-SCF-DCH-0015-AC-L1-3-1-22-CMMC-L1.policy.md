---
title: "Public Access Content Security Policy"
weight: 1
description: "Establishes measures to control publicly-accessible content, safeguarding sensitive information and ensuring compliance with regulatory standards."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L1-3.1.22"
control-question: "Does the organization control publicly-accessible content?"
fiiId: "FII-SCF-DCH-0015"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Data Classification & Handling"
category: ["CMMC", "Level 1", "Compliance"]
---

# Policy Document for Control: AC.L1-3.1.22 (FII: FII-SCF-DCH-0015)

## Introduction
This policy outlines the requirements for controlling publicly-accessible content to ensure the protection of sensitive information, particularly electronic Protected Health Information (ePHI). The objective is to establish a framework for managing access to publicly accessible content while maintaining compliance with regulatory standards.

## Policy Statement
The organization shall implement measures to control publicly-accessible content, ensuring that sensitive information is not inadvertently disclosed. This includes the identification, classification, and management of content that is accessible to the public.

## Scope
This policy applies to all employees, contractors, and third-party vendors who create, receive, maintain, or transmit ePHI. It encompasses all environments, including:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems (Business Associates)
- All channels used for content dissemination

## Responsibilities
- **IT Security Team**: 
  - **Conduct quarterly audits** of publicly accessible content to ensure compliance with policy requirements.
  - **Implement automated tools** for monitoring and reporting on publicly accessible content.
  
- **Content Owners**: 
  - **Review and classify** content prior to publication, ensuring sensitive information is adequately protected.
  - **Update content classification** annually or upon significant changes.

- **Compliance Officer**: 
  - **Facilitate annual policy reviews** and updates based on regulatory changes or organizational needs.
  - **Ensure training** is provided to all relevant personnel on content management practices.

## Evidence Collection Methods

### 1. REQUIREMENT:
Control publicly-accessible content to prevent unauthorized disclosure of sensitive information.

### 2. MACHINE ATTESTATION:
- Use **OSquery** to automate the collection of data regarding publicly accessible content and ingest this data into **Surveilr** daily.
- Implement a script that verifies the presence of appropriate access controls on all web servers hosting publicly accessible content.

### 3. HUMAN ATTESTATION:
- The **Content Owner** must sign the **Content Classification Report** quarterly, confirming that all publicly accessible content has been reviewed and classified appropriately.
- The **Compliance Officer** must maintain a signed acknowledgment from each workforce member regarding their understanding of this policy.

## Verification Criteria
- Compliance will be validated through:
  - **Quarterly audits** showing 100% of publicly accessible content reviewed and classified.
  - **Daily automated reports** from OSquery indicating no unauthorized access to sensitive information.
  - **Signed reports** from Content Owners and Compliance Officers, maintained for audit purposes.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. A formal exception request must include:
- Justification for the exception
- Duration of the exception
- Mitigation measures in place to protect sensitive information

## Lifecycle Requirements
- **Data Retention**: All logs and evidence related to publicly accessible content must be retained for a minimum of **three years**.
- **Annual Review**: This policy must be reviewed and updated at least **annually** or as needed based on changes in regulations or organizational practices.

## Formal Documentation and Audit
- All workforce members must acknowledge their understanding and compliance with this policy through a signed attestation form.
- Comprehensive audit logs must be maintained for all critical actions related to publicly accessible content management.
- Documentation of any exceptions must be formally recorded and reviewed during audits.

## References
None