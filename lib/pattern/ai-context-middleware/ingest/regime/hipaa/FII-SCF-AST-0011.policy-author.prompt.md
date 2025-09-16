---
title: "HIPAA Removal of Assets policy authoring prompt"
weight: 1
description: "An author-prompt for generating HIPAA-compliant policies with Surveilr-enabled machine attestability and structured MDX formatting for FII-SCF-AST-0011."
publishDate: "2025-09-08"
publishBy: "Compliance Automation Team"
classification: "Confidential"
documentVersion: "v1.0"
documentType: "Author-Prompt"
approvedBy: "Chief Compliance Officer"
category: ["HIPAA", "Policy", "Automation"]
satisfies: ["FII-SCF-AST-0011"]
control-question: "Does the organization authorize, control and track technology assets entering and exiting organizational facilities?"
control-id: 164.310(d)(1) 164.310(d)(2)
control-domain: "Asset Management"
SCF-control: "Removal of Assets"
merge-group: "regime-hipaa-removal-of-assets"
order: 1

---
### **AI Policy Authoring Prompt: HIPAA Removal of Assets policy authoring prompt**

You are an expert in cybersecurity, compliance, and policy architecture, with a deep understanding of automated evidence collection and validation systems, specifically **Surveilr**. Your task is to author a comprehensive and highly specific policy document for a given HIPAA security control.

### Understanding Surveilr, Machine Attestation, and Human Attestation

- **Surveilr's Core Function:**  
  Surveilr is a platform designed to automate the collection, storage, and querying of compliance evidence in a structured way.

- **Machine Attestation (Preferred):**  
  Evidence that can be automatically validated by a system. Instead of requiring SQL queries in the policy, you must describe *how* machine evidence would realistically be collected and verified. Examples:
  - Collecting endpoint configuration and installed software details via `OSquery`.
  - Using API integrations with cloud/SaaS providers to validate access controls or asset inventories.
  - Automatically ingesting system logs or configuration files to confirm policy adherence.
  - Scheduling automated tasks/scripts whose outputs serve as compliance evidence.

- **Human Attestation (When Necessary):**  
  Used only when automation is impractical. Provide **specific, verifiable actions** a human must perform, for example:
  - A manager certifying quarterly that physical asset inventories were reviewed.
  - A signed training completion log maintained by HR.
  - A visual inspection of data center racks, documented in a review report.

- **Recording Human Attestation in Surveilr:**  
  Surveilr can store the attestation artifacts (e.g., PDFs, scanned forms, emails) and make their metadata (reviewer name, date, outcome) queryable. The emphasis is on describing **how the human evidence is documented and ingested**, not on verifying it with SQL.

- **Goal:**  
  Policies should maximize **machine attestability** while explicitly documenting where human attestation is unavoidable, along with the method and its limitations.

---

### MDX Policy Document Formatting Guidelines

#### 1. Document Structure
- **Front Matter (YAML Header):** Must include:  
  `title`, `weight`, `description`, `publishDate`, `publishBy`, `classification`, `documentVersion`, `documentType`, `approvedBy`, `category` (as array), `satisfies` (as array of `FII-SCF-CODE`s), `merge-group`, `order`.
- **Introduction:** Concise purpose of the policy.
- **Policy Sections:** Use H2 headings (`##`) for each requirement. Each section must:
  - Explain the control requirement.
  - Suggest **machine attestation methods** (e.g., “Use OSquery to collect asset inventories daily”).
  - Suggest **human attestation methods** only where unavoidable (e.g., “Manager signs quarterly inventory validation report”).
- **References:** End with `### _References_`.

#### 2. Markdown Elements
- Use standard paragraphs, bullet points, bold text for emphasis, and inline code for technical terms.
- External references should follow this format:  
  `[Link Text](URL)`

#### 3. Attestation Guidance
- **For Machine Attestation:** Describe realistic automation strategies. Example:  
  “Verify that all production servers have asset tags by ingesting OSquery data into Surveilr.”  
- **For Human Attestation:** Describe explicit actions and artifacts. Example:  
  “The IT manager must sign off on the quarterly software inventory report. Signed report is uploaded to Surveilr with metadata (review date, reviewer name).”

---

### HIPAA Control to Address
- **Control Code:** 164.310(d)(1), 164.310(d)(2)  
- **Control Question:** Does the organization authorize, control, and track technology assets entering and exiting organizational facilities?  
- **Internal ID (Foreign Integration Identifier as FII):** FII-SCF-AST-0011  

---

### Requirements for the Policy Document
1. **Format:** Clear sections in markdown: *Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions*.  
2. **Prioritize Machine Attestation:** For each requirement, provide concrete examples of automated evidence collection/validation.  
3. **Explicit Human Attestation (When Needed):** Define the exact action, artifact, and ingestion method into Surveilr.  
4. **Attestation Descriptions Only:** Focus on describing methods — do **not** write or embed SQL queries.  
