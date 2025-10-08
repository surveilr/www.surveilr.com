---
title: "Author Prompt: Access Control for Privileged Users Policy"
weight: 1
description: "Limit access to security functions to authorized privileged users while ensuring documentation, monitoring, and regular reviews to maintain compliance and security."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.5"
control-question: "Does the organization limit access to security functions to explicitly-authorized privileged users?"
fiiId: "FII-SCF-IAC-0021.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L2-3.1.5 (FII: FII-SCF-IAC-0021.1). 

The policy must adhere to the following guidelines:

1. **Document Structure**: The policy MUST follow this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.**

2. **Policy Sections**: Use H2 headings (##) for each major requirement. Each section should:
   - Explain the control requirement.
   - Suggest **machine attestation methods** (e.g., "Use OSquery to collect access logs daily").
   - Suggest **human attestation methods** where unavoidable (e.g., "Manager signs quarterly access control review report").
   - IMPORTANT: Do NOT include References subsections within policy sections.

3. **Attestation Guidance**:
   - For **Machine Attestation**: Describe practical, automated methods.
   - For **Human Attestation**: Describe precise steps, required artifacts, and how they are ingested into Surveilr.

4. **Operational Detail and Specificity**: The policy MUST contain **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions, including a bulleted list of 3-5 operational steps for processes like access validation and a specific time-bound metric (KPI/SLA).

5. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include all relevant entities and environments, including cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

6. **Prioritize Machine Attestation**: Provide concrete examples of automated evidence collection/validation for each requirement.

7. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr when needed.

8. **Granular Roles and Cross-Referencing**: The Responsibilities section MUST define specific, task-level duties (action verbs and frequency) for each role mentioned and explicitly link to or reference related organizational plans for escalation and recovery actions.

9. **Policy Lifecycle Requirements**: Include a dedicated subsection detailing minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

10. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for critical actions, and formal documentation for exceptions.

11. **Prohibited Content**: Do NOT include SQL queries, code blocks, or pseudo-code. Focus on describing methods only.

12. **Evidence Collection Methods Structure**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

13. **Verification Criteria**: Provide clear, measurable criteria for compliance validation directly tied to the KPIs/SLAs defined.

14. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

15. **Hyperlinks**: Use [Link Text](URL) format for external references.

16. **Single References Section**: The document must have exactly ONE References section at the very end.

17. **Keyword Emphasis**: The policy text MUST explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

18. **Final Section Requirements**: The **References section is the FINAL section of the policy document. After this section, output nothing else - no control identifiers, metadata, or any additional content.**

19. **References Section Format**: If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by a single line containing "None".

Ensure that your policy does not contain References subsections within individual sections and ends with exactly ONE References section.