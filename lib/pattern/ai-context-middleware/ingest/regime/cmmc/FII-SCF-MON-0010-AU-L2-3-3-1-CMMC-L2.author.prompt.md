---
title: "Author Prompt: Event Log Retention Compliance Policy"
weight: 1
description: "Establishes requirements for the retention of event logs to support investigations and ensure compliance with statutory and regulatory obligations."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AU.L2-3.3.1"
control-question: "Does the organization retain event logs for a time period consistent with records retention requirements to provide support for after-the-fact investigations of security incidents and to meet statutory, regulatory and contractual retention requirements?"
fiiId: "FII-SCF-MON-0010"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Continuous Monitoring"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AU.L2-3.3.1 (FII: FII-SCF-MON-0010). 

The policy must adhere to the following structure and requirements:

1. **Document Structure**: The policy MUST include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit,** and **References**. Do NOT include References subsections within policy sections; they should only appear in the final section.

2. **Markdown Elements**: Use H2 headings (##) for major requirements, standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. 

3. **Attestation Guidance**: Each section must include machine attestation methods and human attestation methods where necessary. For machine attestation, describe practical, automatable methods. For human attestation, detail precise steps and artifacts, including how they will be documented and ingested into Surveilr.

4. **SMART Instructions**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes like containment, correction, or violation sanction, along with specific time-bound metrics (KPIs/SLA).

5. **Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments such as cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates), and all channels used to create, receive, maintain, or transmit ePHI.

6. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection/validation.

7. **Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr where human attestation is required.

8. **Granular Roles and Responsibilities**: The Responsibilities section MUST define specific, task-level duties (action verbs and frequency) for each role mentioned and link to related organizational plans for escalation and recovery/disciplinary action.

9. **Lifecycle Requirements**: Include a dedicated subsection detailing minimum data retention periods for evidence/logs and mandatory frequency for policy review and update.

10. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

11. **Evidence Collection Methods**: Structure this section with numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

12. **Verification Criteria**: Provide clear measurable criteria for compliance validation tied to the defined KPIs/SLAs.

13. **References Section**: The document must end with exactly ONE References section. If external references exist, list them using [Link Text](URL) format; if none exist, state "None".

14. **Keyword Emphasis**: The policy text MUST explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

Ensure that all sections and requirements are addressed comprehensively, and follow the outlined guidelines strictly to achieve a 100% compliance score.