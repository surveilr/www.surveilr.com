---
title: "Author Prompt: Continuous Anti-Malware Operational Integrity Policy"
weight: 1
description: "Establishes continuous operational integrity of anti-malware technologies to protect organizational systems from unauthorized alterations and malware threats."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "SI.L1-3.14.5"
control-question: "Does the organization ensure that anti-malware technologies are continuously running in real-time and cannot be disabled or altered by non-privileged users, unless specifically authorized by management on a case-by-case basis for a limited time period?"
fiiId: "FII-SCF-END-0004.7"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Endpoint Security"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: SI.L1-3.14.5 (FII: FII-SCF-END-0004.7). 

The policy MUST have the following structure: 

1. **Introduction**
2. **Policy Statement**
3. **Scope**
4. **Responsibilities**
5. **Evidence Collection Methods**
6. **Verification Criteria**
7. **Exceptions**
8. **Lifecycle Requirements**
9. **Formal Documentation and Audit**
10. **References** (This section should be the only one at the end of the document, and you must NOT include References subsections after each policy section.)

Each section must follow these guidelines:

- **Introduction**: Briefly outline the purpose of the policy in relation to anti-malware technologies.
  
- **Policy Statement**: Clearly state the organization's commitment to ensuring that anti-malware technologies are continuously running in real-time and cannot be disabled or altered by non-privileged users without authorization.

- **Scope**: Define the scope to include all relevant entities and environments, such as cloud-hosted systems, SaaS applications, and third-party vendor systems.

- **Responsibilities**: Specify task-level duties with **Action Verb + Frequency** for each role involved in the policy enforcement.

- **Evidence Collection Methods**: 
  - **1. REQUIREMENT**: Describe the requirement for continuous anti-malware operation.
  - **2. MACHINE ATTESTATION**: Suggest specific, automatable methods for collecting evidence (e.g., "Use OSquery to verify that anti-malware services are active on all endpoints daily.").
  - **3. HUMAN ATTESTATION**: Outline precise steps for human verification (e.g., "IT manager must sign a report confirming that all non-privileged users have restricted access to anti-malware settings monthly.").

- **Verification Criteria**: Provide clear, measurable criteria tied to defined **KPIs/SLAs** for compliance validation.

- **Exceptions**: Define the process for documenting exceptions, including justification and approval requirements.

- **Lifecycle Requirements**: Include sections on **Data Retention** for logs and evidence, and mandate an **Annual Review** of the policy.

- **Formal Documentation and Audit**: Require workforce member acknowledgment of understanding and compliance, and ensure comprehensive audit logging of critical actions.

The policy must maximize machine attestability and provide detailed attestation guidance in each section. Be sure to include the **SMART** framework in operational details and clearly emphasize all mandated keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

Finally, ensure that the document ends with a single **References** section that contains appropriate citations using the format [Link Text](URL) or states "None" if there are no external references. Do NOT include any References subsections within individual policy sections.