---
title: "Author Prompt: Public Access Content Security Policy"
weight: 1
description: "Establishes measures to control publicly-accessible content, safeguarding sensitive information and ensuring compliance with regulatory standards."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L1-3.1.22"
control-question: "Does the organization control publicly-accessible content?"
fiiId: "FII-SCF-DCH-0015"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Data Classification & Handling"
category: ["CMMC", "Level 1", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L1-3.1.22 (FII: FII-SCF-DCH-0015). 

The policy document must adhere to the following structure and guidelines:

1. **Document Structure**: The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. 

2. **Policy Sections**: Each section should:
   - Explain the control requirement.
   - Suggest machine attestation methods (e.g., "Use OSquery to collect asset inventories daily").
   - Suggest human attestation methods where unavoidable (e.g., "Manager signs quarterly inventory validation report").
   - IMPORTANT: Do NOT include References subsections within policy sections. The References section appears ONLY at the very end of the document.

3. **Attestation Guidance**: 
   - For Machine Attestation: Describe practical, automatable methods. Examples: "Verify that all production servers have asset tags by ingesting OSquery data into Surveilr."
   - For Human Attestation: Describe precise steps and artifacts. Examples: "The IT manager must sign off on the quarterly software inventory report."

4. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps and a specific time-bound metric (KPI/SLA).

5. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, covering **cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates)**, and **all channels** used to create, receive, maintain, or transmit ePHI.

6. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation.

7. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr.

8. **Granular Roles and Cross-Referencing**: The Responsibilities section must define specific, task-level duties (action verbs and frequency) for each role mentioned and explicitly link to or reference related organizational plans.

9. **Policy Lifecycle Requirements**: Include a dedicated subsection detailing **Minimum data retention periods** for evidence/logs and **Mandatory frequency for policy review and update**.

10. **Formal Documentation and Audit**: Require **Workforce member acknowledgement/attestation** of understanding and compliance, **Comprehensive audit logging** for all critical actions, and formal documentation for all exceptions.

11. **Evidence Collection Methods**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

12. **Verification Criteria**: Provide clear measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

13. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

14. **Hyperlinks**: Use [Link Text](URL) format for external references.

15. **Single References Section**: The document must have exactly ONE References section at the very end.

16. **Keyword Emphasis**: The policy text must explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

17. **Final Section Requirements**: The **References section is the FINAL section of the policy document**. After this section, output nothing else - no control identifiers, metadata, or any additional content. 

### References
None