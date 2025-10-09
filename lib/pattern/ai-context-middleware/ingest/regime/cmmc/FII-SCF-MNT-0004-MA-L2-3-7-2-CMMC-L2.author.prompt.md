---
title: "Author Prompt: System Maintenance Tools Control and Monitoring Policy"
weight: 1
description: "Establishes controls and monitoring for system maintenance tools to ensure compliance, protect data integrity, and maintain logs of maintenance activities."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "MA.L2-3.7.2"
control-question: "Does the organization control and monitor the use of system maintenance tools?"
fiiId: "FII-SCF-MNT-0004"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Maintenance"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: MA.L2-3.7.2 (FII: FII-SCF-MNT-0004). 

The policy must adhere to the following structure and guidelines:

1. **Document Structure**: The policy MUST follow this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Each section must be clearly defined using H2 headings (##).

2. **Operational Detail and Specificity**: The policy MUST use **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. For processes like maintenance, the policy MUST include a bulleted list of 3-5 operational steps with a **specific time-bound metric (KPI/SLA)** for completion.

3. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, including **cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates)**, and ALL channels used to create, receive, maintain, or transmit data.

4. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation. For example, specify methods such as using OSquery for endpoint monitoring.

5. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr where human attestation is required.

6. **Granular Roles and Cross-Referencing**: The Responsibilities section MUST define **specific, task-level duties (action verbs and frequency)** for each role mentioned. Explicitly link to or reference related organizational plans (e.g., Incident Response Plan).

7. **Policy Lifecycle Requirements**: The policy MUST contain a dedicated subsection detailing **Minimum data retention periods** for evidence/logs and **mandatory frequency for policy review and update**.

8. **Formal Documentation and Audit**: The policy MUST require **Workforce member acknowledgement/attestation** of understanding and compliance, along with **comprehensive audit logging** for all critical actions.

9. **Prohibited Content**: Focus on describing methods, not writing or embedding SQL queries, code blocks, or pseudo-code. DO NOT include References subsections within policy sections.

10. **Evidence Collection Methods Structure**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

11. **Verification Criteria**: Clear measurable criteria for compliance validation directly tied to the KPIs/SLAs defined.

12. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

13. **Hyperlinks**: Use [Link Text](URL) format for external references.

14. **Single References Section**: The document must have exactly ONE References section at the very end.

15. **Keyword Emphasis**: The policy text MUST explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

16. **Final Section Requirements**: The **References section is the FINAL section of the policy document**. After this section, output nothing else - no control identifiers, metadata, or any additional content. MUST NOT contain control id, control question, and fii id.

17. **References Section Format**: If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by a single line containing "None". 

Please ensure that no References subsections appear after each policy section, and that the policy document ends with exactly ONE References section.