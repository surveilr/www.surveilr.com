---
title: "Author Prompt: ePHI Protection Policy"
weight: 1
description: "Establishes requirements to protect ePHI from unauthorized access by larger organizations."
publishDate: "2025-09-25"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(4)(ii)(A)"
control-question: "If you are a clearinghouse that is part of a larger organization, have you implemented policies and procedures to protect EPHI from the larger organization? (A)"
fiiId: "FII-SCF-IAC-0001"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "If you are a clearinghouse that is part of a larger organization, have you implemented policies and procedures to protect EPHI from the larger organization?" (FII: FII-SCF-IAC-0001). 

The policy document must include the following structure and guidelines:

1. **Document Structure**:
   - **Introduction**: Clearly state the purpose of the policy.
   - **Policy Sections**: Use H2 headings (##) for each major requirement.
     - Explain the control requirement.
     - Suggest machine attestation methods (e.g., "Use OSquery to collect asset inventories daily").
     - Suggest human attestation methods where unavoidable (e.g., "Manager signs quarterly inventory validation report").
   - **References**: End with ### References.

2. **Markdown Elements**:
   - Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms.
   - Use the following format for showing Citation links for external references: [Link Text](URL).

3. **Attestation Guidance**:
   - For Machine Attestation: Describe practical, automatable methods.
     - Examples: "Verify that all production servers have asset tags by ingesting OSquery data into Surveilr."
   - For Human Attestation: Describe precise steps and artifacts.
     - Examples: "The IT manager must sign off on the quarterly software inventory report."

4. **Format**: 
   - Clear sections (Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, References) in markdown format.
   
5. **Operational Detail and Specificity (MANDATORY SMART)**: 
   - The policy must contain specific, measurable, actionable, relevant, and time-bound (SMART) instructions, with a bulleted list of 3-5 operational steps and a specific time-bound metric (KPI/SLA).

6. **Comprehensive Scope Definition (MANDATORY)**: 
   - Explicitly define the policy's scope to include all relevant entities and environments, covering cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

7. **Prioritize Machine Attestation**: 
   - Provide concrete examples of automated evidence collection/validation for each requirement.

8. **Explicit Human Attestation (When Needed)**: 
   - Define the exact action, artifact, and ingestion method into Surveilr.

9. **Granular Roles and Cross-Referencing (MANDATORY)**: 
   - Define specific, task-level duties for each role mentioned and explicitly link to or reference related organizational plans.

10. **Policy Lifecycle Requirements (MANDATORY)**: 
    - Include a dedicated subsection detailing minimum data retention periods for evidence/logs and mandatory policy review frequency.

11. **Formal Documentation and Audit (MANDATORY)**: 
    - Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

12. **Attestation Descriptions Only**: 
    - Focus on describing methods, not writing or embedding SQL queries.

13. **Evidence Collection Methods**: 
    - Must include subheadings per requirement with explanations, machine attestation approaches, and human attestation (if unavoidable).

14. **Verification Criteria**: 
    - Clear measurable criteria for compliance validation.

15. **Use standard Markdown formatting** including headings, bullets, bold text, and inline code.

16. **End with the References section**: The References section is the FINAL section of the policy document. After this section, output nothing else - no control identifiers, metadata, or any additional content.

The policy must maximize machine attestability while explicitly documenting where human attestation is unavoidable.