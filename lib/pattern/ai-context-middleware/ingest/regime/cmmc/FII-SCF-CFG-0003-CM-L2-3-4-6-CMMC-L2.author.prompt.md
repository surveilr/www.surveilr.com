---
title: "Author Prompt: CMMC Non-Essential Services Configuration Policy"
weight: 1
description: "Establishes guidelines to restrict non-essential ports, protocols, and services, enhancing the security of organizational information systems."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "CM.L2-3.4.6"
control-question: "Does the organization configure systems to provide only essential capabilities by specifically prohibiting or restricting the use of ports, protocols, and/or services?"
fiiId: "FII-SCF-CFG-0003"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "CM.L2-3.4.6" (FII: "FII-SCF-CFG-0003"). 

The policy must adhere to the following structure and requirements:

1. **Document Structure**: The policy **MUST** include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** Each section should contain relevant content as outlined below.

2. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. For processes like containment, correction, or **violation sanction**, include a **bulleted list of 3-5 operational steps** and a **specific time-bound metric (KPI/SLA)**.

3. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include all relevant entities and environments, such as **cloud-hosted systems, SaaS applications, and third-party vendor systems (Business Associates)**.

4. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation.

5. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr where human attestation is necessary.

6. **Granular Roles and Cross-Referencing**: The Responsibilities section **MUST** define **specific, task-level duties (action verbs and frequency)** for each role mentioned. Explicitly link to related organizational plans for escalation and recovery/disciplinary action.

7. **Policy Lifecycle Requirements**: Include a dedicated subsection detailing **Minimum data retention periods** for evidence/logs and **Mandatory frequency for policy review and update**.

8. **Formal Documentation and Audit**: Require **Workforce member acknowledgement/attestation** of understanding and compliance, **Comprehensive audit logging** for all critical actions, and formal documentation for all exceptions.

9. **Prohibited Content**: Focus on describing methods without writing or embedding SQL queries, code blocks, or pseudo-code. Do NOT include References subsections within policy sections.

10. **Evidence Collection Methods**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

11. **Verification Criteria**: Provide clear measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

12. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

13. **Hyperlinks**: Use [Link Text](URL) format for external references.

14. **Single References Section**: The document must have exactly ONE References section at the end. 

15. **Keyword Emphasis**: The policy text **MUST** explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

16. **Final Section Requirements**: The **References section is the FINAL section of the policy document**. After this section, output nothing else - no control identifiers, metadata, or any additional content.

17. **References Section Format**: If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by a single line containing "None".

Ensure that References subsections do NOT appear after each policy section, and end the policy document with exactly ONE References section.