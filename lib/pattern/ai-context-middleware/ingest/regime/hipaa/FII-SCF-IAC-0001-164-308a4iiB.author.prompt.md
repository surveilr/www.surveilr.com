---
title: "Access Control Policies Author Prompt"
weight: 1
description: "Access Control Policies This control requires the implementation of comprehensive policies and procedures that govern how access to electronic Protected Health Information (EPHI) is granted. These policies should outline the processes for authorizing access to workstations, transactions, programs, or any other relevant systems, ensuring that only authorized personnel can access sensitive information. Regular reviews and updates to these access controls are essential to maintain the confidentiality, integrity, and availability of EPHI."
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

**Control Code**: 164.308(a)(4)(ii)(B)  
**Control Question**: Have you implemented policies and procedures for granting access to EPHI, for example, through access to a workstation, transaction, program, or process? (A)  
**Internal ID**: FII-SCF-IAC-0001  

### Policy Document Structure
- **Introduction** – concise purpose  
- **Policy Statement** – high-level declaration  
- **Scope** – what/who it applies to  
- **Responsibilities** – clear roles/duties  
- **Evidence Collection Methods** – with subheadings per requirement:  
  - **Explanation**  
  - **Machine Attestation**  
  - **Human Attestation (if unavoidable)**  
- **Verification Criteria**  
- **Exceptions**  
- **References**  
### _References_

### Foundational Knowledge
- **Surveilr’s Core Function**: Automates collection, storage, and querying of compliance evidence.  
- **Machine Attestation**: Evidence that can be automatically validated. Examples:  
  - Endpoint configuration via `OSquery`  
  - API integrations with SaaS/cloud providers  
  - Log/config ingestion  
  - Automated scripts  
- **Human Attestation**: Only when automation is impossible. Must be specific and verifiable. Examples:  
  - Manager certifies access control policy review annually  
  - Signed access control training logs  
  - Physical access logs  
- Surveilr stores attestation artifacts (PDFs, forms, emails) and makes metadata (reviewer, date, outcome) queryable.  

### Attestation Guidance
- **Machine Attestation**: e.g., “Verify access control lists and permissions through automated reports ingested into Surveilr.”  
- **Human Attestation**: e.g., “Compliance Officer must sign the annual access control policy review, then upload to Surveilr with metadata.”