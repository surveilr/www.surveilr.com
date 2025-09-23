---
title: "HIPAA Information System Activity Review - Author Prompt"
weight: 1
description: "Authoring prompt for HIPAA control 164.308(a)(1)(ii)(D)"
publishDate: "2025-09-22"
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

Create a HIPAA-compliant policy document for the control "Information System Activity Review" with the following specifications:

1. **Document Structure:**
   - Start with a YAML header including the following metadata fields:
     - title: "Information System Activity Review Policy"
     - weight: 1
     - description: "Policy governing the regular review of information system activity records."
     - publishDate: "2025-09-09"
     - publishBy: "Compliance Automation Team"
     - classification: "Confidential"
     - documentVersion: "v1.0"
     - documentType: "Policy"
     - approvedBy: "Chief Compliance Officer"
     - category: ["Policy Authoring", "Compliance Automation", "Surveilr"]
     - satisfies: ["FII-SCF-RSK-0004"]
     - merge-group: "system-author-meta-prompts"
     - order: 1

2. **Introduction:**
   - Clearly state the purpose of the policy regarding the regular review of information system activity records, such as audit logs and access reports.

3. **Policy Sections:**
   - Use H2 headings (##) for major requirements:
     - **Control Requirement Explanation:** Describe the importance of regularly reviewing records of IS activity.
     - **Machine Attestation Methods:** Suggest practical automated methods for evidence collection, such as:
       - "Use OSquery to automatically collect and review audit logs weekly."
       - "Integrate with cloud service APIs to retrieve access reports for validation."
       - "Ingest system logs into Surveilr for ongoing compliance monitoring."
     - **Human Attestation Methods (if necessary):** Specify human actions required when automation is impractical, such as:
       - "The security manager shall certify quarterly that all audit logs have been reviewed, with a signed report submitted to Surveilr."
       - "Document inspection of security incident tracking logs, with reports uploaded to Surveilr including metadata (reviewer name, date, outcome)."

4. **References:**
   - End with a section titled ### _References_ where you can include any relevant external links.

5. **Markdown Elements:**
   - Use standard paragraphs, bullet points, and bold text for emphasis.
   - Format technical terms in inline code.

6. **Attestation Guidance:**
   - For Machine Attestation: Describe how to verify compliance through automation, such as:
     - "Confirm that all system logs are reviewed weekly by automatically ingesting data into Surveilr."
     - "Cross-check access logs against a predefined list of authorized users using automated scripts."
   - For Human Attestation: Clearly define the actions, artifacts, and methods for documenting human reviews:
     - "The IT security manager must sign the quarterly review report of IS activity logs."
     - "Upload the signed report to Surveilr, ensuring metadata (review date, reviewer name) is attached."

Ensure that the policy maximizes machine attestability and explicitly documents human attestation requirements where necessary, along with the methods and limitations of such attestations. Focus on providing clear, actionable instructions for each segment of the policy document.