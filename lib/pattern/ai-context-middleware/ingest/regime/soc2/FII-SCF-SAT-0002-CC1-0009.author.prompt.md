---
title: "Author Prompt: Mentorship Program Policy"
weight: 1
description: "Establishes a structured mentorship program to enhance employee skills and professional growth within the organization."
publishDate: "2025-09-25"
publishBy: "AICPA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "CC1-0009"
control-question: "Is there a mentor program to develop personnel in place?"
fiiId: "FII-SCF-SAT-0002"
regimeType: "SOC2-TypeI"
category: ["AICPA", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "" (FII: FII-SCF-SAT-0002). 

Your policy document must adhere to the following structure and guidelines:

1. **Document Structure**:
   - **Front Matter (YAML Header)**: Include required metadata fields: 
     - title
     - weight
     - description
     - publishDate
     - publishBy
     - classification
     - documentVersion
     - documentType
     - control-id (set to "")
     - control-question (set to "")
     - fiiId (set to "")
     - regimeType
     - category (as array)
     - merge-group
     - order
   - **Introduction**: Concise purpose of the policy.
   - **Policy Sections**: Use H2 headings (##) per major requirement. Each section should:
     - Explain the control requirement.
     - Suggest machine attestation methods (e.g., "Use OSquery to collect asset inventories daily").
     - Suggest human attestation methods where unavoidable (e.g., "Manager signs quarterly inventory validation report").
   - **References**: End with ### References.

2. **Markdown Elements**:
   - Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms.
   - Use the following format for showing citation links for external references: [Link Text](URL).

3. **Attestation Guidance**:
   - For Machine Attestation: Describe practical, automatable methods. Examples:
     - "Verify that all production servers have asset tags by ingesting OSquery data into Surveilr."
     - "Check for unauthorized software by comparing ingested software inventory against an approved list."
   - For Human Attestation: Describe precise steps and artifacts. Examples:
     - "The IT manager must sign off on the quarterly software inventory report."
     - "Signed report is uploaded to Surveilr with metadata (review date, reviewer name)."

4. **Format**: Clear sections (Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, References) in markdown format.

5. **Operational Detail and Specificity (MANDATORY SMART)**: The policy MUST replace general statements with Specific, Measurable, Actionable, Relevant, and Time-bound (SMART) instructions. For processes like containment, correction, or prevention, the policy MUST contain a bulleted list of 3-5 operational steps (e.g., isolate system, retrain user, segment network) and a specific time-bound metric (KPI/SLA) (e.g., contain within 48 hours, remediate within 5 business days).

6. **Comprehensive Scope Definition (MANDATORY)**: Explicitly define the policy's scope to include ALL relevant entities and environments, covering cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates), and all channels used to create, receive, maintain, or transmit ePHI.

7. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation.

8. **Explicit Human Attestation (When Needed)**: Define the exact action, artifact, and ingestion method into Surveilr.

9. **Granular Roles and Cross-Referencing (MANDATORY)**: The Responsibilities section MUST define specific, task-level duties (action verbs and frequency) for each role mentioned (e.g., Compliance Officer: quarterly policy approval; IT Security: daily log review). Explicitly link to or reference related organizational plans (e.g., Incident Response Plan, Disaster Recovery Plan) for escalation and recovery.

10. **Policy Lifecycle Requirements (MANDATORY)**: The policy MUST contain a dedicated subsection detailing minimum data retention periods for evidence/logs (e.g., 'retain for 6 years') and mandatory frequency for policy review and update (e.g., 'reviewed at least annually').

11. **Formal Documentation and Audit (MANDATORY)**: The policy MUST require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions (creation, modification, termination), and formal documentation for all exceptions (justification, duration, approval).

12. **Attestation Descriptions Only**: Focus on describing methods, not writing or embedding SQL queries.

13. **Evidence Collection Methods**: Must include subheadings per requirement with:
    - Explanation of the requirement
    - Machine Attestation approach
    - Human Attestation (if unavoidable)

14. **Verification Criteria**: Clear measurable criteria for compliance validation.

15. **Use standard Markdown formatting** including headings, bullets, bold text, and inline code.

16. **Use [Link Text](URL) format for external references.**

17. **End with ### References** section.

18. **The References section is the FINAL section of the policy document. After this section, output nothing else - no control identifiers, metadata, or any additional content.**

Ensure the prompt guides the AI to maximize machine attestability while explicitly documenting where human attestation is unavoidable, along with the method and its limitations.