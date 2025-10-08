---
title: "Author Prompt: Publicly-Accessible Content Control Policy"
weight: 1
description: "Ensure controlled management of publicly-accessible content to protect sensitive information and maintain compliance with CMMC requirements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L1-3.1.22"
control-question: "Does the organization control publicly-accessible content?"
fiiId: "FII-SCF-DCH-0015"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L1-3.1.22 (FII: FII-SCF-DCH-0015). 

Please follow these instructions to create a comprehensive policy document:

1. **Document Structure**: The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Remember that **References subsections should NOT appear after each policy section**. 

2. **Policy Content**: Each section should clearly explain the control requirement, suggest machine attestation methods, and include human attestation methods where necessary. Emphasize that policies must maximize **machine attestability** by including specific attestation guidance. 

3. **Markdown Elements**: Use H2 headings (##) for each major section. Incorporate standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. Use the format for citation links as follows: [Link Text](URL).

4. **Attestation Guidance**: For each requirement, include:
   - **Machine Attestation**: Describe practical, automatable methods (e.g., "Use OSquery to collect asset inventories daily").
   - **Human Attestation**: Define precise actions, artifacts, and ingestion methods into Surveilr (e.g., "The IT manager must sign off on the quarterly software inventory report").

5. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes like containment, correction, or violation sanction, along with a **specific time-bound metric (KPI/SLA)**.

6. **Comprehensive Scope Definition**: Explicitly define the policy's scope to cover **cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates)**, and all channels used to create, receive, maintain, or transmit ePHI.

7. **Explicit Human Attestation**: When automation is impractical, define the exact action, artifact, and ingestion method into Surveilr.

8. **Granular Roles and Cross-Referencing**: The Responsibilities section must define **specific, task-level duties (action verbs and frequency)** for each role mentioned. Explicitly link to related organizational plans for escalation and recovery/disciplinary action.

9. **Policy Lifecycle Requirements**: Include a subsection detailing **Minimum data retention periods** for evidence/logs, and a **Mandatory frequency for policy review and update**.

10. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, and comprehensive audit logging for all critical actions.

11. **Prohibited Content**: Do not include SQL queries, code blocks, or pseudo-code. Focus on describing methods.

12. **Evidence Collection Methods**: Use the mandatory structure with numbered subheadings for each requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

13. **Verification Criteria**: Provide clear measurable criteria for compliance validation directly tied to the KPIs/SLAs defined previously.

14. **Markdown Formatting**: Ensure you use standard Markdown formatting throughout the document.

15. **Keyword Emphasis**: The policy text must explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

16. **Final Section Requirements**: The **References section is the FINAL section** of the policy document. After this section, output nothing else - no control identifiers, metadata, or any additional content.

17. **References Section Format**: If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by a single line containing "None".

Your response must provide a complete policy document that meets all these requirements.