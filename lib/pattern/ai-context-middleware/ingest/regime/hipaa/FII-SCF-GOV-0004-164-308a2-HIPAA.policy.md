---
title: "ePHI Security Policy"
weight: 1
description: "Establishes security policies and procedures to protect electronic Protected Health Information (ePHI) and ensure compliance."
publishDate: "2025-09-26"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "164.308(a)(2)"
control-question: "Assigned security responsibility: Identify the security official who is responsible for the development and implementation of the policies and procedures required by this subpart for the entity."
fiiId: "FII-SCF-GOV-0004, FII-SCF-HRS-0003"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance"]
---

## Introduction

This policy outlines the requirements for the development and implementation of policies and procedures related to the security of electronic Protected Health Information (ePHI) as mandated by Control: 164.308(a)(2). The designated security official will ensure compliance with applicable regulations while leveraging **machine attestability** for evidence collection, thereby enhancing the overall security posture of our organization.

## Policy Statement

The organization is committed to safeguarding ePHI by establishing a clear framework of policies and procedures. The designated security official is responsible for the development, implementation, and continual assessment of these policies to ensure compliance with **SMART** objectives and enhance the integrity and confidentiality of sensitive data.

## Scope

This policy applies to all **cloud-hosted systems**, **SaaS applications**, **third-party vendor systems**, and all channels used to handle ePHI within the organization. It encompasses all workforce members involved in the management and protection of ePHI.

## Responsibilities

- **Security Official**: Develops and implements policies and procedures related to ePHI security **annually**.
- **Compliance Officer**: Reviews and updates compliance policies **quarterly** to align with regulatory changes.
- **IT Security Team**: Monitors system configurations and access controls **continuously**, reporting anomalies **weekly**.
- **All Workforce Members**: Acknowledge receipt of security policies and procedures **upon onboarding** and **annually thereafter**.

## Evidence Collection Methods

### Machine Attestation Methods

- Utilize **OSquery** to collect configuration details of systems handling ePHI. Scheduled queries should run **daily** to gather data on system states.
- Implement API integrations with SaaS applications to automatically log access controls and user interactions with ePHI, generating reports **weekly**.

### Human Attestation Methods

- Workforce members must sign a **compliance acknowledgment form** upon receiving training on security policies. This form will be stored in the compliance management system.
- Conduct **monthly** reviews of access logs, with designated personnel providing a signed report summarizing findings, which will be archived in Surveilr.

## Verification Criteria

- Automated systems must generate reports that can be ingested into Surveilr on a **weekly basis** for validation.
- Human-verified reports must be signed and submitted to the Compliance Officer **monthly** for review and possible action.

## Exceptions

Exceptions to this policy may be granted only through written approval from the security official. Any granted exceptions must be documented, including the rationale and duration of the exception.

## Lifecycle Requirements

- **Data Retention**: All evidence and documentation related to ePHI security must be retained for a minimum of **six years** from the date of creation or the last access, whichever is longer.
- Policies must undergo a mandatory **annual review** to ensure relevance and compliance with evolving security standards and regulations.

## Formal Documentation and Audit

All critical actions, including policy development, reviews, and training acknowledgments, must be logged comprehensively. Audit logs must be retained for **three years** and reviewed by the Compliance Officer **semi-annually**.

## References

None