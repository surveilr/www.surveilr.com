---
title: "Author Prompt: Access Control List Compliance Policy"
weight: 1
description: "Implement Access Control Lists to restrict unauthorized network traffic and ensure compliance with CMMC standards for safeguarding sensitive information."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.3"
control-question: "Does the organization implement and govern Access Control Lists (ACLs) to provide data flow enforcement that explicitly restrict network traffic to only what is authorized?"
fiiId: "FII-SCF-NET-0004"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L2-3.1.3 (FII: FII-SCF-NET-0004). 

The policy must follow this structure: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References.** Each section should include detailed explanations of the control requirements, specific machine attestation methods, and explicit human attestation methods where necessary. 

**Important Instructions:**

1. **Document Structure:** Use H2 headings (##) for each major section. Do not include References subsections within policy sections; the References section should appear only at the very end of the document.

2. **Attestation Guidance:** 
   - For **Machine Attestation**, describe practical, automatable evidence collection methods. For example, "Use OSquery to collect network traffic data daily."
   - For **Human Attestation**, specify the actions, artifacts, and how they are ingested into Surveilr, such as "The network administrator must sign off on the quarterly ACL review report, which is then uploaded to Surveilr."

3. **Operational Detail and Specificity:** Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes like violation sanctions, along with a specific time-bound metric (e.g., "contain within 48 hours").

4. **Scope Definition:** Explicitly define the policy's scope, including cloud-hosted systems, SaaS applications, and all channels used to create, receive, maintain, or transmit data.

5. **Responsibilities:** Define specific, task-level duties for each role (e.g., "Network Security Officer: quarterly ACL review") and link to related organizational plans.

6. **Policy Lifecycle Requirements:** Include a section detailing minimum data retention periods for evidence and mandatory frequency for policy review and update.

7. **Formal Documentation and Audit:** Require workforce member acknowledgment of understanding and compliance, comprehensive audit logging, and formal documentation for exceptions.

8. **Verification Criteria:** Provide measurable criteria for compliance validation, tied to defined KPIs/SLAs.

9. **Markdown Formatting:** Use standard Markdown formatting throughout the document.

10. **Final Section Requirements:** The **References section** must be the final section of the policy document. If external references exist, list them in the format [Link Text](URL). If no external references exist, state "None."

Ensure that the generated policy maximizes machine attestability, and every section must include attestation guidance. Failure to include attestation methods for any requirement will result in non-compliance. 

**All keywords must be bolded:** **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**. 

End the document with exactly ONE References section.