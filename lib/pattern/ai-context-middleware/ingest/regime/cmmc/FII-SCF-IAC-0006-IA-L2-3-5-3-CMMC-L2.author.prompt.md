---
title: "Author Prompt: Multi-Factor Authentication Security Policy"
weight: 1
description: "Establishes Multi-Factor Authentication (MFA) requirements to enhance security and protect sensitive data across the organization."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "IA.L2-3.5.3"
control-question: "Does the organization use automated mechanisms to enforce Multi-Factor Authentication (MFA) for:
 ▪ Remote network access; 
 ▪ Third-party systems, applications and/or services; and/ or
 ▪ Non-console access to critical systems or systems that store, transmit and/or process sensitive/regulated data?"
fiiId: "FII-SCF-IAC-0006"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: IA.L2-3.5.3 (FII: FII-SCF-IAC-0006). 

## Policy Structure
1. **Introduction**: Clearly define the purpose of this policy regarding Multi-Factor Authentication (MFA) and its importance in maintaining security.
2. **Policy Statement**: Articulate the organization's commitment to enforcing MFA for remote network access, third-party systems, and non-console access to critical systems.
3. **Scope**: Explicitly define the scope of this policy to include all users and systems accessing the organization's network, including cloud-hosted systems, SaaS applications, and third-party vendor systems.
4. **Responsibilities**: Detail specific, task-level duties for each role involved in MFA enforcement (e.g., IT Security: daily monitoring of MFA compliance).
5. **Evidence Collection Methods**: 
   - **1. REQUIREMENT**: Describe the requirement for MFA enforcement.
   - **2. MACHINE ATTESTATION**: Suggest automated methods for collecting evidence of MFA compliance (e.g., "Use API integrations with identity providers to verify MFA status for all users accessing critical systems").
   - **3. HUMAN ATTESTATION**: Define required human actions to support MFA compliance (e.g., "IT manager signs off on the quarterly MFA compliance report").
6. **Verification Criteria**: Establish clear, measurable criteria for compliance validation tied to **KPIs/SLAs** (e.g., "All users must demonstrate MFA compliance 100% of the time, validated monthly").
7. **Exceptions**: Outline the process for documenting any exceptions to the policy, including required approvals.
8. **Lifecycle Requirements**: Define **Data Retention** periods for evidence (e.g., "retain MFA logs for a minimum of 6 years") and the frequency for **Annual Review** of this policy.
9. **Formal Documentation and Audit**: Require workforce member acknowledgment of understanding and compliance, along with comprehensive audit logging for all critical actions.
10. **References**: Ensure that this section is the final section of the policy document and contains all relevant external references, formatted correctly. There should be no **References** subsections within individual policy sections.

Emphasize that all sections must maximize machine attestability. Each section must contain detailed attestation guidance. Ensure that the **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review** keywords are **BOLD** as required. 

Ensure that the policy document ends with exactly ONE **References** section and that no **References** subsections appear after each policy section.