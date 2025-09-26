---
title: "Author Prompt: Risk Analysis Compliance Policy"
weight: 1
description: "Conducts comprehensive risk analysis to protect ePHI and ensure compliance with NIST Guidelines."
publishDate: "2025-09-26"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(1)(ii)(A)"
control-question: "Has a risk analysis been completed using IAW NIST Guidelines? (R)"
fiiId: "FII-SCF-RSK-0004"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control : 164.308(a)(1)(ii)(A) (FII: FII-SCF-RSK-0004). 

The policy document must follow this structure:

## Introduction
- Provide a brief overview of the purpose and importance of conducting a risk analysis in compliance with NIST Guidelines.

## Policy Statement
- State the organization's commitment to performing a comprehensive risk analysis.

## Scope
- Clearly define the scope to include all relevant entities and environments, such as cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

## Responsibilities
- Define specific, task-level duties for each role involved, using **Action Verb + Frequency** format (e.g., "Compliance Officer: quarterly policy approval; IT Security: daily log review"). Explicitly link to related organizational plans (e.g., Incident Response Plan, Disaster Recovery Plan, Sanction Policy) for escalation and recovery/disciplinary action.

## Evidence Collection Methods
1. REQUIREMENT:
   - Explain the control requirement related to conducting a risk analysis.
   
2. MACHINE ATTESTATION:
   - Suggest practical, automatable methods for evidence collection, such as using OSquery to validate security configurations or API integrations to verify access controls.

3. HUMAN ATTESTATION:
   - Describe specific actions a human must perform, like having a manager certify the completion of the risk analysis, and detail how this attestation is documented and ingested into Surveilr.

## Verification Criteria
- Provide clear, measurable criteria for validation of compliance, directly tied to **SMART** objectives and **KPIs/SLAs** defined in the Evidence Collection Methods section.

## Exceptions
- Outline the process for documenting exceptions, including required approvals and justifications.

## Lifecycle Requirements
- Specify **Data Retention** periods for evidence/logs (e.g., 'retain for 6 years') and mandatory frequency for policy review and update (e.g., 'reviewed at least annually').

## Formal Documentation and Audit
- Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

### References
- End the document with a single **References** section in the format of [Link Text](URL) for any external references. Ensure that there is exactly ONE References section at the end of the document, with no additional content following it.