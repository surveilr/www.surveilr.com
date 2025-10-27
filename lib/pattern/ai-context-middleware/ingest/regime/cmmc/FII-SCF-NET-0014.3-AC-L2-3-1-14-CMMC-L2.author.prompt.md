---
title: "Author Prompt: Remote Access Security Policy for CMMC Compliance"
weight: 1
description: "Establishes secure remote access protocols to protect sensitive data by routing connections through managed network access control points."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.14"
control-question: "Does the organization route all remote accesses through managed network access control points (e.g., VPN concentrator)?"
fiiId: "FII-SCF-NET-0014.3"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L2-3.1.14 (FII: FII-SCF-NET-0014.3). 

The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. 

Each section should be structured as follows:

1. **Document Structure**: Use H2 headings (##) for each major requirement. 
   - Explain the control requirement clearly.
   - Suggest **machine attestation methods** for automated evidence collection (e.g., "Use OSquery to collect remote access logs daily").
   - Include **human attestation methods** where necessary (e.g., "The network administrator must sign off on the quarterly remote access validation report").
   - **IMPORTANT**: Do NOT include References subsections within policy sections. The References section appears ONLY at the very end of the document.

2. **Markdown Elements**: Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. Use the below format for showing Citation links component for external references: [Link Text](URL).

3. **Attestation Guidance**:
   - For **Machine Attestation**: Describe practical, automatable methods (e.g., "Verify that all remote access connections are routed through the VPN by ingesting logs into Surveilr").
   - For **Human Attestation**: Describe precise steps and artifacts (e.g., "The IT manager must sign off on the quarterly remote access audit report").

4. **Operational Detail and Specificity**: Include **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. For processes like containment or violation sanction, include a **bulleted list of 3-5 operational steps** and a **specific time-bound metric (KPI/SLA)**.

5. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include all relevant entities and environments, covering cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

6. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation.

7. **Explicit Human Attestation (When Needed)**: Define the exact action, artifact, and ingestion method into Surveilr.

8. **Granular Roles and Cross-Referencing**: The Responsibilities section must define specific, task-level duties for each role mentioned (e.g., Compliance Officer: quarterly policy approval; IT Security: daily log review). Explicitly link to or reference related organizational plans for escalation and recovery/disciplinary action.

9. **Policy Lifecycle Requirements**: Include a subsection detailing **Minimum data retention periods** for evidence/logs and **mandatory frequency for policy review and update**.

10. **Formal Documentation and Audit**: Require **workforce member acknowledgement/attestation** of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

11. **Evidence Collection Methods**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

12. **Verification Criteria**: Clear measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

13. **Hyperlinks**: Use [Link Text](URL) format for external references.

14. **Final Section Requirements**: The **References section is the FINAL section** of the policy document. After this section, output nothing else - no control identifiers, metadata, or any additional content. 

15. **References Section Format**: If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by a single line containing "None".

Ensure that all **enforced keywords** such as **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review** are **BOLD** in the policy text. Failure to comply with any of these requirements will result in a non-compliance rating.