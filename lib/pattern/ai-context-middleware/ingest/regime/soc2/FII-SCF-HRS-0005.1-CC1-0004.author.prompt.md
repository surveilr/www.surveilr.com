---
title: "Author Prompt: Employee Handbook Compliance Policy"
weight: 1
description: "Establishes requirements for maintaining, accessing, and verifying compliance with the employee handbook."
publishDate: "2025-09-25"
publishBy: "AICPA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "CC1-0004"
control-question: "Is there an employee handbook in place, and does it include the organization's entity values and behavioral standards? If yes, how is it made available for all employees?"
fiiId: "FII-SCF-HRS-0005.1"
regimeType: "SOC2-TypeI"
category: ["AICPA", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "" (FII: FII-SCF-HRS-0005.1). 

The policy document should be structured in the following format:

1. **Front Matter (YAML Header)**: Include required metadata fields: 
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

2. **Introduction**: Provide a concise purpose of the policy.

3. **Policy Sections**: Use H2 headings (##) for each major requirement. Each section should:
   - Explain the control requirement.
   - Suggest machine attestation methods (e.g., "Collect employee handbook versions via document management systems daily").
   - Suggest human attestation methods where unavoidable (e.g., "HR manager certifies the availability of the handbook quarterly").

4. **Markdown Elements**: Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. Use the format for showing Citation links for external references: [Link Text](URL).

5. **Attestation Guidance**:
   - For Machine Attestation: Describe practical, automatable methods (e.g., "Verify that the employee handbook is accessible to all employees via intranet logs").
   - For Human Attestation: Describe precise steps and artifacts (e.g., "The HR department must maintain a signed acknowledgment of handbook receipt").

6. **Format**: Include clear sections: Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, References.

7. **Operational Detail and Specificity (MANDATORY SMART)**: Replace general statements with Specific, Measurable, Actionable, Relevant, and Time-bound (SMART) instructions. Include a bulleted list of 3-5 operational steps and a specific time-bound metric.

8. **Comprehensive Scope Definition (MANDATORY)**: Explicitly define the policy's scope to cover cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

9. **Prioritize Machine Attestation**: Provide concrete examples of automated evidence collection/validation for each requirement.

10. **Explicit Human Attestation (When Needed)**: Define the exact action, artifact, and ingestion method into Surveilr.

11. **Granular Roles and Cross-Referencing (MANDATORY)**: Define specific duties for each role mentioned and link to related organizational plans.

12. **Policy Lifecycle Requirements (MANDATORY)**: Include minimum data retention periods and mandatory frequency for policy review and update.

13. **Formal Documentation and Audit (MANDATORY)**: Require workforce acknowledgment of understanding and compliance, comprehensive audit logging, and formal documentation for exceptions.

14. **Attestation Descriptions Only**: Focus on methods, not SQL queries.

15. **Evidence Collection Methods**: Include subheadings per requirement with explanations, machine attestation approaches, and human attestation.

16. **Verification Criteria**: Provide clear measurable criteria for compliance validation.

17. **Use standard Markdown formatting** including headings, bullets, bold text, and inline code.

18. **Use [Link Text](URL) format** for external references.

19. **End with the References section**. 

20. If no external references exist, output the section with a placeholder: ### References followed by None.

Ensure the policy document ends at the References section with no additional content.