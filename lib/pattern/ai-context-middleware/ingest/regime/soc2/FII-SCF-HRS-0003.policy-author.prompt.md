---
title: "Common Criteria Related to Control Environment policy authoring prompt for SOC2 CC1-0002"
weight: 1
description: "An author-prompt for generating soc2-compliant policies with Surveilr-enabled machine attestability and structured MDX formatting."
publishDate: "2025-09-08"
publishBy: "Compliance Automation Team"
classification: "Confidential"
documentVersion: "v1.0"
documentType: "Author-Prompt"
approvedBy: "Chief Compliance Officer"
category: ["SOC2", "Policy", "Automation"]
satisfies: ["FII-SCF-HRS-0003"]
control-question: "Are core values communicated from executive management to personnel through policies and the employee handbook?"
control-id: "CC1-0002"
control-domain: "Common Criteria Related to Control Environment"
SCF-control: "CC1-0002"
merge-group: "regime-soc2-cc1-0002"
order: 2
---


Here is a **highly effective AI prompt** tailored to generate SOC 2 policy content for **Control CC2-0002**, optimized for use in **Surveilr** and aligned with your outlined requirements:

---

### ✅ AI PROMPT: Generate SOC 2 Policy for Organizational Structure Documentation (Control CC2-0002)

You are an AI writing assistant helping draft SOC 2 policy documentation that complies with **Trust Services Criteria** and is optimized for **automated compliance evidence collection** using **Surveilr**.

Please write a **comprehensive, structured SOC 2 policy** in **Markdown** format based on the following control requirement:

---

> **Control Code**: CC2-0002
> **Control Question**: Is management's organizational structure with relevant reporting lines documented in an organization chart?
> **Internal ID (FII)**: FII-SCF-HRS-0003

---

### 📌 Policy Requirements & Structure

The resulting policy **must** follow this **exact structure** and content guidance:

---

#### 🟨 YAML Front Matter (at the top of the file)

Include the following metadata as a YAML header:

```yaml
title: "Organizational Structure and Reporting Lines Policy"
weight: 10
description: "This policy defines how the organizational structure and reporting lines are documented, maintained, and verified."
publishDate: 2025-09-17
publishBy: "Security Compliance Team"
classification: "Internal"
documentVersion: "1.0"
documentType: "Policy"
approvedBy: "Chief Compliance Officer"
category:
  - "Human Resources"
  - "Governance"
satisfies:
  - "FII-SCF-HRS-0003"
merge-group: "organization-structure"
order: 2
```
---
## SOC2 Policy Authoring Prompt

### **Role:**

You are an expert in cybersecurity and compliance automation, specializing in authoring SOC2 policy documents. Your goal is to generate robust, clear, and machine-attestable policy content.

### **Core Task:**

Generate a comprehensive SOC2 policy document for the control `CC2-0002` (Organizational Structure and Reporting Lines). This document must be structured for maximum automated attestation via the **Surveilr** platform, while also clearly documenting necessary human attestation methods. The final output must be a complete policy document, not a set of instructions.

### **Surveilr's Core Function:**

**Surveilr** is an automation platform for collecting, storing, and querying compliance evidence. Machine-attestable evidence is collected through API integrations, system log ingestion, OSquery, and automated scripts. Human-attestable evidence is stored as artifacts (e.g., PDFs, scanned documents), with metadata (reviewer name, date, outcome) made queryable.

### **Policy Content Requirements:**

1.  **YAML Front Matter:** Include the following required metadata at the top of the document:
    * `title`: A clear, descriptive title.
    * `weight`: A numerical value for ordering, e.g., `100`.
    * `description`: A brief summary of the policy's purpose.
    * `publishDate`: The date of publication in `YYYY-MM-DD` format.
    * `publishBy`: The name of the author.
    * `classification`: `Confidential` or `Public`.
    * `documentVersion`: A version number, e.g., `1.0`.
    * `documentType`: `Policy`.
    * `approvedBy`: The name of the approving authority.
    * `category`: An array with the value `['Organizational Structure']`.
    * `satisfies`: An array with the value `['FII-SCF-HRS-0003']`.
    * `merge-group`: `policy-documents`.
    * `order`: A numerical value, e.g., `100`.

2.  **Document Structure:**
    * **Introduction:** Start with a concise section outlining the policy's purpose.
    * **Policy Sections:** Use `##` headings for each major requirement. For this control, include the following sections:
        * **Policy Statement:** The core requirement of the policy.
        * **Scope:** Who and what the policy applies to.
        * **Responsibilities:** Key roles and their duties.
        * **Evidence Collection Methods:** Detail the attestation process. This is the most critical section.
            * Sub-section `### Machine Attestation`: Describe how automated systems will collect evidence.
            * Sub-section `### Human Attestation`: Describe the precise actions, artifacts, and ingestion methods for human-based evidence.
        * **Verification Criteria:** How compliance is determined.
        * **Exceptions:** The process for handling deviations.
    * **References:** Conclude the document with a `### _References_` section.

3.  **Attestation Guidance:**
    * **Maximize Machine Attestation:** Prioritize automated methods. For this control, consider how an organization chart can be represented and verified via an API or structured data source. Examples:
        * "Verify the organizational chart's existence and last-modified date via an API call to a Human Resources Information System (HRIS) like Workday or BambooHR."
        * "Check for user accounts that are not assigned to a manager by querying the HRIS API for reporting line data."
        * "Confirm job titles and reporting structures are consistent across multiple systems by ingesting data from HRIS and Active Directory/LDAP and cross-referencing."
    * **Document Human Attestation:** Clearly define the unavoidable human tasks. For this control, consider the formal approval and review process of the organizational chart. Examples:
        * "Management must review and approve the organizational chart at least annually."
        * "The approved organizational chart must be signed by the Chief Information Officer (CIO) or a designated manager."
        * "The signed organizational chart (as a PDF) is uploaded to **Surveilr**. The metadata—including the reviewer's name, review date, and a confirmation of approval—is recorded within the platform."
        * "A signed attestation from a manager confirming the accuracy of the organizational structure is uploaded to **Surveilr** on a quarterly basis."

### **Markdown and Formatting:**

* Use standard markdown (`**bold**`, `*italics*`, `[Link Text](URL)`, `##` headings, `*` for bullet points, and inline code `like this`).
* Do not use verbose explanations or conversational filler. Be direct and clear.
* The final output should be the policy itself, not a set of instructions on how to write it. Start immediately with the YAML header.

