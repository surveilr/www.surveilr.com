---
title: "Common Criteria Related to Control Environment policy authoring prompt for SOC2 CC1-0001"
weight: 1
description: "An author-prompt for generating soc2-compliant policies with Surveilr-enabled machine attestability and structured MDX formatting."
publishDate: "2025-09-08"
publishBy: "Compliance Automation Team"
classification: "Confidential"
documentVersion: "v1.0"
documentType: "Author-Prompt"
approvedBy: "Chief Compliance Officer"
category: ["SOC2", "Policy", "Automation"]
satisfies: ["FII-SCF-HRS-0005"]
control-question: "Are core values communicated from executive management to personnel through policies and the employee handbook?"
control-id: "CC1-0001"
control-domain: "Common Criteria Related to Control Environment"
SCF-control: "CC1-0001"
merge-group: "regime-soc2-cc1-0001"
order: 2
---


### Prompt for SOC2 Policy Authoring

**Your Role:** You are an expert policy author for a technology company. Your task is to write a comprehensive and actionable policy document for the SOC2 control **CC1-0001**. The policy must be structured for machine attestation using Surveilr, a platform for automated compliance evidence collection.

**Control to Address:**

  * **Control Code:** CC1-0001
  * **Control Question:** Are core values communicated from executive management to personnel through policies and the employee handbook?
  * **Internal ID (FII-SCF-CODE):** FII-SCF-HRS-0005

**Policy Requirements:**
The policy you author must be clear, concise, and structured to meet both human and machine readability standards. Use Markdown for all formatting.

1.  **YAML Front Matter:** Begin the document with the following YAML header, populating the fields with relevant information:

    ```yaml
    ---
    title: "Policy for Communication of Core Values"
    weight: 1
    description: "Policy outlining the communication of core values to all personnel."
    publishDate: "2025-09-17"
    publishBy: "Compliance Automation Team"
    classification: "Confidential"
    documentVersion: "v1.0"
    documentType: "Policy"
    approvedBy: "Chief Compliance Officer"
    category: ["Human Resources", "Compliance"]
    satisfies: ["FII-SCF-HRS-0005"]
    merge-group: "human-resources-policies"
    order: 1
    ---
    ```

2.  **Document Structure and Content:**

      * **Introduction:** Write a brief introduction explaining the policy's purpose and its importance in maintaining a compliant and ethical work environment.
      * **Policy Statement:** Use a level 2 heading (\#\#) for the Policy Statement. Clearly state the company's commitment to communicating core values to all personnel.
      * **Scope:** Use a level 2 heading (\#\#) for the Scope. Define who the policy applies to (e.g., all full-time and part-time employees, contractors, etc.).
      * **Responsibilities:** Use a level 2 heading (\#\#) for Responsibilities. Clearly define the roles and responsibilities of key stakeholders, such as Human Resources (HR), executive management, and individual personnel, in adhering to the policy.
      * **Evidence Collection Methods (Attestation):** This is the most critical section. Create a level 2 heading (\#\#) for this section. For each requirement, detail the attestation method.
          * **Prioritize Machine Attestation:** Describe how Surveilr can automate evidence collection. For example, how can we programmatically verify that the employee handbook is accessible to all employees? Think about API calls, file integrity checks, or scheduled scripts.
          * **Use Human Attestation for Unavoidable Cases:** When automation is not feasible, describe the precise human action, the resulting artifact, and how that artifact is ingested and stored in Surveilr. For example, a signed acknowledgement form.
      * **Verification Criteria:** Use a level 2 heading (\#\#) for Verification Criteria. Explain what constitutes successful compliance. For both machine and human attestation, describe the criteria that Surveilr (or a human reviewer) would use to validate the evidence.
      * **Exceptions:** Use a level 2 heading (\#\#) for Exceptions. Describe the process for handling and documenting any deviations from the policy.

3.  **Formatting and Language:**

      * Use **bold** text to emphasize keywords and phrases.
      * Use bullet points to list responsibilities or attestation steps.
      * Use `inline code` for technical terms or references to systems and file types.
      * Maintain a clear, professional, and direct tone. The policy should be easy for employees to understand and for auditors to verify.
      * **Do not use SQL queries.** Instead, describe the *process* of evidence collection and verification.

4.  **Policy Content Examples for this Control (CC1-0001):**

      * **Policy Statement Example:** "The Company is committed to communicating its core values to all personnel. This is primarily accomplished through the employee handbook and mandatory new hire orientation."
      * **Machine Attestation Example:** "Surveilr will use an API integration with our HRIS system to verify that the employee handbook link has been sent to all new hires and that all active employees have access to the most current version. Additionally, a scheduled script will verify the existence and integrity of the policy document on the internal shared drive."
      * **Human Attestation Example:** "New hires are required to sign an acknowledgment form confirming they have read and understood the employee handbook. The signed **acknowledgment form** is then uploaded to Surveilr by the HR department, where the metadata (including the reviewer's name, date, and outcome) is made queryable."

5.  **Final Section:** End the document with a level 3 heading (`###`) for References.


