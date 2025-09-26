---
title: "Author Prompt: EPHI Access Control Policy"
weight: 1
description: "Establish guidelines for granting access to electronic protected health information based on legitimate needs and documented procedures."
publishDate: "2025-09-25"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(4)(ii)(B)"
control-question: "Have you implemented policies and procedures for granting access to EPHI, for example, through access to a workstation, transaction, program, or process? (A)"
fiiId: "FII-SCF-IAC-0001"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "164.308(a)(4)(ii)(B)" (FII: "FII-SCF-IAC-0001"). 

### Policy Document Structure:
1. **Introduction**: Provide a concise purpose of the policy.
2. **Policy Sections**: Use H2 headings (##) for major requirements, including:
   - Explain the control requirement.
   - Suggest machine attestation methods (e.g., "Use OSquery to collect endpoint access logs daily").
   - Suggest human attestation methods where unavoidable (e.g., "Manager signs quarterly access review report").
3. **Scope**: Define the policy's scope to include all relevant entities and environments, covering cloud-hosted systems, SaaS applications, and third-party vendor systems.
4. **Responsibilities**: Define specific, task-level duties for each role mentioned, linking to related organizational plans (e.g., Incident Response Plan).
5. **Evidence Collection Methods**: Include subheadings per requirement with:
   - Explanation of the requirement.
   - Machine Attestation approach.
   - Human Attestation (if unavoidable).
6. **Verification Criteria**: Specify measurable criteria for compliance validation.
7. **Exceptions**: Outline any exceptions to the policy and their documentation.
8. **Policy Lifecycle Requirements**: Detail minimum data retention periods and mandatory frequency for policy review and update.
9. **Formal Documentation and Audit**: Require workforce member acknowledgment of understanding and compliance, comprehensive audit logging, and formal documentation for exceptions.
10. **Attestation Descriptions Only**: Focus on describing methods without embedding SQL queries.
11. **Markdown Elements**: Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms.
12. **References**: Include a section at the end for citations, using the format [Link Text](URL) for external references.

### Attestation Guidance:
- **Machine Attestation**: Describe practical, automatable methods. Examples:
  - "Automatically collect access logs from endpoints using OSquery."
  - "Validate user access through API integrations with cloud providers."
- **Human Attestation**: Describe precise steps and artifacts. Examples:
  - "The Compliance Officer must sign off on the quarterly access review report."
  - "Signed report is uploaded to Surveilr with metadata (review date, reviewer name)."

The policy must maximize machine attestability while explicitly documenting where human attestation is unavoidable, including methods and limitations.

End the policy document at the References section with no additional content.