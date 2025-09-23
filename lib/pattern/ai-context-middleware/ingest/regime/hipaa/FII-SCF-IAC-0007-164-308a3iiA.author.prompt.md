---
title: "HIPAA Authorization and Supervision - Author Prompt"
weight: 1
description: "Authoring prompt for HIPAA control 164.308(a)(3)(ii)(A)"
publishDate: "2025-09-22"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "164.308(a)(3)(ii)(A)"
control-question: "Have you implemented procedures for the authorization and/or supervision of employees who work with EPHI or in locations where it might be accessed? (A)"
fiiId: "FII-SCF-IAC-0007"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

Generate a comprehensive HIPAA-compliant policy document addressing the following control:

**Control Code:** 164.308(a)(3)(ii)(A)  
**Control Title:** Authorization and Supervision  
**Control Question:** Have you implemented procedures for the authorization and/or supervision of employees who work with EPHI or in locations where it might be accessed? (A)  
**FII IDs:** FII-SCF-IAC-0007, FII-SCF-IAC-0007.1  
**Description:** Procedures for authorization and supervision of employees working with EPHI.

The policy document should be structured in markdown format with the following sections:

1. **Policy Statement:** A concise statement of the policy’s purpose regarding authorization and supervision of employees with EPHI.
2. **Scope:** Define the applicability of this policy, detailing which employees and locations it covers.
3. **Responsibilities:** Outline the roles and responsibilities of management and staff in relation to the policy.
4. **Evidence Collection Methods:**  
   - Describe machine attestation methods to collect and verify evidence of authorization and supervision procedures. Examples may include:  
     - “Use API integrations to validate that employee access to EPHI is limited to those authorized.”
     - “Automatically extract user access logs from systems handling EPHI and ingest them into Surveilr for daily review.”
   - Suggest human attestation methods only where automation is impractical. Examples may include:  
     - “The HR manager must maintain and sign a quarterly report that lists all employees with access to EPHI.”
     - “Upload the signed report to Surveilr along with metadata including the reviewer name, review date, and outcome.”
5. **Verification Criteria:** Specify how compliance will be verified, focusing on machine attestability while indicating instances of human attestation.
6. **Exceptions:** Document any exceptions to the policy along with the rationale.

End the document with a **References** section for any external sources or guidelines that inform the policy.

Ensure the document maximizes machine attestability, clearly states where human attestation is necessary, and provides detailed instructions for documenting human evidence in Surveilr without embedding SQL queries. Use bullet points, bold text for key terms, and inline code formatting where applicable.