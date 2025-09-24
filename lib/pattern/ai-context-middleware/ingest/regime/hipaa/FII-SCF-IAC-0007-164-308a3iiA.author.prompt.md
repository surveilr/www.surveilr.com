---
title: "Employee Authorization Author Prompt"
weight: 1
description: "Employee Authorization Procedures This control ensures that procedures are in place for the authorization and supervision of employees who access or handle Electronic Protected Health Information (EPHI). It outlines the necessary steps to verify employee access rights and provides guidelines for monitoring their interactions with EPHI to maintain data security and compliance with HIPAA regulations."
publishDate: "2025-09-24"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(3)(ii)(A)"
control-question: "Have you implemented procedures for the authorization and/or supervision of employees who work with EPHI or in locations where it might be accessed? (A)"
fiiId: "FII-SCF-IAC-0007, FII-SCF-IAC-0007.1"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable HIPAA compliance policies. Your task is to write a policy for the following control:

**Control Code**: 164.308(a)(3)(ii)(A)  
**Control Question**: Have you implemented procedures for the authorization and/or supervision of employees who work with EPHI or in locations where it might be accessed? (A)  
**Internal ID**: FII-SCF-IAC-0007, FII-SCF-IAC-0007.1  

**Surveilr’s Core Function**: Automates collection, storage, and querying of compliance evidence.  
**Machine Attestation**: Evidence that can be automatically validated. Examples:  
- Endpoint configuration via `OSquery`  
- API integrations with SaaS/cloud providers  
- Log/config ingestion  
- Automated scripts  
**Human Attestation**: Only when automation is impossible. Must be specific and verifiable. Examples:  
- Manager certifies asset inventory review quarterly  
- Signed HR training logs  
- Physical inspection reports  

Surveilr stores attestation artifacts (PDFs, forms, emails) and makes metadata (reviewer, date, outcome) queryable.  

**Required Policy Document Structure**:  
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

**Attestation Guidance**:  
- **Machine Attestation**: e.g., “Verify employee access controls are configured properly by ingesting OSquery data into Surveilr.”  
- **Human Attestation**: e.g., “HR Manager must sign the employee access authorization logs quarterly, then upload to Surveilr with metadata.”