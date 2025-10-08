---
title: "Author Prompt: Least Privilege Access Control Policy"
weight: 1
description: "Enforces logical access control permissions based on the principle of least privilege to protect electronic Protected Health Information (ePHI)."
publishDate: "2025-10-06"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L1-3.1.1"
control-question: "Does the organization enforce Logical Access Control (LAC) permissions that conform to the principle of least privilege?"
fiiId: "FII-SCF-IAC-0020"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Identification & Authentication"
category: ["CMMC", "Level 1", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L1-3.1.1 (FII: FII-SCF-IAC-0020). 

**Instructions for Policy Authoring:**

1. **Document Structure**: The policy must follow this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Each section should clearly define the control requirement, suggest machine attestation methods, and suggest human attestation methods where unavoidable.

2. **Evidence Collection Methods**: Structure this section using numbered subheadings per requirement:
   - "1. REQUIREMENT:"
   - "2. MACHINE ATTESTATION:"
   - "3. HUMAN ATTESTATION:"

3. **Attestation Guidance**: For each requirement, provide concrete examples of automated evidence collection/validation methods. Describe practical, automatable methods for machine attestation and define the exact action, artifact, and ingestion method into Surveilr for human attestation.

4. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes like containment, correction, or violation sanction, along with a specific time-bound metric (KPI/SLA).

5. **Scope Definition**: Explicitly define the policy's scope to include all relevant entities and environments, covering cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

6. **Responsibilities Section**: Define specific, task-level duties (action verbs and frequency) for each role mentioned. Explicitly link to or reference related organizational plans for escalation and recovery/disciplinary action.

7. **Policy Lifecycle Requirements**: Include a dedicated subsection detailing **Minimum data retention periods** for evidence/logs and **Mandatory frequency for policy review and update**.

8. **Formal Documentation and Audit**: Require **Workforce member acknowledgement/attestation** of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

9. **Prohibited Content**: Do not write or embed SQL queries, code blocks, or pseudo-code. References subsections must not appear within policy sections.

10. **Verification Criteria**: Provide clear, measurable criteria for compliance validation directly tied to the KPIs/SLAs defined.

11. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code. 

12. **Hyperlinks**: Use [Link Text](URL) format for external references.

13. **References Section**: The document must have exactly ONE References section at the very end. 

14. **Keyword Emphasis**: The policy text **MUST** explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**. 

15. **Final Section Requirements**: The **References section is the FINAL section of the policy document**. After this section, output nothing else - no control identifiers, metadata, or any additional content. 

16. **References Section Format**: If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by a single line containing "None". 

Remember to ensure that each policy section does NOT include References subsections and that the policy document ends with exactly ONE References section.