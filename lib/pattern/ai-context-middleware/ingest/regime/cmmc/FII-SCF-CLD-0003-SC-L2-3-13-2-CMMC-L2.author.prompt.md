---
title: "Author Prompt: Dedicated Subnet Policy for Security Technologies"
weight: 1
description: "Establishes requirements for hosting security technologies in a dedicated subnet to enhance security and compliance with CMMC standards."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "SC.L2-3.13.2"
control-question: "Does the organization host security-specific technologies in a dedicated subnet?"
fiiId: "FII-SCF-CLD-0003"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Cloud Security"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: SC.L2-3.13.2 (FII: FII-SCF-CLD-0003). 

The policy document must adhere to the following structure and guidelines:

1. **Document Structure**: The policy MUST follow this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Ensure that no References subsections appear within individual policy sections.

2. **Policy Sections**: Each section should:
   - Explain the control requirement.
   - Suggest machine attestation methods (e.g., "Use OSquery to collect asset inventories daily").
   - Suggest human attestation methods where unavoidable (e.g., "Manager signs quarterly inventory validation report").

3. **Markdown Elements**: Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. Use the format for showing Citation links for external references: [Link Text](URL).

4. **Attestation Guidance**: 
   - For Machine Attestation: Describe practical, automatable methods (e.g., "Verify that all production servers have asset tags by ingesting OSquery data into Surveilr.").
   - For Human Attestation: Describe precise steps and artifacts (e.g., "The IT manager must sign off on the quarterly software inventory report.").

5. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps and a specific time-bound metric (KPI/SLA).

6. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, covering cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

7. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation.

8. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr.

9. **Granular Roles and Cross-Referencing**: The Responsibilities section MUST define specific, task-level duties for each role mentioned and explicitly link to related organizational plans for escalation and recovery/disciplinary action.

10. **Policy Lifecycle Requirements**: Include a dedicated subsection detailing minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

11. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

12. **Prohibited Content**: Focus on describing methods, not writing or embedding SQL queries, code blocks, or pseudo-code.

13. **Evidence Collection Methods Structure**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

14. **Verification Criteria**: Provide clear measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

15. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

16. **Hyperlinks**: Use [Link Text](URL) format for external references.

17. **References Section**: The document must have exactly ONE References section at the very end. 

18. **Keyword Emphasis**: The policy text MUST explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

Ensure that the policy document ends with exactly ONE References section, and do not include any control identifiers, metadata, or additional content after this section.