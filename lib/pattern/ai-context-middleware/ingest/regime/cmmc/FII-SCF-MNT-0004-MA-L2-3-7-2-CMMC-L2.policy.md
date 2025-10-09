---
title: "System Maintenance Tools Control and Monitoring Policy"
weight: 1
description: "Establishes controls and monitoring for system maintenance tools to ensure compliance, protect data integrity, and maintain logs of maintenance activities."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "MA.L2-3.7.2"
control-question: "Does the organization control and monitor the use of system maintenance tools?"
fiiId: "FII-SCF-MNT-0004"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Maintenance"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction
The purpose of this policy is to establish a framework for the control and monitoring of system maintenance tools within the organization. This policy ensures compliance with the CMMC Control MA.L2-3.7.2 by defining clear responsibilities, evidence collection methods, and verification criteria to protect organizational assets and data.

## Policy Statement
The organization shall control and monitor the use of system maintenance tools to ensure they are utilized in a manner that safeguards the integrity, availability, and confidentiality of the information systems. All maintenance activities must be logged, reviewed, and retained in accordance with established data retention policies.

## Scope
This policy applies to all systems and entities within the organization, including but not limited to:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems (Business Associates)
- All channels used to create, receive, maintain, or transmit data

## Responsibilities
- **IT Security Team**: 
  - Conduct quarterly audits of maintenance tools to ensure compliance with policy. 
  - **Action Verb + Frequency**: Audit - Quarterly
- **System Administrators**: 
  - Maintain logs of all maintenance activities performed on systems. 
  - **Action Verb + Frequency**: Log - Daily
- **Compliance Officer**: 
  - Review maintenance tool usage reports monthly and report findings to management. 
  - **Action Verb + Frequency**: Review - Monthly

## Evidence Collection Methods
1. **REQUIREMENT:** Control and monitor the use of system maintenance tools.
2. **MACHINE ATTESTATION:** 
   - Utilize OSquery to monitor and log the use of maintenance tools across endpoints.
   - Implement automated scripts to verify the presence of approved maintenance tools and flag any unauthorized tools.
3. **HUMAN ATTESTATION:** 
   - System Administrators must complete a maintenance activity report detailing the tools used and actions taken, which will be uploaded to Surveilr for validation.

## Verification Criteria
- Compliance will be verified through:
  - Successful completion of quarterly audits (KPI: 100% completion rate).
  - Daily logging of maintenance activities with a minimum accuracy rate of 95% (SLA).
  - Monthly review reports submitted on time, with a target of 100% on-time submissions.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. Exceptions must include a risk assessment that outlines potential impacts and mitigation strategies.

## Lifecycle Requirements
- **Data Retention**: All maintenance logs must be retained for a minimum of **three years**.
- **Annual Review**: This policy will undergo an **Annual Review** to ensure ongoing relevance and compliance with regulatory requirements.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy through digital signatures in Surveilr. Comprehensive audit logs shall be maintained for all actions taken related to system maintenance tools, including access and modification logs.

## References
None