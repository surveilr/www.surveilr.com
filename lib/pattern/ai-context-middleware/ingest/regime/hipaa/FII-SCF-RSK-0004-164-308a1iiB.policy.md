---
title: "HIPAA 164.308(a)(1)(ii)(B) - Policy"
weight: 1
description: "Policy document for HIPAA control 164.308(a)(1)(ii)(B)"
publishDate: "2025-09-23"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "164.308(a)(1)(ii)(B)"
control-question: "Has the risk management process been completed using IAW NIST Guidelines? (R)"
fiiId: "FII-SCF-RSK-0004"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

# HIPAA Compliance Policy for Control Code 164.308(a)(1)(ii)(B)

## Introduction
This policy outlines the requirements for completing the risk management process in compliance with NIST guidelines, ensuring that adequate measures are in place to protect sensitive health information.

## Policy Statement
All entities covered under HIPAA regulations must implement a comprehensive risk management process that adheres to the NIST guidelines. This process is essential for identifying, assessing, and mitigating risks to the confidentiality, integrity, and availability of protected health information (PHI).

## Scope
This policy applies to all employees, contractors, and third-party service providers who handle PHI within the organization. It encompasses all systems and processes involved in risk management related to HIPAA compliance.

## Responsibilities
- **Compliance Officer**: Responsible for overseeing the risk management process and ensuring adherence to NIST guidelines.
- **IT Security Team**: Tasked with implementing machine attestation methods and maintaining compliance evidence.
- **Department Managers**: Required to ensure their teams conduct necessary risk assessments and provide human attestations when automation is not feasible.

## Evidence Collection Methods

### Explanation
The risk management process must be documented and evidenced to ensure compliance with HIPAA requirements. This includes both automated and manual methods of attestation.

### Machine Attestation
- **Endpoint Configuration**: Validate that all production servers have necessary security configurations by ingesting OSquery data into Surveilr. This data must be automatically collected and stored for future reference.
- **API Integrations**: Utilize API integrations with SaaS/cloud providers to confirm security measures are in place and functioning correctly.
- **Log Ingestion**: Automatically collect and store logs from critical systems to demonstrate adherence to risk management processes.

### Human Attestation (if unavoidable)
- **Quarterly Risk Assessment Reports**: The Compliance Officer must sign off on the quarterly risk assessment report. This document must then be uploaded to Surveilr, including metadata such as the reviewer's name, date, and outcome of the assessment.
- **Training Verification**: Managers must maintain signed HR training logs to confirm staff training on risk management policies and procedures.

## Verification Criteria
The risk management process will be considered complete when:
- All machine attestation evidence is stored within Surveilr and is verifiable.
- Human attestations are submitted and include all necessary metadata.
- A documented review of risks and mitigations is available for audits.

## Exceptions
Any exceptions to this policy must be formally documented and approved by the Compliance Officer. Exceptions will be reviewed on a case-by-case basis.

## References
- [NIST Special Publication 800-30](https://csrc.nist.gov/publications/detail/sp/800-30/rev-1/final) - Guide for Conducting Risk Assessments
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html) - Security Standards for the Protection of Electronic Protected Health Information

### _References_  
- NIST Special Publication 800-30  
- HIPAA Security Rule