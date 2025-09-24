---
title: "IS Activity Review Author Prompt"
weight: 1
description: "IS Activity Review Regular reviews of information system (IS) activity are essential for maintaining security and compliance with HIPAA regulations. This control involves implementing procedures to consistently examine audit logs, access reports, and security incident tracking to identify potential security breaches, unauthorized access, or anomalies. By routinely monitoring these records, organizations can enhance their ability to respond to incidents and protect sensitive patient information effectively."
publishDate: "2025-09-24"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(1)(ii)(D)"
control-question: "Have you implemented procedures to regularly review records of IS activity such as audit logs, access reports, and security incident tracking? (R)"
fiiId: "FII-SCF-RSK-0004"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable HIPAA compliance policies. Your task is to write a policy for the following control:

**Control Code**: 164.308(a)(1)(ii)(D)  
**Control Question**: Have you implemented procedures to regularly review records of IS activity such as audit logs, access reports, and security incident tracking? (R)  
**Internal ID**: FII-SCF-RSK-0004  

### Policy Document Structure
- **Introduction** – concise purpose  
- **Policy Statement** – high-level declaration  
- **Scope** – what/who it applies to  
- **Responsibilities** – clear roles/duties  
- **Evidence Collection Methods** – with subheadings per requirement:  
  - **Explanation**  
  - **Machine Attestation**  
  - **Human Attestation** (if unavoidable)  
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
  - Manager certifies asset inventory review quarterly  
  - Signed HR training logs  
  - Physical inspection reports  
- Surveilr stores attestation artifacts (PDFs, forms, emails) and makes metadata (reviewer, date, outcome) queryable.

### Attestation Guidance
- **Machine Attestation**: e.g., “Verify audit logs are regularly reviewed by ingesting access report data into Surveilr.”  
- **Human Attestation**: e.g., “Compliance Officer must sign the quarterly audit log review report, then upload to Surveilr with metadata.”