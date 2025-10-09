---
title: "Media Security and Malware Prevention Policy"
weight: 1
description: "Establishes rigorous checks for malicious code on media containing diagnostic and test programs to protect information systems and ePHI."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "MA.L2-3.7.4"
control-question: "Does the organization check media containing diagnostic and test programs for malicious code before the media are used?"
fiiId: "FII-SCF-MNT-0004.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Maintenance"
category: ["CMMC", "Level 2", "Compliance"]
---

# Policy Document for Control: MA.L2-3.7.4 (FII: FII-SCF-MNT-0004.2)

## Introduction
The purpose of this policy is to establish a comprehensive framework for ensuring that all media containing diagnostic and test programs are thoroughly checked for malicious code prior to use. This proactive measure is crucial in safeguarding the integrity of our information systems and the confidentiality of electronic Protected Health Information (ePHI). This policy aims to mitigate risks associated with malware that could compromise the security and functionality of our systems.

## Policy Statement
The organization is committed to ensuring that all media containing diagnostic and test programs are rigorously checked for malicious code before being utilized. This commitment extends to all relevant stakeholders and is integral to our security posture and compliance with CMMC requirements.

## Scope
This policy applies to all relevant entities and environments, including but not limited to:
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities
- **IT Security Team**: Conduct media checks for malicious code on a **per-usage basis** and ensure compliance with the policy. 
- **IT Manager**: Review and approve media validation reports on a **monthly basis**.
- **Compliance Officer**: Ensure policy adherence and conduct audits on a **quarterly basis**. 
- **All Workforce Members**: Report any suspicious media or breaches immediately to the IT Security Team on a **real-time basis**.

Escalation and recovery plans are outlined in the organization's Incident Response Plan, and disciplinary actions for non-compliance follow the Employee Handbook.

## Evidence Collection Methods
1. **REQUIREMENT**: All media containing diagnostic and test programs must be checked for malicious code before use.
   
2. **MACHINE ATTESTATION**: 
   - Use OSquery to verify the integrity of media prior to usage. 
   - Implement automated scripts for initial scans and reporting of results.

3. **HUMAN ATTESTATION**: 
   - The IT manager must sign off on the media validation report, which is to be uploaded to Surveilr with metadata including review date and reviewer name. 
   - All workforce members must complete a training module on media security and sign an acknowledgment form.

## Verification Criteria
Compliance validation will be measured through:
- Percentage of media checked for malicious code (target: 100%).
- Number of media checks performed per month (target: at least 95% of scheduled checks).
- Timeliness of media validation report submissions (target: 100% submitted within 24 hours of media usage).

## Exceptions
Exceptions to this policy may be granted under special circumstances and must be documented and approved by the Compliance Officer. All exceptions will require a formal justification and will be reviewed annually.

## Lifecycle Requirements
Evidence and logs related to media checks must be retained for a minimum of **three years**. The policy itself will be reviewed and updated at least **annually** to ensure continued relevance and compliance with applicable regulations.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy by signing an attestation form. Comprehensive audit logs will be maintained for all critical actions, and formal documentation for all exceptions will be retained and reviewed during audits.

## References
None