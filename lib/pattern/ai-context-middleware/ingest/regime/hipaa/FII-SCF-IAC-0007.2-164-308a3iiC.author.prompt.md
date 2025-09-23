---
title: "HIPAA Access Termination - Author Prompt"
weight: 1
description: "Authoring prompt for HIPAA control 164.308(a)(3)(ii)(C)"
publishDate: "2025-09-22"
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

Generate a comprehensive HIPAA-compliant policy document for the control "Access Termination" (Control Code: 164.308(a)(3)(ii)(C)). The document should follow the structured MDX formatting guidelines provided below:

1. **Document Structure**:
   - **Front Matter (YAML Header)**: Include the following metadata fields: title, weight, description, publishDate, publishBy, classification, documentVersion, documentType, approvedBy, category (as an array), satisfies (as an array of FII-SCF-CODEs), merge-group, and order.
   - **Introduction**: Provide a concise purpose of the policy.
   - **Policy Sections**: Use H2 headings (##) for each major requirement. For each section:
     - Explain the control requirement.
     - Suggest machine attestation methods, such as “Use OSquery to collect access logs of terminated employees.”
     - Suggest human attestation methods where unavoidable, such as “A manager signs off on the access termination report for each employee who leaves.”

2. **Markdown Elements**:
   - Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms.
   - Include citation links for external references in the format: [Link Text](URL).

3. **Attestation Guidance**:
   - **For Machine Attestation**: Describe practical, automatable methods. For example:
     - “Automatically revoke access to EPHI by integrating with the HR system to trigger access termination when an employee is marked as terminated.”
     - “Use API calls to cloud service providers to ensure that all access tokens for terminated employees are invalidated.”
   - **For Human Attestation**: Describe precise steps and artifacts. For example:
     - “The HR department must provide a signed termination notice that is uploaded to Surveilr with metadata (review date, reviewer name).”
     - “The IT administrator must verify the access termination and document the process in a report uploaded to Surveilr.”

4. **Control to Address**:
   - Control Code: 164.308(a)(3)(ii)(C)
   - Control Question: Have you implemented procedures for terminating access to EPHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section? (A)
   - FII IDs: FII-SCF-IAC-0007.2
   - Description: Procedures for terminating EPHI access when employees leave or as required.

5. **Requirements for the Policy Document**:
   - Format: Include clear sections (Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions) in markdown format.
   - Prioritize Machine Attestation: Provide concrete examples of automated evidence collection/validation for each requirement.
   - Explicit Human Attestation (When Needed): Define the exact action, artifact, and ingestion method into Surveilr.
   - Attestation Descriptions Only: Focus on describing methods, avoiding the writing or embedding of SQL queries.

Ensure that the final policy document maximizes machine attestability while explicitly documenting where human attestation is necessary, along with the method and its limitations.