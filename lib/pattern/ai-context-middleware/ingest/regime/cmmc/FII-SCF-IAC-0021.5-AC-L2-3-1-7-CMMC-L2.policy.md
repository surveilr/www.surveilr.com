---
title: "Privileged Access Control Policy for Non-Privileged Users"
weight: 1
description: "Establishes restrictions preventing non-privileged users from executing privileged functions to enhance security and protect sensitive information."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.7"
control-question: "Does the organization prevent non-privileged users from executing privileged functions to include disabling, circumventing or altering implemented security safeguards / countermeasures?"
fiiId: "FII-SCF-IAC-0021.5"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

# Policy for Control: AC.L2-3.1.7 (FII: FII-SCF-IAC-0021.5)

## Introduction
This policy aims to establish a framework for preventing non-privileged users from executing privileged functions, including disabling, circumventing, or altering security safeguards. The significance of this policy lies in maintaining the integrity and security of sensitive information and systems by ensuring that only authorized personnel have the capacity to perform actions that could compromise security. By adhering to this policy, the organization can better protect against unauthorized access and potential data breaches.

## Policy Statement
The organization prohibits non-privileged users from executing any privileged functions, including the alteration, circumvention, or disabling of implemented security safeguards and countermeasures. This policy aligns with our commitment to safeguarding sensitive information and ensuring compliance with relevant regulations and standards.

## Scope
This policy applies to all entities within the organization, including but not limited to:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit sensitive information

## Responsibilities
- **IT Security Team**: Conduct monthly reviews of user access logs to ensure compliance with privileged access controls.
- **System Administrators**: Implement and regularly test security safeguards on a quarterly basis.
- **Compliance Officer**: Review policy adherence and performance metrics annually and escalate issues to management as necessary.
- **All Users**: Attend mandatory training sessions on security policies and report any suspicious activity weekly.

## Evidence Collection Methods

1. **REQUIREMENT**: Control requires that non-privileged users cannot execute privileged functions.
   - **MACHINE ATTESTATION**: Automate the collection of access logs and system configurations through Surveilr to ensure that access permissions are set correctly.
   - **HUMAN ATTESTATION**: Require users to complete an acknowledgment form confirming their understanding of access limitations, which is then ingested into Surveilr.

2. **REQUIREMENT**: Alteration or circumvention of security measures must be restricted.
   - **MACHINE ATTESTATION**: Use automated tools to generate reports on attempted access to privileged functions, which are ingested into Surveilr.
   - **HUMAN ATTESTATION**: Maintain a log of incidents where users report security safeguard failures, with reports submitted to Surveilr.

## Verification Criteria
- **SMART Objective**: Achieve 100% compliance with privileged access restrictions across all systems by the end of Q4.
- **KPIs/SLAs**: 
  - Monthly review of user access logs, with no unauthorized access events recorded.
  - Quarterly testing of security safeguards, with reported vulnerabilities addressed within 30 days.

## Exceptions
Any exceptions to this policy must be documented and approved by the IT Security Team. The documentation must include the rationale for the exception, the duration, and a plan for remediation. All exceptions will be logged in Surveilr for auditing purposes.

## Lifecycle Requirements
- **Data Retention**: Logs and evidence related to privileged access must be retained for a minimum of 3 years.
- **Annual Review**: This policy shall be reviewed and updated annually to ensure its effectiveness and compliance with applicable regulations.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy through digital signatures. Comprehensive audit logs must be maintained for all critical actions related to privileged access, and formal documentation of all exceptions must be retained in Surveilr for review.

## References
- CMMC Control AC.L2-3.1.7
- FII-SCF-IAC-0021.5
- Organizational security policies and procedures
- Relevant compliance standards and regulations