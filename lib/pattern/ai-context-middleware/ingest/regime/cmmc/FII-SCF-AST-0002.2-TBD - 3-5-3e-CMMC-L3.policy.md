---
title: "Automated Detection of Unauthorized Components Policy"
weight: 1
description: "Implement automated detection and alerting mechanisms to identify unauthorized hardware, software, and firmware components, ensuring asset integrity and compliance."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "TBD - 3.5.3e"
control-question: "Does the organization use automated mechanisms to detect and alert upon the detection of unauthorized hardware, software and firmware components?"
fiiId: "FII-SCF-AST-0002.2"
regimeType: "CMMC"
cmmcLevel: 3
domain: "Asset Management"
category: ["CMMC", "Level 3", "Compliance"]
---

# CMMC Policy Document for Control: TBD - 3.5.3e

## Introduction
The purpose of this policy is to establish guidelines for the automated detection and alerting of unauthorized hardware, software, and firmware components within the organization. This policy aligns with CMMC control TBD - 3.5.3e and is essential for maintaining the integrity and security of our asset management processes.

## Policy Statement
The organization shall implement automated mechanisms to detect and alert upon the detection of unauthorized hardware, software, and firmware components. This includes the use of machine attestation methods to ensure compliance and the establishment of human attestation processes where automation is impractical.

## Scope
This policy applies to all organizational entities and environments, including but not limited to:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit electronic Protected Health Information (**ePHI**)

## Responsibilities
- **IT Security Team**: 
  - Implement and maintain automated detection mechanisms.
  - Conduct regular reviews of detection logs.
- **Compliance Officer**: 
  - Ensure adherence to policy requirements and facilitate annual reviews.
- **Department Managers**: 
  - Oversee human attestation processes and ensure staff compliance.

## Evidence Collection Methods

### 1. REQUIREMENT:
Automated detection of unauthorized components.

### 2. MACHINE ATTESTATION:
- Use **OSquery** to collect and analyze system inventories daily.
- Implement continuous monitoring tools that generate alerts for unauthorized changes in software and firmware.

### 3. HUMAN ATTESTATION:
- Department managers must sign a quarterly report validating the integrity of asset inventories, which will be submitted to the Compliance Officer for ingestion into Surveilr.

### 1. REQUIREMENT:
Alerting mechanisms for unauthorized components.

### 2. MACHINE ATTESTATION:
- Configure automated alerts through the asset management system to notify the IT Security Team within **5 minutes** of detecting unauthorized components.

### 3. HUMAN ATTESTATION:
- Conduct a monthly review meeting to discuss alert responses and document findings in a report, which will be uploaded to Surveilr.

## Verification Criteria
- Compliance will be validated through the following **SMART** criteria:
  - **100%** of unauthorized component alerts must be acknowledged and addressed within **1 hour** (KPI).
  - Quarterly inventory validation reports must be submitted on time, with a **minimum** of **95%** compliance rate (SLA).

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. Documentation must include the rationale for the exception and will be reviewed during the **Annual Review**.

## Lifecycle Requirements
- **Data Retention**: All logs and evidence related to unauthorized component detection must be retained for a minimum of **3 years**.
- Policy reviews and updates must occur at least **annually** to ensure continued relevance and compliance.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logs must be maintained for all critical actions, and formal documentation must be kept for all exceptions.

## References
- [CMMC Framework](https://www.acq.osd.mil/cmmc) 
- [OSquery Documentation](https://osquery.io/docs/) 
- [Surveilr Compliance Management](https://www.surveilr.com) 

This policy is effective immediately and will be reviewed annually to ensure compliance with CMMC standards and organizational requirements.