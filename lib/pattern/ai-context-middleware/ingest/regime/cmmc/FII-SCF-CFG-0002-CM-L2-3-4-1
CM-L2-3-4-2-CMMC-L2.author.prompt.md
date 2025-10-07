---
title: "Author Prompt: Secure Baseline Configuration Management Policy"
weight: 1
description: "Establishes secure baseline configurations for technology platforms to enhance security and ensure compliance with CMMC controls."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "CM.L2-3.4.1
CM.L2-3.4.2"
control-question: "Does the organization develop, document and maintain secure baseline configurations for technology platforms that are consistent with industry-accepted system hardening standards?"
fiiId: "FII-SCF-CFG-0002"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "CM.L2-3.4.1, CM.L2-3.4.2" (FII: FII-SCF-CFG-0002). 

Please follow these instructions to ensure the policy is robust, clear, and machine-attestable:

1. **Document Structure**: Ensure the policy follows this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** Do NOT include References subsections within policy sections.

2. **Markdown Elements**: Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. 

3. **Attestation Guidance**:
   - **Machine Attestation**: Describe practical, automatable methods of evidence collection and verification, such as using OSquery or API integrations.
   - **Human Attestation**: Define precise steps and artifacts a human must perform, including documentation methods for attestation artifacts stored in Surveilr.

4. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions, particularly in sections that detail processes like containment, correction, or violation sanction. Include a **bulleted list of 3-5 operational steps** and specific time-bound metrics (KPI/SLA).

5. **Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, including cloud-hosted systems, SaaS applications, and third-party vendor systems.

6. **Prioritize Machine Attestation**: For each requirement, provide concrete examples of automated evidence collection or validation.

7. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr when automation is impractical.

8. **Granular Roles and Cross-Referencing**: In the Responsibilities section, define specific, task-level duties (action verbs and frequency) for each role mentioned, and explicitly link to related organizational plans.

9. **Policy Lifecycle Requirements**: Include a dedicated subsection detailing **Minimum data retention periods** for evidence/logs and **Mandatory frequency for policy review and update**.

10. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance and comprehensive audit logging for all critical actions.

11. **Evidence Collection Methods**: Use numbered subheadings for evidence collection: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

12. **Verification Criteria**: Establish clear, measurable criteria for compliance validation, tied to the KPIs/SLAs defined in the operational steps.

13. **Hyperlinks**: Use [Link Text](URL) format for external references.

14. **Keyword Emphasis**: Explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

15. **Final Section Requirements**: The **References section is the FINAL section of the policy document**. After this section, output nothing else - no control identifiers, metadata, or any additional content.

16. **References Section Format**: List external references under ### References using [Link Text](URL) format, or output "### References" followed by "None" if no external references exist.

Ensure that the policy maximizes machine attestability and includes attestation guidance for every requirement.