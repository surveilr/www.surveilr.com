---
title: "HIPAA 164.308(a)(3)(ii)(C) - Author Prompt"
weight: 1
description: "Authoring prompt for HIPAA control 164.308(a)(3)(ii)(C)"
publishDate: "2025-09-23"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(3)(ii)(C)"
control-question: "Have you implemented procedures for terminating access to EPHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section? (A)"
fiiId: "FII-SCF-IAC-0007.2"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for the following control:

- **Control Code**: 164.308(a)(3)(ii)(C)  
- **Control Question**: Have you implemented procedures for terminating access to EPHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section? (A)  
- **Internal ID**: FII-SCF-IAC-0007.2  

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
- **References** (with `### _References_`)  

### Attestation Guidance
- Machine Attestation: e.g., “Verify that access to EPHI is removed for all terminated employees by integrating with identity management systems and ingesting logs into Surveilr.”  
- Human Attestation: e.g., “HR must complete and sign the access termination checklist for departing employees, then upload to Surveilr with metadata.”  

### Markdown and Formatting Rules
- Use standard Markdown (headings, bullets, bold, inline code).  
- Use `[Link Text](URL)` for citations.  
- Do not include SQL queries.