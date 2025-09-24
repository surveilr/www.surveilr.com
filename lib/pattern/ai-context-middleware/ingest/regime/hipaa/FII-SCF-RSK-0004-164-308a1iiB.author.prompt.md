---
title: "Risk Management Author Prompt"
weight: 1
description: "Risk Management Compliance The risk management process must be conducted in accordance with the National Institute of Standards and Technology (NIST) guidelines to ensure that all potential risks to sensitive information are identified, assessed, and mitigated appropriately. This involves a systematic approach to evaluating threats and vulnerabilities, implementing necessary safeguards, and regularly reviewing and updating the risk management strategies to maintain compliance with HIPAA regulations. Adhering to these guidelines helps organizations protect patient information and reduce the likelihood of data breaches."
publishDate: "2025-09-24"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(1)(ii)(B)"
control-question: "Has the risk management process been completed using IAW NIST Guidelines? (R)"
fiiId: "FII-SCF-RSK-0004"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable HIPAA compliance policies. Your task is to write a policy for the following control:

**Control Code**: 164.308(a)(1)(ii)(B)  
**Control Question**: Has the risk management process been completed using IAW NIST Guidelines? (R)  
**Internal ID**: FII-SCF-RSK-0004  

**Foundational Knowledge**:  
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

**Required Policy Document Structure**:  
1. **Introduction** – concise purpose  
2. **Policy Statement** – high-level declaration  
3. **Scope** – what/who it applies to  
4. **Responsibilities** – clear roles/duties  
5. **Evidence Collection Methods** – with subheadings per requirement:  
   - Explanation  
   - Machine Attestation  
   - Human Attestation (if unavoidable)  
6. **Verification Criteria**  
7. **Exceptions**  
8. **References** (with `### _References_`)  

**Attestation Guidance**:  
- Machine Attestation: e.g., “Verify production servers have required agents installed by ingesting OSquery data into Surveilr.”  
- Human Attestation: e.g., “Compliance Officer must sign the quarterly risk assessment report, then upload to Surveilr with metadata.”