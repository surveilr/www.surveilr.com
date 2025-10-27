---
title: "Author Prompt: Authenticator Protection and Security Policy"
weight: 1
description: "Protects authenticators to ensure compliance with CMMC control IA.L2-3.5.10 and safeguards sensitive information across various environments."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "IA.L2-3.5.10"
control-question: "Does the organization protect authenticators commensurate with the sensitivity of the information to which use of the authenticator permits access?"
fiiId: "FII-SCF-IAC-0010.5"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "IA.L2-3.5.10" (FII: "FII-SCF-IAC-0010.5"). 

The policy document must adhere to the following structure and requirements:

1. **Document Structure**: Include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Ensure that there are **NO** References subsections within individual policy sections.

2. **Policy Content**: Each section should:
   - Explain the control requirement clearly.
   - Provide **MACHINE ATTESTATION** methods that are practical and automatable.
   - Include **HUMAN ATTESTATION** methods where necessary, detailing specific actions, artifacts, and how these will be ingested into Surveilr.

3. **Operational Detail**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes like containment and correction, along with a specific time-bound metric (KPI/SLA).

4. **Scope Definition**: Clearly define the policy's scope to encompass all relevant entities and environments, including **cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates)**, and all channels used to create, receive, maintain, or transmit ePHI.

5. **Attestation Guidance**: 
   - For **MACHINE ATTESTATION**, describe automated evidence collection/validation methods.
   - For **HUMAN ATTESTATION**, specify actions, artifacts, and ingestion methods into Surveilr.

6. **Responsibilities**: Clearly define specific duties for each role mentioned, using **Action Verb + Frequency** language. Link to related organizational plans for escalation and recovery actions.

7. **Policy Lifecycle Requirements**: Include a dedicated subsection for **Data Retention** periods for evidence/logs (e.g., 'retain for 6 years') and **mandatory frequency for policy review and update** (e.g., 'reviewed at least annually').

8. **Formal Documentation and Audit**: Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for critical actions, and formal documentation for all exceptions.

9. **Evidence Collection Methods**: Use the structure "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:" for each requirement.

10. **Verification Criteria**: Provide clear, measurable criteria for compliance validation directly tied to the KPIs/SLAs defined in the operational detail.

11. **Markdown Formatting**: Use standard Markdown elements including headings, bullet points, bold text for emphasis, and inline code for technical terms. Ensure all enforced keywords like **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review** are **BOLD**.

12. **Final Section Requirements**: The **References** section must be the final section of the policy document, containing only the references used in the document. If no external references exist, state "None".

Remember to end the policy document with exactly ONE References section and ensure that no control identifiers, metadata, or additional content is included after this section.