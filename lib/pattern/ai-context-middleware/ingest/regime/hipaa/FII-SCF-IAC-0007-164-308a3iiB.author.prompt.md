---
title: "HIPAA Appropriate Access Determination - Author Prompt"
weight: 1
description: "Authoring prompt for HIPAA control 164.308(a)(3)(ii)(B)"
publishDate: "2025-09-22"
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

Create a comprehensive HIPAA-compliant policy document addressing the control titled "Appropriate Access Determination" (Control Code: 164.308(a)(3)(ii)(B)). The document should follow structured MDX formatting and include the following sections: 

1. **Policy Statement**: Clearly state the purpose of the policy regarding the determination of employee access to Electronic Protected Health Information (EPHI).

2. **Scope**: Define who the policy applies to, including all employees who have access to EPHI.

3. **Responsibilities**: Outline the roles responsible for implementing and maintaining access determination procedures.

4. **Evidence Collection Methods**: 
   - Prioritize machine attestability by suggesting automated methods for collecting evidence. Examples include:
     - "Use OSquery to collect and validate endpoint configurations and ensure appropriate access levels to EPHI."
     - "Implement API integrations with cloud providers to automatically verify user access controls to EPHI."
     - "Ingest system logs directly into Surveilr to confirm policy adherence regarding access to EPHI."
   - Specify human attestation methods only when automation is impractical. Examples include:
     - "The HR manager must certify quarterly that access permissions for employees are reviewed and documented."
     - "A signed access review report must be uploaded to Surveilr, including metadata such as the reviewer's name and date."

5. **Verification Criteria**: Describe the criteria for verifying that access determination procedures are effective, focusing on both automated evidence and necessary human attestations.

6. **Exceptions**: Define any exceptions to the policy, if applicable.

End the document with a section titled **References** for any external resources or guidelines that support the policy.

Ensure that the document maximizes machine attestability while clearly documenting the instances where human attestation is required, specifying the exact actions, artifacts, and ingestion methods into Surveilr. Use standard markdown elements, including bullet points, bold text for emphasis, and inline code for technical terms. Avoid embedding SQL queries and focus solely on describing evidence collection methods.