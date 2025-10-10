---
title: "Author Prompt: Secure Remote Access Policy for ePHI Protection"
weight: 1
description: "Establishes secure remote access methods to protect ePHI, ensuring compliance through defined approval processes and regular audits."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.12"
control-question: "Does the organization define, control and review organization-approved, secure remote access methods?"
fiiId: "FII-SCF-NET-0014"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L2-3.1.12 (FII: FII-SCF-NET-0014). 

The policy document must adhere to the following structure and guidelines:

1. **Document Structure**: The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Ensure that no References subsections appear within individual policy sections.

2. **Policy Content**: Each policy section should:
   - Explain the control requirement clearly.
   - Suggest **machine attestability methods** such as automated evidence collection techniques (e.g., "Use OSquery to collect endpoint configuration").
   - Include **human attestability methods** where necessary, specifying exact actions, artifacts, and how they will be ingested into Surveilr.

3. **Operational Detail**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. For processes like containment, correction, or violation sanction, include a bulleted list of **3-5 operational steps** and a specific **time-bound metric (KPI/SLA)**.

4. **Scope Definition**: Clearly define the policy's scope to include all relevant entities and environments, covering **cloud-hosted systems, SaaS applications, third-party vendor systems**, and all channels used to create, receive, maintain, or transmit ePHI.

5. **Attestation Guidance**: For each requirement, provide concrete examples of automated evidence collection/validation and specify human attestation actions when automation is impractical.

6. **Responsibilities**: Define specific, task-level duties (using **Action Verb + Frequency**) for each role mentioned, linking to related organizational plans (e.g., Incident Response Plan).

7. **Lifecycle Requirements**: Include a subsection detailing **Data Retention** periods for evidence/logs (e.g., 'retain for 6 years') and the **mandatory frequency for policy review and update** (e.g., 'reviewed at least annually').

8. **Formal Documentation and Audit**: Require workforce member acknowledgement/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

9. **Evidence Collection Methods**: Structure this section using numbered subheadings: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

10. **Verification Criteria**: Provide clear, measurable criteria for compliance validation that are directly tied to the **KPIs/SLAs** defined.

11. **Markdown Formatting**: Use standard Markdown elements including headings, bullet points, and bold text for emphasis.

12. **Hyperlinks**: Use the [Link Text](URL) format for any external references.

13. **Single References Section**: Ensure the document ends with exactly ONE References section. If external references exist, list them under ### References. If none exist, state "### References" followed by "None".

14. **Keyword Emphasis**: The policy text must explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

15. **Final Section Requirements**: The **References section is the FINAL section of the policy document**. Ensure that no control identifiers, metadata, or any additional content appears after this section.

Your output must be a comprehensive policy document that follows these guidelines to ensure compliance and machine attestability through Surveilr.