---
title: "Author Prompt: Access Logging Policy for ePHI Security"
weight: 1
description: "Establishes guidelines for logging all access attempts to ensure the security of ePHI and compliance with CMMC requirements."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "PE.L1-3.10.4"
control-question: "Does the organization generate a log entry for each access attempt through controlled ingress and egress points?"
fiiId: "FII-SCF-PES-0003.3"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: PE.L1-3.10.4 (FII: FII-SCF-PES-0003.3). 

The policy must follow this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** 

Each policy section should:
- Explain the control requirement clearly.
- Suggest machine attestation methods (e.g., "Use OSquery to collect asset inventories daily").
- Suggest human attestation methods where automation is impractical (e.g., "Manager signs quarterly inventory validation report").
- Include **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions for processes like containment, correction, or violation sanction, including a **bulleted list of 3-5 operational steps** and a **specific time-bound metric (KPI/SLA)**.
- Explicitly define the scope to include **cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels** used to create, receive, maintain, or transmit ePHI.
- Prioritize machine attestation by providing concrete examples of automated evidence collection and validation for each requirement.
- Define the exact action, artifact, and ingestion method into Surveilr for human attestation where needed.
- Clearly define **specific, task-level duties (action verbs and frequency)** for each role in the Responsibilities section and link to related organizational plans.
- Contain a dedicated subsection detailing **Minimum data retention periods** for evidence/logs and the **mandatory frequency for policy review and update**.
- Require **Workforce member acknowledgement/attestation** of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.
- Use numbered subheadings for the Evidence Collection Methods: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".
- Provide clear, measurable **Verification Criteria** directly tied to the **KPIs/SLAs** defined.
- Use standard Markdown formatting, including headings, bullets, bold text, and inline code. 
- Ensure that the **References section is the FINAL section of the policy document** and that no References subsections appear after each policy section. 

The document must also **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**. 

### References 

None