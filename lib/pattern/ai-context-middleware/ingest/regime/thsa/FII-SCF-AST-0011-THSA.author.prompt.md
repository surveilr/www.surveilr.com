---
title: "Author Prompt: Control of Systems Access and Tracking Policy"
weight: 1
description: "Establishes systematic control and tracking of systems entering and exiting organizational facilities to safeguard assets and ensure compliance with ePHI regulations."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "FII-SCF-AST-0011"
control-question: "Does the organization authorize, control and track systems entering and exiting organizational facilities?"
fiiId: "FII-SCF-AST-0011"
regimeType: "THSA"
category: ["THSA", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "Does the organization authorize, control and track systems entering and exiting organizational facilities?" (FII: FII-SCF-AST-0011). 

1. **Document Structure**: Create the policy with the following mandatory sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. 

2. **Policy Sections**: Each section must:
   - Explain the control requirement.
   - Suggest machine attestation methods (e.g., "Use OSquery to collect asset inventories daily").
   - Suggest human attestation methods where unavoidable (e.g., "Manager signs quarterly inventory validation report").
   - IMPORTANT: Do NOT include References subsections within policy sections; the References section appears ONLY at the very end of the document.

3. **Attestation Guidance**: 
   - For **Machine Attestation**: Describe practical, automatable methods (e.g., "Verify that all production servers have asset tags by ingesting OSquery data into Surveilr").
   - For **Human Attestation**: Describe precise steps and artifacts (e.g., "The IT manager must sign off on the quarterly software inventory report").

4. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a **bulleted list of 3-5 operational steps** for processes like containment, correction, or violation sanction, with a **specific time-bound metric (KPI/SLA)** (e.g., contain within 48 hours).

5. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, such as **cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates)**, and **all channels** used to create, receive, maintain, or transmit ePHI.

6. **Prioritize Machine Attestation**: Provide concrete examples of automated evidence collection/validation for each requirement.

7. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr when human attestation is required.

8. **Granular Roles and Cross-Referencing**: Specify task-level duties (action verbs and frequency) for each role mentioned in the Responsibilities section and link to related organizational plans (e.g., Incident Response Plan).

9. **Policy Lifecycle Requirements**: Include a dedicated subsection detailing **Minimum data retention periods** for evidence/logs (e.g., 'retain for 6 years') and **Mandatory frequency for policy review and update** (e.g., 'reviewed at least annually').

10. **Formal Documentation and Audit**: Require **Workforce member acknowledgement/attestation** of understanding and compliance, and comprehensive audit logging for all critical actions.

11. **Evidence Collection Methods Structure**: Use numbered subheadings per requirement in the format: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

12. **Verification Criteria**: Establish clear, measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined in Requirement 4.

13. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

14. **Hyperlinks**: Use [Link Text](URL) format for external references.

15. **Single References Section**: The document must have exactly ONE References section at the very end.

16. **Keyword Emphasis**: The policy text MUST explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

17. **Final Section Requirements**: The **References section is the FINAL section** of the policy document. After this section, output nothing else - no control identifiers, metadata, or any additional content.

### References
None