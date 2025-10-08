---
title: "Author Prompt: Automated Inactive Account Disabling Policy"
weight: 1
description: "Establishes automated processes to disable inactive user accounts, enhancing security and compliance with CMMC control IA.L2-3.5.6."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "IA.L2-3.5.6"
control-question: "Does the organization use automated mechanisms to disable inactive accounts after an organization-defined time period?"
fiiId: "FII-SCF-IAC-0015.3"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "IA.L2-3.5.6" (FII: "FII-SCF-IAC-0015.3"). 

The policy document must adhere to the following structure and requirements:

1. **Document Structure**: The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Ensure that no References subsections appear within policy sections; the References section should only be at the very end of the document.

2. **Policy Sections**: Each major requirement section must be formatted with H2 headings (##) and include:
   - An explanation of the control requirement.
   - Suggested machine attestation methods.
   - Suggested human attestation methods where unavoidable.
   - All sections must include clear, actionable, and specific instructions that adhere to **SMART** criteria.

3. **Attestation Guidance**: 
   - For **Machine Attestation**, describe practical automated methods (e.g., "Use OSquery to collect user account activity data daily").
   - For **Human Attestation**, specify the exact actions and artifacts (e.g., "The IT manager must sign the quarterly user account review report").

4. **Operational Detail and Specificity**: Include a bulleted list of **3-5 operational steps** related to processes like account disabling, with a defined time-bound metric (KPI/SLA) such as "disable inactive accounts within 30 days".

5. **Scope Definition**: Clearly define the policy’s scope to include all relevant entities and environments, including cloud-hosted systems, SaaS applications, and third-party vendor systems.

6. **Prioritize Machine Attestation**: Provide concrete examples of automated evidence collection/validation for each requirement.

7. **Explicit Human Attestation**: Define the action, artifact, and how it will be ingested into Surveilr.

8. **Granular Roles and Cross-Referencing**: Specify task-level duties for each role in the Responsibilities section and link to related organizational plans.

9. **Policy Lifecycle Requirements**: Include a subsection detailing minimum data retention periods for evidence/logs and mandatory review frequency (e.g., "reviewed at least annually").

10. **Formal Documentation and Audit**: Require workforce acknowledgment of understanding and compliance, comprehensive audit logging, and documentation of exceptions.

11. **Evidence Collection Methods Structure**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

12. **Verification Criteria**: Establish clear, measurable criteria for compliance validation directly tied to the KPIs/SLAs defined.

13. **Markdown Formatting**: Use standard Markdown formatting, including headings, bullets, and bold text for emphasis.

14. **Hyperlinks**: Use [Link Text](URL) format for any external references.

15. **References Section**: The document must contain exactly ONE References section at the very end.

16. **Keyword Emphasis**: The policy text must explicitly use and **BOLD** the keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

17. **Final Section Requirements**: Ensure that the References section is the only content at the end of the document, and do not include control identifiers, metadata, or any additional content.

Create a comprehensive policy that ensures compliance with the specified CMMC control while maximizing machine attestability.