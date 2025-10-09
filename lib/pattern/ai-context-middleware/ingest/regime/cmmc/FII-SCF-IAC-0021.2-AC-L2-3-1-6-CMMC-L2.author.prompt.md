---
title: "Author Prompt: Privileged Account Usage Security Policy"
weight: 1
description: "Enforces the prohibition of privileged users using privileged accounts for non-security functions to protect sensitive data and maintain compliance."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.6"
control-question: "Does the organization prohibit privileged users from using privileged accounts, while performing non-security functions?"
fiiId: "FII-SCF-IAC-0021.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "AC.L2-3.1.6" (FII: "FII-SCF-IAC-0021.2"). 

The policy must follow these guidelines:

1. **Document Structure**: 
   - Use the mandatory section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.**
   - Each section must clearly explain the control requirement, suggest machine attestation methods, and outline human attestation methods when necessary. 

2. **Markdown Elements**:
   - Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. 
   - Provide hyperlinks in the format: [Link Text](URL).

3. **Attestation Guidance**:
   - For Machine Attestation: Describe practical, automatable methods for compliance validation.
   - For Human Attestation: Specify the exact action, artifact, and how it will be ingested into Surveilr.

4. **Operational Detail and Specificity**:
   - Use **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions.
   - Include a **bulleted list of 3-5 operational steps** for processes like containment, correction, or violation sanction, with a specific time-bound metric (KPI/SLA).

5. **Comprehensive Scope Definition**:
   - Explicitly define the policy's scope to include all relevant entities, environments, and channels related to ePHI.

6. **Prioritize Machine Attestation**:
   - For each requirement, provide concrete examples of automated evidence collection and validation.

7. **Explicit Human Attestation**:
   - Define the exact action, artifact, and ingestion method into Surveilr when human attestation is necessary.

8. **Granular Roles and Cross-Referencing**:
   - Define specific, task-level duties for each role mentioned and link to related organizational plans.

9. **Policy Lifecycle Requirements**:
   - Include minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

10. **Formal Documentation and Audit**:
    - Require workforce member acknowledgement/attestation of understanding and compliance, comprehensive audit logging, and formal documentation for exceptions.

11. **Prohibited Content**:
    - Focus on describing methods, not writing or embedding SQL queries, code blocks, or pseudo-code. 

12. **Evidence Collection Methods**:
    - Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

13. **Verification Criteria**:
    - Clearly define measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

14. **Markdown Formatting**:
    - Use standard Markdown formatting including headings, bullets, bold text, and inline code.

15. **Hyperlinks**:
    - Use [Link Text](URL) format for external references.

16. **Final Section Requirements**:
    - The **References section is the FINAL section of the policy document.** Ensure there are no References subsections within individual policy sections.

17. **References Section Format**:
    - If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by "None".

18. **Keyword Emphasis**:
    - The policy text **MUST** explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**. 

Ensure that the policy maximizes machine attestability and that every section includes attestation guidance. Do not include any conversational filler or additional content after the References section.