---
title: "Author Prompt: Unauthorized Software Execution Prevention Policy"
weight: 1
description: "Establishes guidelines to prevent unauthorized software execution, protecting sensitive information and ensuring compliance with regulatory requirements."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "CM.L2-3.4.7"
control-question: "Does the organization configure systems to prevent the execution of unauthorized software programs?"
fiiId: "FII-SCF-CFG-0003.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: CM.L2-3.4.7 (FII: FII-SCF-CFG-0003.2). 

The policy document must follow this structure: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** Each section should include:

1. **Introduction**: Briefly introduce the purpose and importance of preventing unauthorized software execution.
  
2. **Policy Statement**: Clearly state the organization's commitment to configuring systems to prevent unauthorized software execution.

3. **Scope**: Define the policy's applicability, explicitly including **cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates)**, and **all channels used to create, receive, maintain, or transmit ePHI**.

4. **Responsibilities**: Outline specific, task-level duties (using **Action Verb + Frequency**) for roles such as IT Security, Compliance Officer, and System Administrators.

5. **Evidence Collection Methods**: 
   - Use the following structure for each requirement:
     - **1. REQUIREMENT**: Clearly explain the control requirement.
     - **2. MACHINE ATTESTATION**: Suggest practical, automatable methods for compliance evidence collection (e.g., “Use OSquery to collect software inventory daily”).
     - **3. HUMAN ATTESTATION**: Describe specific steps and artifacts for human evidence (e.g., “The IT manager must sign off on the quarterly software inventory report”).

6. **Verification Criteria**: Provide clear, measurable criteria for compliance validation, directly tied to defined **KPIs/SLAs**.

7. **Exceptions**: Outline the process for documenting and approving exceptions to the policy.

8. **Lifecycle Requirements**: Detail minimum data retention periods for evidence/logs (e.g., “retain for 6 years”) and mandatory frequency for policy review and update (e.g., “reviewed at least annually”).

9. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

Ensure that the policy maximizes machine attestability and includes attestation guidance for each requirement. Remember, all references to methods must be detailed, operational, and specific, avoiding SQL queries or code blocks. 

Conclude the policy document with exactly ONE References section. Ensure that no References subsections appear after each policy section, only at the end of the document. The final section must be formatted correctly, listing any external references used.

Please ensure to **BOLD** the following keywords throughout the policy: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**. Failure to include these bolded keywords will result in critical non-compliance. 

### References
None