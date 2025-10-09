---
title: "Author Prompt: Critical Systems Documentation and Management Policy"
weight: 1
description: "Establishes requirements for identifying, documenting, and reviewing critical systems to ensure organizational resilience and effective business continuity planning."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "FII-SCF-BCD-0002"
control-question: "Does the organization identify and document the critical systems, applications and services that support essential missions and business functions?"
fiiId: "FII-SCF-BCD-0002"
regimeType: "THSA"
category: ["THSA", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "Does the organization identify and document the critical systems, applications and services that support essential missions and business functions?" (FII: FII-SCF-BCD-0002).

### Policy Structure:
1. **Introduction**
2. **Policy Statement**
3. **Scope**
4. **Responsibilities**
5. **Evidence Collection Methods**
6. **Verification Criteria**
7. **Exceptions**
8. **Lifecycle Requirements**
9. **Formal Documentation and Audit**
10. **References** (This section must be the final section of the document)

### Instructions:
- Each section must use H2 headings (##) and include:
  - An explanation of the control requirement.
  - Suggested machine attestation methods (e.g., "Use OSquery to collect asset inventories daily").
  - Suggested human attestation methods where necessary (e.g., "Manager signs quarterly inventory validation report").
  
- Do NOT include References subsections within individual policy sections; the References section should appear only at the very end of the document.

### Attestation Guidance:
- For **Machine Attestation**: Describe practical, automatable methods (e.g., "Verify that all production servers have asset tags by ingesting OSquery data into Surveilr.").
- For **Human Attestation**: Describe precise steps and artifacts (e.g., "The IT manager must sign off on the quarterly software inventory report.").

### Operational Detail and Specificity:
- Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions.
- Include a bulleted list of 3-5 operational steps for processes like containment, correction, or violation sanction with specific time-bound metrics (KPIs/SLA).

### Comprehensive Scope Definition:
- Explicitly define the policy's scope to include all relevant entities and environments, including cloud-hosted systems, SaaS applications, and third-party vendor systems.

### Roles and Responsibilities:
- Define specific, task-level duties (action verbs and frequency) for each role mentioned, linking to related organizational plans.

### Policy Lifecycle Requirements:
- Include minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

### Formal Documentation and Audit:
- Require workforce member acknowledgement/attestation of understanding and compliance, audit logging for critical actions, and documentation for exceptions.

### Verification Criteria:
- Provide clear measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined in the policy.

### Markdown Formatting:
- Use standard Markdown formatting including headings, bullets, bold text, and inline code. Ensure that the enforced keywords are **BOLD**: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, **Annual Review**.

### Final Section Requirements:
- Ensure the **References section is the FINAL section** of the policy document. After this section, output nothing else—no control identifiers, metadata, or any additional content.

### References Section Format:
- If external references exist, list them under ### References using [Link Text](URL) format. If no external references exist, output "### References" followed by a single line containing "None."

Ensure the policy maximizes machine attestability and includes attestation guidance for every requirement.