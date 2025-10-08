---
title: "Author Prompt: Portable Storage Device Usage Security Policy"
weight: 1
description: "Restricts the use of portable storage devices to prevent unauthorized data transfer and protect sensitive organizational information."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.21"
control-question: "Does the organization restrict or prohibit the use of portable storage devices by users on external systems?"
fiiId: "FII-SCF-DCH-0013.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "AC.L2-3.1.21" (FII: "FII-SCF-DCH-0013.2"). 

## Policy Structure Requirements
1. **Document Structure**: Follow the exact order of sections: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** 
2. **Attestation Guidance**: For each section, provide:
   - An explanation of the control requirement.
   - **MACHINE ATTESTATION** methods that can be automated, e.g., "Use OSquery to collect asset inventories daily."
   - **HUMAN ATTESTATION** methods for scenarios where automation is impractical, e.g., "Manager signs quarterly inventory validation report."
   - Ensure every section includes attestation guidance to maximize machine attestability.

## Detailed Instructions
1. **SMART Instructions**: Use **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions for processes, including a bulleted list of 3-5 operational steps and a specific time-bound metric (KPI/SLA).
2. **Scope Definition**: Clearly define the policy's scope, including all relevant entities and environments such as cloud-hosted systems, SaaS applications, and third-party vendor systems.
3. **Granular Responsibilities**: Define specific tasks for each role mentioned (e.g., Compliance Officer: quarterly policy approval) and link to related organizational plans for escalation and recovery actions.
4. **Lifecycle Requirements**: Include minimum data retention periods for logs and mandatory review frequencies.
5. **Formal Documentation and Audit**: Require acknowledgment of understanding and compliance, comprehensive audit logging, and documentation for exceptions.
6. **Verification Criteria**: Establish clear and measurable criteria for compliance validation, tied to the defined KPIs/SLAs.

## Markdown Formatting
- Use standard Markdown formatting with headings, bullet points, bold text, and inline code.
- Avoid including any SQL queries or code blocks.
- Ensure that the **References section** is the final section of the document, with no References subsections in individual policy sections.

## Emphasis on Keywords
Ensure to explicitly use and **BOLD** the following keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

### Final Note
The document must conclude with **exactly ONE References section** and should not include control identifiers, metadata, or any additional content after this section. 

### Output
Create the policy document based on the above guidelines without including any conversational filler or explanations.