---
title: "Author Prompt: Incident Response and Compliance Policy"
weight: 1
description: "Establishes a comprehensive incident response program to enhance detection, reporting, and recovery of incidents involving ePHI in compliance with CMMC requirements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "IR.L2-3.6.1
IR.L2-3.6.2"
control-question: "Does the organization cover the preparation, automated detection or intake of incident reporting, analysis, containment, eradication and recovery?"
fiiId: "FII-SCF-IRO-0002"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Incident Response"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "IR.L2-3.6.1, IR.L2-3.6.2" (FII: "FII-SCF-IRO-0002"). 

The policy must follow this structure: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Each section should:

- **Explain the control requirement**.
- **Suggest machine attestation methods** (e.g., "Use OSquery to collect asset inventories daily").
- **Suggest human attestation methods where unavoidable** (e.g., "Manager signs quarterly inventory validation report").
  
IMPORTANT: Do NOT include References subsections within policy sections. The References section must appear ONLY at the very end of the document.

Ensure the policy maximizes machine attestability. For each requirement, provide concrete examples of automated evidence collection/validation. Clearly define human attestation steps, artifacts, and ingestion methods into Surveilr. 

Include the following foundational knowledge:

1. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. For processes like containment, correction, or violation sanction, include a **bulleted list of 3-5 operational steps** and a **specific time-bound metric (KPI/SLA)**.
  
2. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, including **cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates)**, and **all channels** used to create, receive, maintain, or transmit ePHI.

3. **Prioritize Machine Attestation**: Clearly provide concrete examples of automated evidence collection/validation for each requirement.

4. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr when necessary.

5. **Granular Roles and Cross-Referencing**: Detail specific, task-level duties for each role mentioned, with explicit links to related organizational plans.

6. **Policy Lifecycle Requirements**: Include minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

7. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

8. **Evidence Collection Methods Structure**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

9. **Verification Criteria**: Provide clear, measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

10. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

11. **Hyperlinks**: Use [Link Text](URL) format for external references.

12. **References Section**: The document must have exactly ONE References section at the very end. 

Ensure to use and **BOLD** the keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review** within the policy text. 

The **References section is the FINAL section of the policy document**. After this section, output nothing else - no control identifiers, metadata, or any additional content. 

### References
None