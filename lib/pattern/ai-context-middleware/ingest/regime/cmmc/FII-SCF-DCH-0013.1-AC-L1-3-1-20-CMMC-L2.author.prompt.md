---
title: "Author Prompt: **External Data Handling Security Policy**"
weight: 1
description: "Establishes guidelines to prevent external handling of sensitive data without verified security controls or formal processing agreements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L1-3.1.20"
control-question: "Does the organization prohibit external parties, systems and services from storing, processing and transmitting data unless authorized individuals first: 
 ▪ Verifying the implementation of required security controls; or
 ▪ Retaining a processing agreement with the entity hosting the external systems or service?"
fiiId: "FII-SCF-DCH-0013.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L1-3.1.20 (FII: FII-SCF-DCH-0013.1). 

The policy must include the following sections in this exact order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Each section must be structured using H2 headings (##) and formatted with standard Markdown elements, including paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. 

1. **Introduction**: Provide a clear overview of the policy's purpose.
2. **Policy Statement**: Define the policy regarding the prohibition of external parties, systems, and services from storing, processing, and transmitting data unless authorized individuals verify security controls or retain processing agreements.
3. **Scope**: Explicitly define the scope to include all relevant entities, environments, cloud-hosted systems, SaaS applications, and third-party vendors involved in the handling of data.
4. **Responsibilities**: Clearly outline specific task-level duties for each role mentioned, using action verbs and frequency, and link to related organizational plans for escalation and recovery.
5. **Evidence Collection Methods**: Use numbered subheadings for each requirement, detailing:
   - **1. REQUIREMENT:** Explain the control requirement.
   - **2. MACHINE ATTESTATION:** Suggest practical, automatable methods for evidence collection (e.g., "Use OSquery to collect asset inventories daily").
   - **3. HUMAN ATTESTATION:** Describe specific actions, artifacts, and ingestion methods into Surveilr for human attestation.
6. **Verification Criteria**: Provide clear, measurable criteria for compliance validation that are directly tied to defined **KPIs/SLAs**.
7. **Exceptions**: State any exceptions to the policy, along with their documentation requirements.
8. **Lifecycle Requirements**: Detail minimum data retention periods for evidence/logs and the mandatory frequency for policy review and update (e.g., 'reviewed at least annually').
9. **Formal Documentation and Audit**: Require workforce member acknowledgment of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for exceptions.

Ensure that the policy maximizes machine attestability by providing concrete examples for automated evidence collection and validation. Include explicit human attestation methods when necessary, defining the exact action, artifact, and method for ingestion into Surveilr. 

Remember to emphasize **SMART** instructions, outline specific operational steps for processes like containment or violation sanctions, and include time-bound metrics. Use bold text for keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**. 

Do NOT include References subsections within individual policy sections; all references should be consolidated in a single **References** section at the end of the document. 

End with exactly ONE **References** section.