---
title: "Author Prompt: Sensitive Information Security Policy"
weight: 1
description: "Establishes comprehensive security policies to protect ePHI and ensure compliance with regulations."
publishDate: "2025-09-26"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "CC1-0004"
control-question: "Information security policies and procedures (including hiring and termination procedures; logging procedures; monitoring procedures) with revision history"
fiiId: "FII-SCF-IRO-0012"
regimeType: "SOC2-TypeII"
category: ["SOC2-TypeII", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "CC1-0004" (FII: "FII-SCF-IRO-0012"). 

The policy document must follow this exact structure: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** 

1. **Document Structure**: Each major requirement should be a separate section marked with H2 headings (##). Each section must explain the control requirement, suggest machine attestation methods, and outline human attestation methods where necessary. Do NOT include References subsections within policy sections. 

2. **Markdown Elements**: Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. Ensure citation links use the format: [Link Text](URL).

3. **Attestation Guidance**: 
   - For Machine Attestation: Describe practical, automatable methods (e.g., "Use OSquery to collect asset inventories daily").
   - For Human Attestation: Describe specific actions and artifacts (e.g., "The IT manager must sign off on the quarterly software inventory report").

4. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions, including a bulleted list of 3-5 operational steps and a specific time-bound metric (KPI/SLA) for processes like containment or correction.

5. **Scope Definition**: Explicitly define the policy's scope to include all relevant entities and environments, covering cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

6. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation.

7. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr.

8. **Granular Roles and Cross-Referencing**: The Responsibilities section must define specific, task-level duties for each role mentioned, linking to related organizational plans for escalation and recovery/disciplinary action.

9. **Policy Lifecycle Requirements**: The policy must detail minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

10. **Formal Documentation and Audit**: The policy must require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging, and formal documentation for all exceptions.

11. **Prohibited Content**: Focus on describing methods, not writing or embedding SQL queries or code blocks. 

12. **Evidence Collection Methods Structure**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

13. **Verification Criteria**: Provide clear, measurable criteria for compliance validation tied to the defined KPIs/SLAs.

14. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

15. **Hyperlinks**: Use [Link Text](URL) format for external references.

16. **Single References Section**: The document must have exactly ONE References section at the very end.

17. **Keyword Emphasis**: The policy text must explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

18. **Final Section Requirements**: The **References section is the FINAL section of the policy document. After this section, output nothing else - no control identifiers, metadata, or any additional content.** 

### References
None