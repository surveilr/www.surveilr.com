---
title: "Author Prompt: Privileged Account Multi-Factor Authentication Policy"
weight: 1
description: "Establishes Multi-Factor Authentication for privileged accounts to enhance security and ensure compliance with CMMC control IA.L2-3.5.3."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "IA.L2-3.5.3"
control-question: "Does the organization utilize Multi-Factor Authentication (MFA) to authenticate network access for privileged accounts?"
fiiId: "FII-SCF-IAC-0006.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "IA.L2-3.5.3" (FII: "FII-SCF-IAC-0006.1"). 

The policy must follow the exact structure: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** 

1. **Introduction**: Clearly explain the purpose of the policy.  
2. **Policy Statement**: State the organization's commitment to utilizing Multi-Factor Authentication (MFA) for privileged accounts.  
3. **Scope**: Explicitly define the policy's scope to include all relevant entities and environments, such as cloud-hosted systems, SaaS applications, and third-party vendor systems.  
4. **Responsibilities**: Define specific, task-level duties (using **Action Verb + Frequency**) for each role involved in the policy, linking to relevant organizational plans for escalation and recovery.  
5. **Evidence Collection Methods**: Follow the structure:  
   - **1. REQUIREMENT**: Explain the MFA requirement.  
   - **2. MACHINE ATTESTATION**: Describe practical, automatable methods for evidence collection, ensuring machine attestability through Surveilr (e.g., "Use API integrations to validate MFA configurations").  
   - **3. HUMAN ATTESTATION**: Specify the exact action, artifact, and ingestion method into Surveilr (e.g., "The IT manager must sign a quarterly report confirming MFA compliance and upload it to Surveilr with metadata").  
6. **Verification Criteria**: Provide clear, measurable criteria for compliance validation, directly tied to defined **KPIs/SLAs** related to MFA implementation.  
7. **Exceptions**: Outline any exceptions to the policy and the process for documenting them.  
8. **Lifecycle Requirements**: Detail **Data Retention** periods for evidence/logs, and the **Annual Review** frequency for the policy.  
9. **Formal Documentation and Audit**: Require workforce member acknowledgment of the policy, comprehensive audit logging of actions, and formal documentation for exceptions.  
10. **References**: The document must end with exactly ONE References section, using the format "[Link Text](URL)" for external references, if applicable. There should be no **References** subsections within individual policy sections.

Ensure the policy emphasizes machine attestability, includes specific, measurable, actionable, relevant, and time-bound (**SMART**) instructions, and all **BOLD** keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.   

Avoid including any SQL queries, code blocks, or pseudo-code within the policy. The **References** section should be the final section of the policy document, with no additional content following it.