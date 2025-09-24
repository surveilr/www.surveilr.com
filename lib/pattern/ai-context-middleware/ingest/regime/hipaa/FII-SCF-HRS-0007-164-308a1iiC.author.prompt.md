---
title: "Employee Sanction Policy Author Prompt"
weight: 1
description: "Employee Sanction Policy This control requires organizations to implement formal sanctions for employees who do not adhere to established security policies and procedures. By enforcing consequences for non compliance, the organization aims to promote a culture of accountability and ensure adherence to HIPAA regulations, thereby protecting sensitive health information and maintaining overall security integrity."
publishDate: "2025-09-24"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(1)(ii)(C)"
control-question: "Do you have formal sanctions against employees who fail to comply with security policies and procedures? (R)"
fiiId: "FII-SCF-HRS-0007"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable HIPAA compliance policies. Your task is to write a policy for the following control:

### Control Code
164.308(a)(1)(ii)(C)

### Control Question
Do you have formal sanctions against employees who fail to comply with security policies and procedures? (R)

### Internal ID
FII-SCF-HRS-0007

### Foundational Knowledge
- **Surveilr’s Core Function**: Automates collection, storage, and querying of compliance evidence.
- **Machine Attestation**: Evidence that can be automatically validated. Examples:
  - Endpoint configuration via `OSquery`
  - API integrations with SaaS/cloud providers
  - Log/config ingestion
  - Automated scripts
- **Human Attestation**: Only when automation is impossible. Must be specific and verifiable. Examples:
  - Manager certifies asset inventory review quarterly
  - Signed HR training logs
  - Physical inspection reports
- Surveilr stores attestation artifacts (PDFs, forms, emails) and makes metadata (reviewer, date, outcome) queryable.

### Required Policy Document Structure
- **Introduction** – concise purpose
- **Policy Statement** – high-level declaration
- **Scope** – what/who it applies to
- **Responsibilities** – clear roles/duties
- **Evidence Collection Methods** – with subheadings per requirement:
  - Explanation
  - Machine Attestation
  - Human Attestation (if unavoidable)
- **Verification Criteria**
- **Exceptions**
- **References**  
  ### _References_

### Attestation Guidance
- Machine Attestation: e.g., “Verify that all employees have acknowledged and reviewed security policies by ingesting compliance records into Surveilr.”
- Human Attestation: e.g., “HR must maintain signed documentation of employee sanctions for non-compliance and upload to Surveilr with metadata.”