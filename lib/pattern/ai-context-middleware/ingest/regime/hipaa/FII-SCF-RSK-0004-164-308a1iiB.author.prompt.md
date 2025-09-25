---
title: "Author Prompt: HIPAA Risk Management Policy"
weight: 1
description: "Establishes a comprehensive risk management process to protect PHI in compliance with HIPAA and NIST guidelines."
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

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for the following control:

**Control Code**: 164.308(a)(1)(ii)(B)  
**Control Question**: Has the risk management process been completed using IAW NIST Guidelines? (R)  
**Internal ID**: FII-SCF-RSK-0004  

Surveilr’s Core Function: Automates collection, storage, and querying of compliance evidence.  
Machine Attestation: Evidence that can be automatically validated. Examples:  
- Endpoint configuration via `OSquery`  
- API integrations with SaaS/cloud providers  
- Log/config ingestion  
- Automated scripts  

Human Attestation: Only when automation is impossible. Must be specific and verifiable. Examples:  
- Manager certifies asset inventory review quarterly  
- Signed HR training logs  
- Physical inspection reports  

Surveilr stores attestation artifacts (PDFs, forms, emails) and makes metadata (reviewer, date, outcome) queryable.  

### Policy Document Structure
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
- **Machine Attestation**: e.g., “Verify risk management process completion by ingesting relevant assessment data into Surveilr.”  
- **Human Attestation**: e.g., “Risk Management Officer must sign the completed risk management report, then upload to Surveilr with metadata.”