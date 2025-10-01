---
title: "Change Management Policy for Information Systems"
weight: 1
description: "Establishes a framework for documenting, testing, and approving changes to information systems managing electronic Protected Health Information (ePHI)."
publishDate: "2025-09-30"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "06.09b1System.2"
control-question: "Changes to information systems (including changes to applications, databases, configurations, network devices, and operating systems and with the potential exception of automated security patches) are consistently documented, tested, and approved."
fiiId: "FII-SCF-CFG-0001"
regimeType: "HiTRUST"
category: ["HiTRUST", "Compliance"]
---

## Introduction

This policy addresses the requirements outlined in HiTRUST control 06.09b1System.2, focusing on the documentation, testing, and approval of changes to information systems. Effective configuration management is essential for maintaining the integrity, availability, and confidentiality of electronic Protected Health Information (ePHI). This policy establishes a framework ensuring that all changes to information systems, applications, databases, configurations, network devices, and operating systems are consistently and thoroughly managed.

## Policy Statement

All changes to information systems, including applications, databases, configurations, network devices, and operating systems, will be documented, tested, and approved prior to implementation. Exceptions to this policy will be limited to automated security patches, as defined in this document.

## Scope

This policy applies to all entities and environments that manage, store, or transmit ePHI, including but not limited to:
- **Cloud-hosted systems**
- **SaaS applications**
- **Third-party vendor systems (Business Associates)**
- **All channels used to create, receive, maintain, or transmit ePHI**

## Responsibilities

- **IT Security Team**: 
  - **Review** changes weekly.
  - **Approve** or **reject** changes based on risk assessments.
  
- **System Administrators**: 
  - **Document** all changes immediately upon implementation.
  - **Test** changes in a controlled environment prior to deployment.

- **Management**: 
  - **Sign** off on change approval forms within 48 hours of submission.
  - **Review** change logs quarterly to ensure compliance.

## Evidence Collection Methods

1. **REQUIREMENT**: Changes to information systems are documented, tested, and approved.
   - **MACHINE ATTESTATION**: 
     - Use OSquery to collect change logs daily and verify that all changes are logged with timestamps and descriptions.
   - **HUMAN ATTESTATION**: 
     - Managers must sign the change approval forms within 48 hours of change submission to validate approvals.

2. **REQUIREMENT**: Automated security patches are the only exceptions.
   - **MACHINE ATTESTATION**: 
     - Utilize configuration management tools to track the application of automated security patches and log their installation.
   - **HUMAN ATTESTATION**: 
     - System Administrators must submit a quarterly report summarizing all automated patches applied, including dates and systems affected.

3. **REQUIREMENT**: Changes are tested prior to implementation.
   - **MACHINE ATTESTATION**: 
     - Implement automated testing scripts to validate changes in a staging environment.
   - **HUMAN ATTESTATION**: 
     - Document test results and have the relevant team lead sign off on the test completion report.

## Verification Criteria

Compliance will be validated against the following **SMART** objectives:
- **Specific**: All changes must be documented prior to deployment.
- **Measurable**: 100% of changes must have documented approval from management.
- **Actionable**: Changes must be tested in a staging environment before production deployment.
- **Relevant**: Ensure that only authorized personnel make changes to systems.
- **Time-bound**: All approvals must occur within 48 hours of submission.

### KPIs/SLAs
- **KPI**: 95% of changes must be approved and documented within the specified timeframe.
- **SLA**: Change requests must be reviewed within one business week.

## Exceptions

Exceptions to this policy must be documented and approved by the IT Security Team. Any exceptions must include justification and will be reviewed during the **Annual Review** for continued relevance and necessity.

## Lifecycle Requirements

- **Data Retention**: All change logs and approval documents must be retained for a minimum of **3 years**.
- **Mandatory Frequency for Policy Review and Update**: This policy will undergo an **Annual Review** to ensure it remains relevant and effective.

## Formal Documentation and Audit

All workforce members must acknowledge their understanding of this policy through an attestation process. Comprehensive audit logs must be maintained for all critical actions related to changes in information systems. Any exceptions to this policy must be formally documented and reviewed.

## References

None