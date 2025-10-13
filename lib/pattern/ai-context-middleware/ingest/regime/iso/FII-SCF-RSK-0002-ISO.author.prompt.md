---
title: "Author Prompt: Information Classification and Management Policy"
weight: 1
description: "Establishes a systematic framework for categorizing and protecting sensitive information to ensure compliance with legal and regulatory requirements."
publishDate: "2025-10-11"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "FII-SCF-RSK-0002"
control-question: "Does the organization categorize systems and data in accordance with applicable laws, regulations and contractual obligations that:
 (1) Document the security categorization results (including supporting rationale) in the security plan for systems; and
 (2) Ensure the security categorization decision is reviewed and approved by the asset owner?"
fiiId: "FII-SCF-RSK-0002"
regimeType: "ISO"
category: ["ISO", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control : (FII: FII-SCF-RSK-0002).

## Policy Structure
1. **Introduction**: Provide an overview of the policy, stating its purpose and importance in relation to categorizing systems and data in accordance with applicable laws, regulations, and contractual obligations.

2. **Policy Statement**: Clearly state the organization's commitment to categorizing systems and data, ensuring compliance with relevant legal and regulatory requirements.

3. **Scope**: Define the scope of the policy, explicitly including all relevant entities and environments, such as cloud-hosted systems, SaaS applications, third-party vendor systems (Business Associates), and all channels used to create, receive, maintain, or transmit sensitive information.

4. **Responsibilities**: Outline specific, task-level duties for each role involved in the categorization process. Use **Action Verb + Frequency** for clarity (e.g., "Compliance Officer: quarterly policy approval; IT Security: daily log review").

5. **Evidence Collection Methods**: 
   - **1. REQUIREMENT**: Document the security categorization results, including supporting rationale.
   - **2. MACHINE ATTESTATION**: Use API integrations with system classification tools to automatically validate categorized assets and ensure compliance.
   - **3. HUMAN ATTESTATION**: Require the asset owner to sign the classification documentation, which is then uploaded to Surveilr with metadata (review date, reviewer name).

6. **Verification Criteria**: Establish clear, measurable criteria for compliance validation, directly tied to the **KPIs/SLAs** defined in the responsibilities section.

7. **Exceptions**: Define the process and criteria for any exceptions to the policy, including required documentation and approvals.

8. **Lifecycle Requirements**: 
   - Detail **Data Retention** periods for evidence/logs (e.g., 'retain for 6 years').
   - Specify the **Annual Review** frequency for policy updates.

9. **Formal Documentation and Audit**: 
   - Require workforce member acknowledgment/attestation of understanding and compliance.
   - Ensure comprehensive audit logging for all critical actions (creation, modification, termination).
   - Mandate formal documentation for all exceptions (justification, duration, approval).

10. **References**: At the end of the document, include a single References section formatted as follows: 
   - If external references exist, list them under ### References using [Link Text](URL) format.
   - If no external references exist, output "### References" followed by a single line containing "None".

**IMPORTANT**: Ensure that no References subsections appear after each policy section. The policy document must end with exactly ONE References section as specified.