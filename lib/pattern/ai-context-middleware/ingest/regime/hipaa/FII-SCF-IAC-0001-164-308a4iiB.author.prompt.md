---
title: "Author Prompt: EPHI Access Control Policy"
weight: 1
description: "Establishes procedures for granting and monitoring access to electronic protected health information in compliance with HIPAA."
publishDate: "2025-09-24"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(4)(ii)(B)"
control-question: "Have you implemented policies and procedures for granting access to EPHI, for example, through access to a workstation, transaction, program, or process? (A)"
fiiId: "FII-SCF-IAC-0001"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable HIPAA compliance policies. Your task is to write a policy for the following control:

- **Control Code**: 164.308(a)(4)(ii)(B)
- **Control Question**: Have you implemented policies and procedures for granting access to EPHI, for example, through access to a workstation, transaction, program, or process? (A)
- **Internal ID**: FII-SCF-IAC-0001

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
- Machine Attestation: e.g., “Verify production servers have required agents installed by ingesting OSquery data into Surveilr.”  
- Human Attestation: e.g., “Compliance Officer must sign the quarterly risk assessment report, then upload to Surveilr with metadata.”