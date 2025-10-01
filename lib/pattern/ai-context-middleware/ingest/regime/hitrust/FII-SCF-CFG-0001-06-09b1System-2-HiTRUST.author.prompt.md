---
title: "Author Prompt: Change Management Policy for Information Systems"
weight: 1
description: "Establishes a framework for documenting, testing, and approving changes to information systems managing electronic Protected Health Information (ePHI)."
publishDate: "2025-09-30"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "06.09b1System.2"
control-question: "Changes to information systems (including changes to applications, databases, configurations, network devices, and operating systems and with the potential exception of automated security patches) are consistently documented, tested, and approved."
fiiId: "FII-SCF-CFG-0001"
regimeType: "HiTRUST"
category: ["HiTRUST", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: 06.09b1System.2 (FII: FII-SCF-CFG-0001). 

### Instructions:

1. **Document Structure**: The policy MUST follow this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** Ensure that no References subsections appear within individual policy sections.

2. **Policy Sections**: Each major requirement section should include:
   - An explanation of the control requirement.
   - Suggested machine attestation methods (e.g., "Use OSquery to collect asset inventories daily").
   - Suggested human attestation methods where unavoidable (e.g., "Manager signs quarterly inventory validation report").
   - Ensure all sections use H2 headings (##) and do not include References subsections.

3. **SMART Objectives**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes like containment, correction, or violation sanction, along with a specific time-bound metric (KPI/SLA).

4. **Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, covering **cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates)**, and **all channels** used to create, receive, maintain, or transmit ePHI.

5. **Attestation Guidance**: For each requirement, provide concrete examples of automated evidence collection/validation and define the exact action, artifact, and ingestion method into Surveilr for human attestation when needed.

6. **Roles and Responsibilities**: Define specific, task-level duties (action verbs and frequency) for each role mentioned. Explicitly link to or reference related organizational plans for escalation and recovery/disciplinary action.

7. **Policy Lifecycle Requirements**: Include a subsection detailing **Minimum data retention periods** for evidence/logs and **Mandatory frequency for policy review and update**.

8. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

9. **Evidence Collection Methods**: Use the structure with numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

10. **Verification Criteria**: Provide clear, measurable criteria for compliance validation, directly tied to the **KPIs/SLAs** defined in the SMART objectives.

11. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

12. **Hyperlinks**: Format external references using [Link Text](URL).

13. **Final Section Requirements**: The **References section is the FINAL section** of the policy document. After this section, output nothing else. 

14. **References Section Format**: If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by a single line containing "None".

15. **Keyword Emphasis**: The policy text MUST explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**. 

Ensure that every policy section maximizes machine attestability and provides explicit human attestation methods where necessary. The policy document should conclude with exactly ONE References section.