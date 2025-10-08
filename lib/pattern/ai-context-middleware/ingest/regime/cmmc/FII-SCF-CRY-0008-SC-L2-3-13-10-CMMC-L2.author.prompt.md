---
title: "Author Prompt: Secure Public Key Infrastructure Policy"
weight: 1
description: "Establishes secure PKI infrastructure or services to protect sensitive data and ensure compliance with cybersecurity standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "SC.L2-3.13.10"
control-question: "Does the organization securely implement an internal Public Key Infrastructure (PKI) infrastructure or obtain PKI services from a reputable PKI service provider?"
fiiId: "FII-SCF-CRY-0008"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Cryptographic Protections"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: SC.L2-3.13.10 (FII: FII-SCF-CRY-0008). 

Please create the following sections in the policy document, ensuring that each section adheres to the specified requirements:

1. **Introduction**: Provide an overview of the control and its importance in maintaining secure PKI infrastructure.
2. **Policy Statement**: Clearly state the organization's commitment to securely implementing PKI infrastructure or obtaining PKI services from a reputable provider.
3. **Scope**: Define the scope of the policy to include all relevant entities and environments, including cloud-hosted systems, SaaS applications, and third-party vendor systems.
4. **Responsibilities**: Specify clear, task-level duties for each role involved, using **Action Verb + Frequency** format (e.g., "Compliance Officer: quarterly policy approval").
5. **Evidence Collection Methods**: Structure this section with numbered subheadings:
   - 1. **REQUIREMENT**: Explain the control requirement in detail.
   - 2. **MACHINE ATTESTATION**: Suggest practical, automatable methods for collecting and validating evidence (e.g., "Use OSquery to collect PKI configuration details daily").
   - 3. **HUMAN ATTESTATION**: Define the exact actions, artifacts, and ingestion methods into Surveilr when automation is impractical (e.g., "The IT manager must sign off on the PKI review report, which is then uploaded to Surveilr with metadata").
6. **Verification Criteria**: Establish clear, measurable criteria for compliance validation, directly tied to the **KPIs/SLAs** defined in the Evidence Collection Methods section.
7. **Exceptions**: Outline any exceptions to the policy, including required documentation for justifications and approval processes.
8. **Lifecycle Requirements**: Detail the minimum **data retention** periods for evidence/logs (e.g., "retain for 6 years") and mandatory frequency for policy review (e.g., "reviewed at least annually").
9. **Formal Documentation and Audit**: Require workforce member acknowledgment of understanding and compliance, comprehensive audit logging, and formal documentation for all exceptions.
10. **References**: Include a single, final References section at the end of the document, formatted as [Link Text](URL). Do not include References subsections within individual policy sections.

Ensure that the policy maximizes machine attestability, includes **SMART** instructions, and follows the specified structure and formatting guidelines. BOLD the keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review** throughout the document. Remember, do NOT include any SQL queries, code blocks, or pseudo-code, and ensure that there is no additional content or metadata after the References section.