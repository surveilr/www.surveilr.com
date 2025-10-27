---
title: "Author Prompt: Automated Detection of Unauthorized Components Policy"
weight: 1
description: "Implement automated detection and alerting mechanisms to identify unauthorized hardware, software, and firmware components, ensuring asset integrity and compliance."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "TBD - 3.5.3e"
control-question: "Does the organization use automated mechanisms to detect and alert upon the detection of unauthorized hardware, software and firmware components?"
fiiId: "FII-SCF-AST-0002.2"
regimeType: "CMMC"
cmmcLevel: 3
domain: "Asset Management"
category: ["CMMC", "Level 3", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "TBD - 3.5.3e" (FII: FII-SCF-AST-0002.2). 

The policy must adhere to the following structure and guidelines:

1. **Document Structure**: The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. 

2. **Policy Content**: Each section should:
   - Clearly explain the control requirement.
   - Suggest machine attestation methods, such as "Use OSquery to collect asset inventories daily."
   - Suggest human attestation methods where automation is impractical, e.g., "Manager signs quarterly inventory validation report."
   - Do NOT include References subsections within policy sections. The References section appears ONLY at the very end of the document.

3. **Markdown Formatting**: Use standard Markdown formatting including headings (##), bullet points, bold text for emphasis, and inline code for technical terms. 

4. **Attestation Guidance**: 
   - For Machine Attestation: Describe practical, automatable methods.
   - For Human Attestation: Describe precise steps and artifacts.

5. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes like containment, correction, or violation sanction, along with a specific time-bound metric (KPI/SLA).

6. **Scope Definition**: Explicitly define the policy's scope to include all relevant entities and environments, covering cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

7. **Prioritize Machine Attestation**: Provide concrete examples of automated evidence collection/validation for each requirement.

8. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr when human attestation is needed.

9. **Granular Roles and Cross-Referencing**: Define specific, task-level duties for each role mentioned in the Responsibilities section and explicitly link to related organizational plans.

10. **Policy Lifecycle Requirements**: Include a subsection detailing minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

11. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

12. **Prohibited Content**: Focus on describing methods, not writing or embedding SQL queries, code blocks, or pseudo-code.

13. **Evidence Collection Methods Structure**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

14. **Verification Criteria**: Provide clear, measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

15. **Hyperlinks**: Use [Link Text](URL) format for external references.

16. **Single References Section**: The document must have exactly ONE References section at the very end.

17. **Keyword Emphasis**: The policy text must explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

The policy must end with exactly ONE References section. Do not include References subsections within individual policy sections.