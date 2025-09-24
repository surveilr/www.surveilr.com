---
title: "Employee Access Author Prompt"
weight: 1
description: "Employee Access Management This control ensures that procedures are in place to evaluate and verify the appropriateness of employee access to electronic protected health information (EPHI). Regular assessments help determine whether access levels align with job responsibilities, thereby minimizing the risk of unauthorized access and ensuring compliance with HIPAA regulations."
publishDate: "2025-09-24"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(3)(ii)(B)"
control-question: "Have you implemented procedures to determine the access of an employee to EPHI is appropriate? (A)"
fiiId: "FII-SCF-IAC-0007"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable HIPAA compliance policies. Your task is to write a policy for the following control:

- **Control Code**: 164.308(a)(3)(ii)(B)  
- **Control Question**: Have you implemented procedures to determine the access of an employee to EPHI is appropriate? (A)  
- **Internal ID**: FII-SCF-IAC-0007  

### Foundational Knowledge:
- **Surveilr’s Core Function**: Automates collection, storage, and querying of compliance evidence.  
- **Machine Attestation**: Evidence that can be automatically validated. Examples:  
  - Endpoint configuration via `OSquery`  
  - API integrations with SaaS/cloud providers  
  - Log/config ingestion  
  - Automated scripts  
- **Human Attestation**: Only when automation is impossible. Must be specific and verifiable. Examples:  
  - Manager certifies access rights review quarterly  
  - Signed access request forms  
  - Physical inspection of access controls  
- Surveilr stores attestation artifacts (PDFs, forms, emails) and makes metadata (reviewer, date, outcome) queryable.  

### Required Policy Document Structure:
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

### Attestation Guidance:
- **Machine Attestation**: e.g., “Verify that user access levels are appropriate by ingesting access log data into Surveilr.”  
- **Human Attestation**: e.g., “HR must sign off on access permission changes and upload the signed document to Surveilr with metadata.”