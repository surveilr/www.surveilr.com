---
title: "Author Prompt: Remote Maintenance and Diagnostic Security Policy"
weight: 1
description: "Establishes secure and compliant controls for authorizing, monitoring, and documenting remote maintenance and diagnostic activities involving electronic Protected Health Information (ePHI)."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "MA.L2-3.7.5"
control-question: "Does the organization authorize, monitor and control remote, non-local maintenance and diagnostic activities?"
fiiId: "FII-SCF-MNT-0005"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Maintenance"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: "MA.L2-3.7.5" (FII: FII-SCF-MNT-0005). 

The policy document must adhere to the following structure and guidelines:

1. **Document Structure**: The policy **MUST** follow this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.**

2. **CRITICAL FAILURE POINT**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a **bulleted list of 3-5 operational steps** for processes like containment, correction, or **violation sanction**, along with a **specific time-bound metric (KPI/SLA)** (e.g., contain within 48 hours, remediate within 5 business days).

3. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include ALL relevant entities and environments, covering **cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates)**, and **all channels** used to create, receive, maintain, or transmit ePHI.

4. **Prioritize Machine Attestation**: Each requirement **MUST** provide concrete examples of automated evidence collection/validation.

5. **Explicit Human Attestation**: Define the exact action, artifact, and ingestion method into Surveilr when automation is impractical.

6. **Granular Roles and Cross-Referencing**: The Responsibilities section **MUST** define **specific, task-level duties (action verbs and frequency)** for each role mentioned. **Explicitly link to or reference** related organizational plans (e.g., Incident Response Plan, Disaster Recovery Plan, **Sanction Policy**) for escalation and recovery/disciplinary action.

7. **Policy Lifecycle Requirements**: The policy **MUST** contain a subsection detailing **Minimum data retention periods** for evidence/logs and **Mandatory frequency for policy review and update**.

8. **Formal Documentation and Audit**: The policy **MUST** require **Workforce member acknowledgement/attestation** of understanding and compliance, **Comprehensive audit logging** for all critical actions, and formal documentation for all exceptions.

9. **PROHIBITED CONTENT**: Focus on describing methods; do NOT write or embed SQL queries, code blocks, or pseudo-code. 

10. **Evidence Collection Methods**: **MANDATORY STRUCTURE:** Must use numbered subheadings per requirement: "1. REQUIREMENT:", "2. MACHINE ATTESTATION:", "3. HUMAN ATTESTATION:".

11. **Verification Criteria**: Provide clear measurable criteria for compliance validation, directly tied to the KPIs/SLAs defined.

12. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, bold text, and inline code.

13. **Hyperlinks**: Use [Link Text](URL) format for external references.

14. **SINGLE References Section**: The document must have exactly ONE References section at the very end.

15. **Keyword Emphasis**: The policy text **MUST** explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

16. **Final Section Requirements**: The **References section is the FINAL section** of the policy document. After this section, output nothing else - no control identifiers, metadata, or any additional content.

17. **References Section Format**: List external references under ### References using [Link Text](URL) format, or output "None" if there are no external references.

Ensure that **References subsections do NOT appear after each policy section**, and conclude the policy document with exactly ONE References section.