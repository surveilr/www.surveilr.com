---
title: "HIPAA Risk Analysis - Author Prompt"
weight: 1
description: "Authoring prompt for HIPAA control 164.308(a)(1)(ii)(A)"
publishDate: "2025-09-22"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(1)(ii)(A)"
control-question: "Has a risk analysis been completed using IAW NIST Guidelines? (R)"
fiiId: "FII-SCF-RSK-0004"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

Generate a comprehensive HIPAA-compliant policy document addressing Control Code 164.308(a)(1)(ii)(A) titled "Risk Analysis." The document should follow structured MDX formatting and include the following sections: 

1. **Front Matter**: Include required metadata fields in YAML format: title, weight, description, publishDate, publishBy, classification, documentVersion, documentType, approvedBy, category (as array), satisfies (as array of FII-SCF-CODEs), merge-group, and order.

2. **Introduction**: Provide a concise purpose of the policy regarding risk analysis completion in accordance with NIST Guidelines.

3. **Policy Sections**: Use H2 headings for each major requirement. Each section should:
   - Explain the control requirement for conducting a risk analysis.
   - Suggest machine attestation methods, such as using automated tools to identify and assess risks and vulnerabilities. For example: "Utilize vulnerability scanning tools to automatically assess system vulnerabilities and ingest results into Surveilr."
   - Identify human attestation methods where automation is impractical, such as: "The risk management team must certify the completion of the risk analysis report quarterly, and this signed report should be uploaded to Surveilr with metadata including the reviewer name, date, and outcome."

4. **References**: Include a section at the end titled ### _References_ to cite relevant standards and guidelines.

5. **Attestation Guidance**: 
   - For Machine Attestation: Describe practical, automatable methods to collect evidence. For example: "Automate the collection of risk assessment results using a centralized vulnerability management system and integrate the data into Surveilr for compliance verification."
   - For Human Attestation: Outline the specific actions, artifacts, and ingestion methods into Surveilr. For example: "The Chief Compliance Officer must review and sign the risk analysis report, which will then be digitized and stored in Surveilr with all pertinent metadata."

Ensure the document emphasizes the prioritization of machine attestability while clearly documenting instances where human attestation is necessary, including detailed methods for documentation and ingestion into Surveilr. Focus on providing clarity and compliance without embedding SQL queries.