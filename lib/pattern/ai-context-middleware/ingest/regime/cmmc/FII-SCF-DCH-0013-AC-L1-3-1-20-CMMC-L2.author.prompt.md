---
title: "Author Prompt: External Data Handling Security Policy"
weight: 1
description: "Establishes guidelines to ensure secure handling of sensitive data by external parties, systems, and services in compliance with CMMC standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L1-3.1.20"
control-question: "Does the organization govern how external parties, systems and services are used to securely store, process and transmit data?"
fiiId: "FII-SCF-DCH-0013"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L1-3.1.20 (FII: FII-SCF-DCH-0013). 

### Policy Structure Instructions:
1. **Document Structure**: The policy **MUST** follow this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. 

2. **Policy Sections**: Use H2 headings (##) for each major requirement. Each section should:
   - Explain the control requirement.
   - Suggest **machine attestation methods** (e.g., "Use OSquery to collect asset inventories daily").
   - Suggest **human attestation methods** where unavoidable (e.g., "Manager signs quarterly inventory validation report").
   - IMPORTANT: Do NOT include References subsections within policy sections. The References section appears ONLY at the very end of the document.

3. **Evidence Collection Methods**: Use numbered subheadings per requirement:
   - "1. REQUIREMENT:"
   - "2. MACHINE ATTESTATION:"
   - "3. HUMAN ATTESTATION:"

4. **SMART Instructions**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. For processes like containment or violation sanction, include a **bulleted list of 3-5 operational steps** (e.g., isolate system, retrain user) and a **specific time-bound metric (KPI/SLA)** (e.g., contain within 48 hours).

5. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, covering **cloud-hosted systems, SaaS applications, third-party vendor systems**, and **all channels** used to create, receive, maintain, or transmit data.

6. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation.

7. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr when human attestation is needed.

8. **Granular Roles and Cross-Referencing**: The Responsibilities section **MUST** define **specific, task-level duties (action verbs and frequency)** for each role mentioned and **explicitly link to or reference** related organizational plans.

9. **Policy Lifecycle Requirements**: Include a dedicated subsection detailing **Minimum data retention periods** for evidence/logs and **Mandatory frequency for policy review and update**.

10. **Formal Documentation and Audit**: The policy **MUST** require **Workforce member acknowledgement/attestation** of understanding and compliance and **Comprehensive audit logging** for all critical actions.

11. **Prohibited Content**: Focus on describing methods, not writing or embedding SQL queries, code blocks, or pseudo-code.

12. **Verification Criteria**: Clear measurable criteria for compliance validation **must be directly tied to the KPIs/SLAs** defined.

13. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

14. **Hyperlinks**: Use [Link Text](URL) format for external references.

15. **Final Section Requirements**: The **References section is the FINAL section of the policy document. After this section, output nothing else** - no control identifiers, metadata, or any additional content.

### Additional Requirements:
- The policy text **MUST** explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.
- The document must have exactly ONE References section at the very end.

### End of Instructions
### References Section Format:
- If external references exist, list them under ### References using [Link Text](URL) format.
- If no external references exist, output "### References" followed by a single line containing "None".
- CRITICAL: Do not output References subsections within individual policy sections - only at the document end.