---
title: "Author Prompt: Periodic Review of System Configurations Policy"
weight: 1
description: "Establishes a comprehensive framework for regularly reviewing and securing system configurations to enhance organizational security and compliance."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "CM.L2-3.4.7"
control-question: "Does the organization periodically review system configurations to identify and disable unnecessary and/or non-secure functions, ports, protocols and services?"
fiiId: "FII-SCF-CFG-0003.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "CM.L2-3.4.7" (FII: "FII-SCF-CFG-0003.1"). 

The policy structure must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** 

1. **Introduction**: Introduce the purpose of the policy regarding the periodic review of system configurations to identify and disable unnecessary and/or non-secure functions, ports, protocols, and services.

2. **Policy Statement**: Clearly state the organization's commitment to regularly reviewing system configurations as part of its Configuration Management process.

3. **Scope**: Define the scope of the policy, ensuring it covers all relevant entities and environments, including cloud-hosted systems, SaaS applications, and third-party vendor systems that interact with organizational data.

4. **Responsibilities**: 
   - Define specific, task-level duties (action verbs and frequency) for each role involved in the policy implementation (e.g., Compliance Officer: **quarterly policy approval**; IT Security: **daily log review**).
   - Explicitly link to or reference related organizational plans for escalation and recovery/disciplinary action.

5. **Evidence Collection Methods**: 
   - For each requirement related to the control, use the numbered structure:
     - **1. REQUIREMENT**: Explain the control requirement.
     - **2. MACHINE ATTESTATION**: Suggest automatable methods such as using OSquery to collect configuration data or API integrations with cloud providers to validate secure configurations.
     - **3. HUMAN ATTESTATION**: Describe the exact actions, artifacts, and ingestion methods into Surveilr for any human attestations needed.

6. **Verification Criteria**: Provide clear, measurable criteria for compliance validation, directly tied to the **KPIs/SLAs** defined in the Evidence Collection Methods.

7. **Exceptions**: Outline any conditions under which exceptions to the policy may be granted, along with the required documentation.

8. **Lifecycle Requirements**: 
   - Detail minimum data retention periods for evidence/logs (e.g., 'retain for 6 years').
   - State the mandatory frequency for policy review and update (e.g., 'reviewed at least **annually**').

9. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

The policy document must end with exactly ONE **References** section. Do NOT include References subsections within individual policy sections; they should only appear at the very end of the document.

Ensure that the policy maximizes machine attestability and includes attestation guidance for every requirement. Use standard Markdown formatting, including headings, bullets, and bold text for emphasis. Keywords such as **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review** must be explicitly bolded throughout the policy. No SQL queries, code blocks, or pseudo-code should be included. 

The final document must adhere strictly to this structure and these guidelines to achieve a 100% compliance score.