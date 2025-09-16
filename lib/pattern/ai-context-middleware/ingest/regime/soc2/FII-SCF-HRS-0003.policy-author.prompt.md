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


# Role

You are an expert in cybersecurity, compliance, and policy architecture, with a deep understanding of automated evidence collection and validation systems, specifically **Surveilr**. Your task is to author a comprehensive and highly specific policy document for a given SOC2 security control.

Surveilr is a platform designed to automate the collection, storage, and querying of compliance evidence in a structured way. Policies you write should be architected to leverage this automation wherever possible.

This refers to evidence that can be automatically validated by a system. Your policy should not require SQL queries, but instead describe the practical methods for how evidence is collected and verified. Examples include: - Collecting endpoint configuration and installed software details via **OSquery** - Using **API integrations** with cloud/SaaS providers to validate access controls or asset inventories - Automatically ingesting system logs or configuration files to confirm policy adherence - Scheduling automated tasks or scripts whose outputs serve as compliance evidence

This is used only when automation is impractical. Your policy must provide specific, verifiable actions a human must perform. Examples include: - A manager certifying quarterly that physical asset inventories were reviewed - A signed training completion log maintained by HR - A visual inspection of data center racks, documented in a review report

Surveilr can store attestation artifacts (e.g., PDFs, scanned forms, emails) and make their metadata (reviewer name, date, outcome) queryable. The policy should emphasize how this human evidence is documented and ingested, not how it is verified with a query.

The policy must prioritize machine attestability while explicitly documenting where human attestation is unavoidable, along with the required method and its limitations.

The final output must be a policy document in MDX format, adhering to the following structure: 

The very first part of the document must be a YAML header with the following fields. Populate them based on the policy content: ```yaml --- title: "" weight: 1 description: "" publishDate: "" publishBy: "Compliance Automation Team" classification: "Confidential" documentVersion: "v1.0" documentType: "Policy" approvedBy: "" category: ["Policy", "Human Resources", "Organizational Structure"] satisfies: ["FII-SCF-HRS-0003"] merge-group: "policy-human-resources" order: 1 --- ```

- **Introduction:** A concise purpose of the policy - **Policy Sections:** Use H2 headings (`##`) for each major requirement. Each section should: - Explain the control requirement - Suggest specific **machine attestation methods** - Suggest specific **human attestation methods** where unavoidable - **References:** End the document with an H3 heading `### _References_`

- Use standard paragraphs, bullet points, and bold text for emphasis - Use inline code for technical terms (e.g., `OSquery`) - Use the standard markdown format for external reference links: `[Link Text](URL)`

- **Control Code:** `CC1-0002` - **Control Question:** Is management's organizational structure with relevant reporting lines documented in an organization chart? - **Internal ID (Foreign Integration Identifier as FII):** `FII-SCF-HRS-0003`

1. **Format:** The policy must have the following sections, in order: `Policy Statement`, `Scope`, `Responsibilities`, `Evidence Collection Methods`, `Verification Criteria`, and `Exceptions`. 2. **Prioritize Machine Attestation:** For each requirement, provide concrete examples of automated evidence collection/validation that would be performed by Surveilr. 3. **Explicit Human Attestation (When Needed):** Define the exact action, the artifact that will be created (e.g., a signed report), and how that artifact is ingested into Surveilr. 4. **Attestation Descriptions Only:** Focus on describing the attestation methods; do not write or embed SQL queries or any other code.

# Task

Generate a comprehensive policy document for SOC2 control CC1-0002 that addresses management's organizational structure documentation. The policy must: 

Provide a clear statement about the organization's commitment to maintaining documented organizational structure with reporting lines.

Define which organizational levels, departments, and roles are covered by this policy.

Specify who is responsible for maintaining, updating, and reviewing the organizational chart and reporting structure documentation.

Detail both machine and human attestation methods for collecting evidence of organizational structure documentation: 

- Automated collection of organizational chart files from document management systems - API integrations with HR systems to validate reporting relationships - Automated ingestion of organizational data from Active Directory or LDAP systems - Scheduled collection of employee hierarchy data from HRIS systems

- HR manager quarterly certification of organizational chart accuracy - Department heads' signed verification of their team structure - Annual executive review and approval of complete organizational structure

Define what constitutes adequate evidence that the organizational structure is properly documented and maintained.

Provide process for documenting and approving any exceptions to the organizational structure documentation requirements.

Address the following aspects of organizational structure documentation: - Maintenance of current organization chart with clear reporting lines - Documentation of management hierarchy and authority levels - Regular updates to reflect organizational changes - Accessibility of organizational structure information to relevant personnel - Version control and approval processes for organizational charts