---
title: "Author Prompt: Multi-Factor Authentication Policy for Network Access"
weight: 1
description: "Implement Multi-Factor Authentication (MFA) to enhance network security and protect non-privileged accounts from unauthorized access."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "IA.L2-3.5.3"
control-question: "Does the organization utilize Multi-Factor Authentication (MFA) to authenticate network access for non-privileged accounts?"
fiiId: "FII-SCF-IAC-0006.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: IA.L2-3.5.3 (FII: FII-SCF-IAC-0006.2). 

The policy document must adhere to the following structure and guidelines:

1. **Document Structure**: 
   - Follow the mandatory order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**.
   - Each section must clearly explain the control requirement, suggest machine attestation methods, and include human attestation methods where automation is impractical.

2. **Markdown Formatting**: 
   - Use H2 headings (##) for major sections.
   - Employ standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms.
   - Do NOT include References subsections within policy sections; the References section appears ONLY at the very end of the document.

3. **Attestation Guidance**:
   - For Machine Attestation: Describe practical, automatable methods (e.g., "Use OSquery to collect MFA configuration details").
   - For Human Attestation: Specify exact actions, artifacts, and ingestion methods into Surveilr (e.g., "IT manager signs the MFA configuration review report").

4. **Operational Detail and Specificity**: 
   - Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions.
   - Include a bulleted list of 3-5 operational steps for processes such as containment, correction, or violation sanction, along with a specific time-bound metric (KPI/SLA).

5. **Comprehensive Scope Definition**: 
   - Define the policy's scope explicitly to include ALL relevant entities and environments, such as cloud-hosted systems, SaaS applications, and third-party vendor systems.

6. **Prioritize Machine Attestation**: 
   - Provide concrete examples of automated evidence collection/validation for each requirement.

7. **Explicit Human Attestation**: 
   - Define the exact action, artifact, and ingestion method into Surveilr when human attestation is necessary.

8. **Granular Roles and Cross-Referencing**: 
   - Define specific, task-level duties for each role mentioned, using action verbs and frequency.
   - Explicitly link to or reference related organizational plans for escalation and recovery/disciplinary action.

9. **Policy Lifecycle Requirements**: 
   - Include a subsection detailing minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

10. **Formal Documentation and Audit**: 
    - Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for critical actions, and formal documentation for all exceptions.

11. **Verification Criteria**: 
    - Establish clear, measurable criteria for compliance validation that are directly tied to the defined KPIs/SLAs.

12. **Keyword Emphasis**: 
    - Explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

13. **Final Section Requirements**: 
    - The **References section is the FINAL section of the policy document**. After this section, output nothing else. 

14. **References Section Format**: 
    - If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by a single line containing "None".

Ensure that the policy maximizes machine attestability and includes specific attestation methods for each requirement.