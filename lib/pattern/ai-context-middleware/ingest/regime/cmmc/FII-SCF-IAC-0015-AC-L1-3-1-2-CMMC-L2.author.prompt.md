---
title: "Author Prompt: Account Management and Access Control Policy"
weight: 1
description: "Establishes structured account management practices to protect ePHI and ensure compliance with regulatory standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L1-3.1.2"
control-question: "Does the organization proactively govern account management of individual, group, system, service, application, guest and temporary accounts?"
fiiId: "FII-SCF-IAC-0015"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L1-3.1.2 (FII: FII-SCF-IAC-0015). 

### Policy Structure
1. Begin with an **Introduction** that outlines the purpose and importance of proactive governance in account management.
2. Provide a **Policy Statement** that establishes the organization’s commitment to managing individual, group, system, service, application, guest, and temporary accounts effectively.
3. Define the **Scope** to include all relevant entities and environments, such as cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates), and all channels used to create, receive, maintain, or transmit ePHI.
4. Detail the **Responsibilities** section with specific, task-level duties for each role (e.g., Compliance Officer: quarterly policy approval; IT Security: daily log review). Use **Action Verbs + Frequency** to clarify responsibilities and explicitly link to related organizational plans (e.g., Incident Response Plan).
5. Outline **Evidence Collection Methods** with the following structure:
   - **1. REQUIREMENT:** Describe the control requirement.
   - **2. MACHINE ATTESTATION:** Suggest practical, automatable methods (e.g., "Use OSquery to collect account activity logs daily").
   - **3. HUMAN ATTESTATION:** Describe precise actions, artifacts, and ingestion methods into Surveilr (e.g., "The IT manager must sign off on the quarterly account review report").
6. Specify **Verification Criteria** that include clear measurable criteria for compliance validation, directly tied to **SMART** KPIs/SLAs defined in the Evidence Collection Methods.
7. Include **Exceptions** that outline any permissible deviations from the policy.
8. Define **Lifecycle Requirements** detailing minimum data retention periods for evidence/logs (e.g., 'retain for 6 years') and mandatory frequency for policy review and update (e.g., 'reviewed at least annually').
9. Describe **Formal Documentation and Audit** requirements, including workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.
10. End the document with a **References** section that contains exactly ONE entry, using the format [Link Text](URL) for any external references.

### Important Instructions
- Ensure that **References subsections** do NOT appear after each policy section; they should be compiled only at the document end.
- Emphasize the need for **machine attestability** in each section, providing concrete examples of automated evidence collection/validation.
- Include **specific, measurable, actionable, relevant, and time-bound (SMART)** instructions in all processes, especially for containment, correction, or violation sanction.
- Highlight the importance of **KPIs/SLAs, Data Retention**, and **Annual Review** in the policy text by using **bold text** for these keywords.

### Format
- Use standard Markdown formatting for all sections, including headings, bullets, bold text, and inline code.
- Ensure the policy document concludes with the **References** section, and do not output anything else after this section.

Your goal is to create a robust, clear policy document that achieves a 100% compliance score by addressing every rule in the 'Requirements for the Policy Document' section.