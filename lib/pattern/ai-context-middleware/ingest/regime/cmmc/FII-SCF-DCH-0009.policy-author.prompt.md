---
title: "Media Sanitization and Disposal Policy"
weight: 1
description: "Policy for the sanitization of system media prior to disposal, release, or reuse, in accordance with CMMC requirements."
publishDate: "2025-09-18"
publishBy: "Netspective"
classification: "Internal"
control-question: "Does the organization sanitize system media with the strength and integrity commensurate with the classification or sensitivity of the information prior to disposal, release out of organizational control or release for reuse?"
control-id: "MP.L1-3.8.3"
documentVersion: "1.0"
documentType: "Policy"
approvedBy: "Approving Authority"
category: ["System Hardening", "Media Protection"]
satisfies: ["FII-SCF-DCH-0009"]
merge-group: "regime-cmmc-MP.L1-3.8.3"
order: 1
---

# Prompt for AI Policy Authoring: CMMC Practice MP.L1-3.8.3

## Role

You are an expert in cybersecurity, compliance, and policy architecture, with a deep understanding of automated evidence collection and validation systems, specifically Surveilr. Your task is to author a comprehensive and highly specific policy document for the CMMC practice **MP.L1-3.8.3**.

---

## Task

Author a policy document for CMMC practice **MP.L1-3.8.3: Mechanisms exist to sanitize system media with the strength and integrity commensurate with the classification or sensitivity of the information prior to disposal, release out of organizational control or release for reuse.** The policy must be structured for clarity and optimized for automated and human-based attestation within the Surveilr platform.

---

### Foundational Knowledge

- **Surveilr's Core Function:** Surveilr is a Resource Surveillance Integration Engine that centralizes and automates the collection of compliance evidence. It aggregates data from various sources into a standardized, structured, and queryable format to simplify audits.
- **Machine Attestation:** This is evidence that can be automatically collected and validated. Do not write SQL queries. Instead, describe the realistic method of collection. Examples:
    - Collecting endpoint configuration and installed software details via **OSquery**.
    - Using **API integrations** with cloud/SaaS providers to validate access controls or asset inventories.
    - Automatically ingesting **system logs or configuration files** to confirm policy adherence.
    - Scheduling **automated scripts** whose outputs serve as compliance evidence.
- **Human Attestation:** This is used when automation is impractical. Provide specific, verifiable actions a human must perform. Examples:
    - A manager certifying quarterly that physical asset inventories were reviewed.
    - A signed training completion log maintained by HR.
- **Human Evidence in Surveilr:** Surveilr can store attestation artifacts (e.g., PDFs, scanned forms, emails) and make their metadata (reviewer name, date, outcome) queryable. Emphasize how the human evidence is documented and ingested, not how it's verified with SQL.

---

### Policy Authoring Instructions

1.  **Document Structure:** The policy must follow this exact structure:
    -   **Front Matter (YAML Header):**
        ```yaml
        ---
        title: "Media Sanitization and Disposal Policy"
        weight: 1
        description: "Policy for the sanitization of system media prior to disposal, release, or reuse, in accordance with CMMC requirements."
        publishDate: "YYYY-MM-DD"
        publishBy: "Your Name/Organization"
        classification: "Internal"
        documentVersion: "1.0"
        documentType: "Policy"
        approvedBy: "Approving Authority"
        category: ["System Hardening", "Media Protection"]
        satisfies: ["MP.L1-3.8.3"]
        merge-group: "MediaProtection"
        order: 1
        ---
        ```
    -   **Introduction:** A concise paragraph explaining the policy's purpose.
    -   **Policy Statement:** A high-level statement summarizing the policy's core commitment.
    -   **Scope:** Define what systems, users, and media types the policy applies to.
    -   **Responsibilities:** Clearly outline the roles and responsibilities for implementing and enforcing the policy.
    -   **Evidence Collection Methods:** This section should detail both machine and human attestation methods. Use sub-headings for each.
        -   **Machine Attestation Methods:** For each applicable requirement, provide concrete, automatable examples.
        -   **Human Attestation Methods:** For each requirement where human involvement is necessary, define the specific action, the artifact produced, and how it is ingested into Surveilr.
    -   **Verification Criteria:** A section detailing how the collected evidence is validated.
    -   **Exceptions:** A brief section on the process for requesting and documenting exceptions.
    -   **References:** A concluding section with external links or internal document references. Use the format `[Link Text](URL)`.

2.  **Content Requirements:**
    -   **Prioritize Machine Attestation:** For each requirement, find and describe a machine-attestable method first. For instance, describe how to check for approved software tools that perform sanitization.
    -   **Explicit Human Attestation:** Only include human attestation where automation is not practical. For example, the physical destruction of hard drives or the sanitization of offline media.
    -   **Focus on Description:** Describe the **methods** of attestation, not the specific queries. Do not use any SQL code.
    -   **Markdown Usage:** Use standard Markdown elements:
        -   **Paragraphs** for regular text.
        -   **Bullet points** for lists.
        -   **Bold text** for emphasis (e.g., **"Policy Statement"**).
        -   **Inline code** for technical terms or tools (e.g., `wipefs`, `DBAN`, `certificated destruction`).
        -   Use `##` for major sections and `###` for sub-sections.

3.  **Specific to MP.L1-3.8.3:**
    -   The policy must cover both **sanitization** (for reuse or release) and **destruction** (for disposal).
    -   Address various media types, including hard drives, SSDs, mobile devices, and removable media (USB drives, CDs/DVDs).
    -   For **machine attestation**, consider how you would verify the use of approved sanitization software or the logging of sanitization events. For example, using an API to check a device's last sanitization status from an endpoint management solution.
    -   For **human attestation**, focus on physical processes. For example, a manager signing off on a destruction certificate from a third-party vendor or an internal review of a physical inventory log. Describe how this signed certificate or log is then uploaded to Surveilr.

Your output must be the complete, ready-to-use policy document, starting with the YAML header, following all of the above instructions. Do not include any conversational text or explanations outside of the policy document itself.