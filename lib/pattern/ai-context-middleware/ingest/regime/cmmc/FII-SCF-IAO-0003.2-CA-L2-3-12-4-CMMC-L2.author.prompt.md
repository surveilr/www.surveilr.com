---
title: "Author Prompt: Sensitive Data Protection Compliance Policy"
weight: 1
description: "Establishes comprehensive measures for protecting sensitive data through machine and human attestations across all organizational systems and environments."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "CA.L2-3.12.4"
control-question: "Does the organization protect sensitive / regulated data that is collected, developed, received, transmitted, used or stored in support of the performance of a contract?"
fiiId: "FII-SCF-IAO-0003.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Information Assurance"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "CA.L2-3.12.4" (FII: FII-SCF-IAO-0003.2). 

Please follow these guidelines for crafting the policy document:

1. **Document Structure**: The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. 

2. **Policy Sections**: Each section should:
   - Explain the control requirement.
   - Suggest machine attestation methods (e.g., "Use OSquery to collect asset inventories daily").
   - Suggest human attestation methods where necessary (e.g., "Manager signs quarterly inventory validation report").
   - Note: Do NOT include References subsections within these policy sections. The References section should appear only at the end of the document.

3. **Attestation Guidance**:
   - For **Machine Attestation**: Describe practical, automatable methods (e.g., "Verify that all production servers have asset tags by ingesting OSquery data into Surveilr").
   - For **Human Attestation**: Describe precise actions, artifacts, and ingestion methods into Surveilr (e.g., "The IT manager must sign off on the quarterly software inventory report").

4. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes such as containment, correction, or violation sanction, and a **specific time-bound metric (KPI/SLA)** for each.

5. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include all relevant entities and environments, such as cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to handle sensitive data.

6. **Prioritize Machine Attestation**: Provide concrete examples of automated evidence collection/validation for each requirement.

7. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr.

8. **Granular Roles and Cross-Referencing**: Define specific, task-level duties for each role mentioned in the Responsibilities section, including action verbs and frequency. Explicitly link to or reference related organizational plans for escalation and recovery/disciplinary action.

9. **Policy Lifecycle Requirements**: Include a subsection detailing minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

10. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

11. **Evidence Collection Methods**: Use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

12. **Verification Criteria**: Must include clear, measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

13. **Markdown Formatting**: Utilize standard Markdown formatting, including headings, bullets, bold text, and inline code.

14. **Hyperlinks**: Use [Link Text](URL) format for external references.

15. Ensure that the policy text explicitly uses and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

16. The **References section** must be the final section of the policy document, with no additional content following it.

17. The **References section format** must list any external references or state "None" if there are none.

Adhere strictly to these guidelines to ensure compliance and maximize machine attestability.