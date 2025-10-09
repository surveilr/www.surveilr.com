---
title: "Author Prompt: Remote Device Split Tunneling Prevention Policy"
weight: 1
description: "Establishes guidelines to prevent split tunneling on remote devices, ensuring secure access to organizational resources and protecting sensitive data."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "SC.L2-3.13.7"
control-question: "Does the organization prevent split tunneling for remote devices unless the split tunnel is securely provisioned using organization-defined safeguards?

Prevent split tunneling for remote devices unless the split tunnel is securely provisioned using organization-defined safeguards?"
fiiId: "FII-SCF-CFG-0003.4"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: SC.L2-3.13.7 (FII: FII-SCF-CFG-0003.4). 

## Policy Structure

1. **Introduction**: Begin with a clear overview of the policy's purpose regarding the prevention of split tunneling for remote devices, including its significance for security and compliance.

2. **Policy Statement**: Clearly state the organization's commitment to preventing split tunneling unless securely provisioned with defined safeguards.

3. **Scope**: Define the policy's scope to include all relevant entities and environments, specifically addressing cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates), and all channels used to create, receive, maintain, or transmit sensitive data.

4. **Responsibilities**: Specify granular roles and task-level duties using **Action Verb + Frequency** (e.g., IT Security: daily review of tunnel configurations; Compliance Officer: quarterly policy approval).

5. **Evidence Collection Methods**: 
   - **1. REQUIREMENT**: State the requirement to prevent split tunneling.
   - **2. MACHINE ATTESTATION**: Suggest practical, automatable methods for evidence collection, such as monitoring network configurations and routing tables using automated tools.
   - **3. HUMAN ATTESTATION**: Describe the specific actions and artifacts required, such as management review and documentation of secure tunnel provisioning.

6. **Verification Criteria**: Provide clear, measurable criteria for compliance validation that are directly tied to defined **KPIs/SLAs**.

7. **Exceptions**: Outline any conditions under which exceptions to the policy may be granted, including the documentation needed for approval.

8. **Lifecycle Requirements**: Include a subsection detailing **Data Retention** periods for logs and evidence (e.g., retain for 6 years) and the mandatory frequency for **Annual Review** of the policy.

9. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

10. **References**: At the very end of the document, include exactly ONE References section formatted as follows: 
   - If external references exist, list them under ### References using [Link Text](URL) format.
   - If no external references exist, state "### References" followed by "None".

**IMPORTANT**: Ensure that no References subsections appear within any policy sections. All relevant content must maximize machine attestability and include explicit human attestation where necessary. Use **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review** as emphasized keywords throughout the document. 

End the policy document with exactly ONE References section, and do not include control identifiers, metadata, or any additional content beyond the specified sections.