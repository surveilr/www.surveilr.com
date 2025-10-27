---
title: "Author Prompt: Mobile Device Connection Security Policy"
weight: 1
description: "Restricts personally-owned mobile devices from connecting to organizational systems to protect sensitive information and ensure compliance with security standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.18"
control-question: "Does the organization restrict the connection of personally-owned, mobile devices to organizational systems and networks?"
fiiId: "FII-SCF-MDM-0006"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Mobile Device Management"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "AC.L2-3.1.18" (FII: FII-SCF-MDM-0006). 

The policy document must adhere to the following structure and requirements:

1. **Document Structure**: The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Important: Do not include References subsections within individual policy sections; the References section should appear only at the end of the document.

2. **Policy Content**:
   - Each section must explain the control requirement clearly.
   - Machine attestation methods must be suggested where applicable, detailing how evidence will be collected and validated (e.g., "Use OSquery to collect asset inventories daily").
   - Where machine attestation is impractical, human attestation methods must be specified with precise actions and artifacts (e.g., "Manager signs quarterly inventory validation report").
   - All policy statements must include **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions, especially for operational processes like containment, correction, or violation sanction. Provide a bulleted list of 3-5 operational steps for each relevant process along with a specific time-bound metric (KPI/SLA).

3. **Comprehensive Scope Definition**: The policy's scope must explicitly include all relevant entities and environments, covering cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

4. **Prioritize Machine Attestation**: Each requirement must provide concrete examples of automated evidence collection/validation, emphasizing machine attestability.

5. **Explicit Human Attestation**: Define the exact actions, artifacts, and how they will be ingested into Surveilr wherever human attestation is necessary.

6. **Granular Roles and Cross-Referencing**: The Responsibilities section must define specific, task-level duties for each role mentioned, using action verbs and frequency. Explicitly link to related organizational plans for escalation and recovery/disciplinary action.

7. **Policy Lifecycle Requirements**: Include a subsection detailing minimum data retention periods for evidence/logs (e.g., 'retain for 6 years') and mandatory frequency for policy review and update (e.g., 'reviewed at least annually').

8. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

9. **Mandatory Structure for Evidence Collection Methods**: Use numbered subheadings for each requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

10. **Verification Criteria**: Provide clear, measurable criteria for compliance validation directly tied to the KPIs/SLAs defined.

11. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text for emphasis, and inline code.

12. **Hyperlinks**: Use [Link Text](URL) format for external references.

13. **References Section**: Ensure that there is exactly ONE References section at the end of the document, and do not output anything else after this section.

14. **Keyword Emphasis**: The policy text must explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

15. **Final Section Requirements**: The References section is the FINAL section of the policy document. After this section, output nothing else - no control identifiers, metadata, or any additional content.

### References
None