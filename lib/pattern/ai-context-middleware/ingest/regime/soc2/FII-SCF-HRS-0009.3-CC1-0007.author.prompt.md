---
title: "Author Prompt: Recruitment Policy Framework"
weight: 1
description: "Establishes a structured and compliant framework for the organization's recruitment process."
publishDate: "2025-09-25"
publishBy: "AICPA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "CC1-0007"
control-question: "How are candidates recruited for job openings? Evidence could include the recruitment policies and procedures; a PowerPoint deck, a questionnaire, job opening postings, or emails."
fiiId: "FII-SCF-HRS-0009.3"
regimeType: "SOC2-TypeI"
category: ["AICPA", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control : "" (FII: FII-SCF-HRS-0009.3). 

The policy document must include the following structure and requirements:

1. **Document Structure**:
   - **Front Matter (YAML Header)**: Include required metadata fields: title, weight, description, publishDate, publishBy, classification, documentVersion, documentType, control-id (set to ""), control-question (set to "How are candidates recruited for job openings?"), fiiId (set to "FII-SCF-HRS-0009.3"), regimeType, category (as array), merge-group, and order.
   - **Introduction**: Concise purpose of the policy.
   - **Policy Sections**: Use H2 headings (##) for each major requirement. Each section should:
     - Explain the control requirement.
     - Suggest machine attestation methods (e.g., "Use API integrations to gather recruitment data from job postings and applicant tracking systems daily").
     - Suggest human attestation methods where unavoidable (e.g., "HR manager reviews and certifies the recruitment process quarterly").

2. **Markdown Elements**: Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. Use the format for showing Citation links for external references: [Link Text](URL).

3. **Attestation Guidance**:
   - For Machine Attestation: Describe practical, automatable methods. Examples: 
     - "Verify recruitment policy compliance by ingesting recruitment data into Surveilr."
     - "Check for adherence to job posting standards by comparing ingested job postings against approved templates."
   - For Human Attestation: Describe precise steps and artifacts. Examples:
     - "The HR manager must sign off on the quarterly recruitment report."
     - "Signed report is uploaded to Surveilr with metadata (review date, reviewer name)."

4. **Format**: Clear sections (Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, References) in markdown format.

5. **Operational Detail and Specificity (MANDATORY SMART)**: The policy **MUST** replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. For processes like recruitment, the policy **MUST** contain a **bulleted list of 3-5 operational steps** (e.g., post job openings, screen applications, interview candidates) and a **specific time-bound metric (KPI/SLA)** (e.g., complete candidate screening within 10 business days).

6. **Comprehensive Scope Definition (MANDATORY)**: Explicitly define the policy's scope to include ALL relevant entities and environments, such as **cloud-hosted systems, SaaS applications, and third-party vendor systems**.

7. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation.

8. **Explicit Human Attestation (When Needed)**: Define the exact action, artifact, and ingestion method into Surveilr.

9. **Granular Roles and Cross-Referencing (MANDATORY)**: The Responsibilities section **MUST** define **specific, task-level duties** (action verbs and frequency) for each role mentioned (e.g., HR Manager: monthly review of recruitment policies; Recruitment Officer: weekly update of job postings). **Explicitly link to or reference** related organizational plans (e.g., Recruitment Plan).

10. **Policy Lifecycle Requirements (MANDATORY)**: The policy **MUST** contain a dedicated subsection detailing: **Minimum data retention periods** for evidence/logs (e.g., 'retain for 5 years'). **Mandatory frequency for policy review and update** (e.g., 'reviewed at least annually').

11. **Formal Documentation and Audit (MANDATORY)**: The policy **MUST** require: **Workforce member acknowledgement/attestation** of understanding and compliance. **Comprehensive audit logging** for all critical actions (creation, modification, termination). Formal documentation for all exceptions (justification, duration, approval).

12. **Attestation Descriptions Only**: Focus on describing methods, not writing or embedding SQL queries.

13. **Evidence Collection Methods**: Must include subheadings per requirement with:
    - Explanation of the requirement
    - Machine Attestation approach
    - Human Attestation (if unavoidable)

14. **Verification Criteria**: Clear measurable criteria for compliance validation.

15. **Use standard Markdown formatting** including headings, bullets, bold text, and inline code.

16. **Use [Link Text](URL) format for external references**.

17. **End with ### References section**. 

18. **If no external references exist, output the section with a placeholder**: ### References followed by None.

The policy document must conclude at the References section with no additional content.