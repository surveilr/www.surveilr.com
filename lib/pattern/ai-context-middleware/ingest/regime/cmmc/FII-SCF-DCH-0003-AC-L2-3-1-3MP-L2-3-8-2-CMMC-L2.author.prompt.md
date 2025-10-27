---
title: "Author Prompt: Media Access Control and Security Policy"
weight: 1
description: "Establishes guidelines to restrict access to sensitive digital and non-digital media, ensuring only authorized personnel can handle such information."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.3
MP.L2-3.8.2"
control-question: "Does the organization control and restrict access to digital and non-digital media to authorized individuals?"
fiiId: "FII-SCF-DCH-0003"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L2-3.1.3 (FII: FII-SCF-DCH-0003). 

Please ensure the policy adheres to the following structure and requirements:

1. **Document Structure**: The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. 

2. **Policy Sections**: 
   - Each section should be marked with H2 headings (##) and must:
     - Explain the control requirement clearly.
     - Suggest machine attestation methods, e.g., "Use OSquery to collect asset inventories daily".
     - Suggest human attestation methods where necessary, e.g., "Manager signs quarterly inventory validation report".
   - Do NOT include References subsections within policy sections. The References section appears ONLY at the very end of the document.

3. **Markdown Elements**: Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. 

4. **Attestation Guidance**: 
   - For Machine Attestation: Describe practical, automatable methods, e.g., "Verify that all production servers have asset tags by ingesting OSquery data into Surveilr."
   - For Human Attestation: Describe precise steps and artifacts, e.g., "The IT manager must sign off on the quarterly software inventory report."

5. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes like containment or correction and a specific time-bound metric (KPI/SLA).

6. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, including cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

7. **Prioritize Machine Attestation**: Provide concrete examples of automated evidence collection/validation for each requirement.

8. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr when human attestation is required.

9. **Granular Roles and Cross-Referencing**: The Responsibilities section must define specific, task-level duties for each role, linking to related organizational plans for escalation and recovery/disciplinary action.

10. **Policy Lifecycle Requirements**: Include a dedicated subsection detailing minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

11. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

12. **Evidence Collection Methods Structure**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

13. **Verification Criteria**: Provide clear, measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

14. **Hyperlinks**: Use [Link Text](URL) format for external references.

15. **Keyword Emphasis**: The policy text must explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

16. **Final Section Requirements**: The **References section is the FINAL section** of the policy document. After this section, output nothing else.

17. **References Section Format**: List external references under ### References using [Link Text](URL) format, or if none exist, output "### References" followed by "None".

Make sure all instructions are followed precisely for a 100% compliance score.