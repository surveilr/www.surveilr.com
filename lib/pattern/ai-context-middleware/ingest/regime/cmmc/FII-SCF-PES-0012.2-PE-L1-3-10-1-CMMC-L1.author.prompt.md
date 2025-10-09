---
title: "Author Prompt: Printer Access Control and Compliance Policy"
weight: 1
description: "Implement access controls to printers and output devices, ensuring only authorized personnel retrieve sensitive documents and maintain compliance with CMMC standards."
publishDate: "2025-10-06"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "PE.L1-3.10.1"
control-question: "Does the organization restrict access to printers and other system output devices to prevent unauthorized individuals from obtaining the output?"
fiiId: "FII-SCF-PES-0012.2"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 1", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: PE.L1-3.10.1 (FII: FII-SCF-PES-0012.2). 

Please follow these instructions to create a comprehensive policy document that maximizes machine attestability:

1. **Document Structure**: Use the following section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Ensure that each section includes clear explanations, specific machine attestation methods, and detailed human attestation methods where necessary.

2. **Markdown Formatting**: Utilize standard Markdown elements, including H2 headings (##), paragraphs, bullet points, bold text for emphasis, and inline code for technical terms. 

3. **Attestation Guidance**: 
   - For **Machine Attestation**: Provide practical, automatable methods for evidence collection. For example, "Use OSquery to collect access logs for printers."
   - For **Human Attestation**: Clearly describe the exact action, artifact, and how it is documented and ingested into Surveilr, such as "The facilities manager must sign the quarterly access control report, which is then uploaded to Surveilr with relevant metadata."

4. **Operational Detail and Specificity**: Replace general statements with **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions. Include a bulleted list of 3-5 operational steps for processes like containment, correction, or violation sanction. Each step must have a **specific time-bound metric (KPI/SLA)** associated with it.

5. **Comprehensive Scope Definition**: Explicitly define the policy's scope to include all relevant entities and environments, covering cloud-hosted systems, SaaS applications, and third-party vendor systems.

6. **Verification Criteria**: Clearly outline measurable criteria for compliance validation related to the **KPIs/SLAs** defined.

7. **Formal Documentation and Audit**: The policy must require workforce member acknowledgment of understanding and compliance, comprehensive audit logging for critical actions, and formal documentation for all exceptions.

8. **Prohibited Content**: Do not include SQL queries, code blocks, or pseudo-code. Ensure that no References subsections are included within individual policy sections, only at the end of the document.

9. **Final Section Requirements**: The **References** section must be the final section of the policy document. If external references exist, list them; if none exist, output "None." 

Ensure that the keywords **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review** are **BOLD** throughout the document as required. 

Now, proceed to create the policy document according to these guidelines, ensuring the document ends with exactly ONE References section.