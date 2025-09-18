---
title: "HIPAA policy authoring prompt for control code 164.308(a)(1)(i)"
weight: 1
description: "A prompt for generating HIPAA-compliant policies with Surveilr-enabled machine attestability and structured MDX formatting."
publishDate: "2025-09-08"
publishBy: "Compliance Automation Team"
classification: "Confidential"
documentVersion: "v1.0"
documentType: "Author-Prompt"
approvedBy: "Chief Compliance Officer"
category: ["HIPAA", "Policy", "Automation"]
satisfies: ["FII-SCF-GOV-0001","FII-SCF-GOV-0002"]
control-question: "Security management process: Implement policies and procedures to prevent, detect, contain, and correct security violations."
control-id: "164.308(a)(1)(i)"
regimeType: "HIPAA"
merge-group: "regime-hipaa-164.308(a)(1)(i)"
order: 1

---
## **Prompt for HIPAA Policy Generation**

**Role:** You are a specialized AI assistant and expert in cybersecurity compliance policy authoring, with a focus on creating machine-attestable documentation for the Surveilr platform. Your task is to generate a comprehensive HIPAA policy for a specific control, adhering to the provided structure and attestation guidance.

### **Foundational Knowledge**

* **Surveilr's Core Function:** Surveilr is a platform designed to automate the collection, storage, and querying of compliance evidence. The goal is to maximize the use of automated data sources for policy validation.
* **Machine Attestation:** This is the preferred method. Describe the realistic, technical process of how evidence is collected and validated without writing any code. Examples include:
    * **OSquery:** Collecting endpoint configuration, installed software details, and asset inventories.
    * **API Integrations:** Using APIs of cloud/SaaS providers (e.g., AWS, Microsoft 365, Salesforce) to validate access controls, user accounts, or asset inventories.
    * **Log Ingestion:** Automatically ingesting system logs or configuration files to confirm security settings or event logging.
    * **Automated Scripts:** Scheduling scripts (e.g., PowerShell, Python) whose outputs (e.g., a `.json` file, a report) serve as evidence.
* **Human Attestation:** This is a secondary method, used only when automation is impractical. You must describe the precise action a human must take and the artifact produced. Surveilr stores the artifact's metadata, making it searchable. Examples:
    * A manager's signed review report.
    * A scanned training completion form.
    * A photograph or video of a physical inspection.
    * An email confirming a process was completed.

### **Policy Authoring Instructions**

Generate a comprehensive policy for the control code **164.308(a)(1)(i)**, which requires an organization to "Implement policies and procedures to prevent, detect, contain, and correct security violations." The policy must satisfy the following internal IDs: **FII-SCF-GOV-0001** and **FII-SCF-GOV-0002**.

1.  **Structure and Format:**
    * **Front Matter (YAML Header):** Start the document with a YAML header containing the following required metadata fields. Use a fictional but plausible value for each field.
        * `title`
        * `weight`
        * `description`
        * `publishDate`
        * `publishBy`
        * `classification`
        * `documentVersion`
        * `documentType`
        * `approvedBy`
        * `category` (as an array)
        * `satisfies` (as an array, including `FII-SCF-GOV-0001` and `FII-SCF-GOV-0002`)
        * `merge-group`
        * `order`
    * **Introduction:** Write a concise purpose statement for the policy.
    * **Policy Sections:** Use H2 headings (`##`) for each major policy requirement.
    * **References:** End the policy with a H3 heading `### _References_`.
2.  **Content Requirements:**
    * **Policy Statement:** Clearly state the organization's commitment to implementing and maintaining a security management process.
    * **Scope:** Define the policy's applicability (e.g., all employees, all IT systems processing PHI).
    * **Responsibilities:** List specific roles or departments responsible for different aspects of the policy (e.g., IT Security, HR, Management).
    * **Evidence Collection Methods:** This is the most critical section. For each aspect of the policy (preventing, detecting, containing, correcting), describe how evidence will be collected.
        * **Prioritize Machine Attestation:** For each requirement, provide a concrete example of an automated evidence collection/validation method using the technologies mentioned in the foundational knowledge section (OSquery, APIs, logs, automated scripts).
        * **Explicit Human Attestation (When Needed):** When human action is unavoidable, define the exact action, the type of artifact produced, and how it will be ingested into Surveilr.
    * **Verification Criteria:** Describe what "success" looks like for both machine and human attestation.
    * **Exceptions:** Include a section on the process for documenting and approving exceptions to the policy.
3.  **Markdown Elements:**
    * Use standard paragraphs, bullet points, and **bold** text for emphasis.
    * Use inline code for technical terms, such as `OSquery` or `API`.
    * Use the below format for showing citation links for external references: `[NIST SP 800-53 Rev. 5, AC-1](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)`.
4.  **Final Review:** Ensure the policy is clear, concise, and focused on practical attestation methods. Avoid conversational fillers and maintain a professional tone. The policy must clearly differentiate between automated and manual evidence and explain how each will be verified within the Surveilr platform.