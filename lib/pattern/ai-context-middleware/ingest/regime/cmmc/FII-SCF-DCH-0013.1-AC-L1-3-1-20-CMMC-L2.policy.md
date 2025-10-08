---
title: "**External Data Handling Security Policy**"
weight: 1
description: "Establishes guidelines to prevent external handling of sensitive data without verified security controls or formal processing agreements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L1-3.1.20"
control-question: "Does the organization prohibit external parties, systems and services from storing, processing and transmitting data unless authorized individuals first: 
 ▪ Verifying the implementation of required security controls; or
 ▪ Retaining a processing agreement with the entity hosting the external systems or service?"
fiiId: "FII-SCF-DCH-0013.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

```markdown
## Introduction

The purpose of this policy is to establish a framework that ensures the security and integrity of sensitive data by prohibiting external parties, systems, and services from storing, processing, or transmitting this data unless certain security controls are verified by authorized individuals or a processing agreement is retained. This policy aligns with the CMMC control AC.L1-3.1.20 and is crucial for maintaining compliance within the Data Classification & Handling domain.

## Policy Statement

It is the policy of this organization to strictly prohibit external parties, systems, and services from storing, processing, and transmitting data unless:

- **Authorized individuals** have verified the implementation of **required security controls**.
- A formal **processing agreement** is retained with the entity that hosts the external systems or services.

This ensures that all data handling practices comply with organizational standards and regulatory requirements.

## Scope

This policy applies to:

- All organizational entities that handle sensitive data.
- All environments, including on-premises and **cloud-hosted systems**.
- **SaaS** applications that process or store organizational data.
- All third-party vendors involved in the handling of sensitive data.

## Responsibilities

- **Data Owners**: 
  - Review and approve third-party processing agreements **annually**.
  - Ensure compliance with security control verification before data sharing.
  
- **IT Security Team**: 
  - Conduct security control assessments for external parties **bi-annually**.
  - Maintain records of verified security controls and agreements.
  
- **Compliance Officer**: 
  - Monitor adherence to policy and report violations **monthly**.
  - Facilitate training on this policy for relevant staff **quarterly**.

## Evidence Collection Methods

### 1. REQUIREMENT

The control requires that external entities do not process sensitive data without proof of verified security controls or a processing agreement.

### 2. MACHINE ATTESTATION

- **Automatable Method**: Use `OSquery` to collect asset inventories **daily** to ensure that all external systems are accounted for and validated.

### 3. HUMAN ATTESTATION

- **Specific Action**: Authorized personnel must complete a **Security Control Verification Checklist** for each external system.
- **Artifact**: Store completed checklists in a designated Surveilr folder.
- **Ingestion Method**: Upload the checklists into Surveilr using the automated ingestion tool bi-weekly.

## Verification Criteria

Compliance with this policy will be validated using the following **KPIs/SLAs**:

- **100% verification** of security controls for external systems prior to data processing.
- **Monthly audits** of third-party processing agreements to ensure they are current and compliant.
- **Annual review** of all policies related to data handling practices.

## Exceptions

Any exceptions to this policy must be documented and approved by the Compliance Officer. Documentation must include:

- Description of the exception
- Justification for the exception
- Duration for which the exception is granted

## Lifecycle Requirements

- **Data Retention**: Evidence and logs must be retained for a minimum of **three years**.
- Policy must be **reviewed annually** to ensure its relevance and effectiveness.

## Formal Documentation and Audit

All workforce members are required to acknowledge their understanding and compliance with this policy. Comprehensive audit logging must be maintained for all critical actions taken regarding data handling. Formal documentation is required for any exceptions, which includes:

- Approval signatures from relevant authorities.
- A detailed account of the circumstances surrounding the exception.

## References

- CMMC Control AC.L1-3.1.20
- FII Identifier: FII-SCF-DCH-0013.1
- Organizational Data Handling Guidelines
- Surveilr Documentation for Evidence Collection
```