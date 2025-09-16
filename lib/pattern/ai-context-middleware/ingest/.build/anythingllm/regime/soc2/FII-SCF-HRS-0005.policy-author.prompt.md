---
title: >-
  Common Criteria Related to Control Environment policy authoring prompt for
  SOC2 CC1-0001
weight: 1
description: >-
  An author-prompt for generating soc2-compliant policies with Surveilr-enabled
  machine attestability and structured MDX formatting.
publishDate: '2025-09-08'
publishBy: Compliance Automation Team
classification: Confidential
documentVersion: v1.0
documentType: Author-Prompt
approvedBy: Chief Compliance Officer
category:
  - SOC2
  - Policy
  - Automation
satisfies:
  - FII-SCF-HRS-0005
control-question: >-
  Are core values communicated from executive management to personnel through
  policies and the employee handbook?
control-id: CC1-0001
control-domain: Common Criteria Related to Control Environment
SCF-control: CC1-0001
merge-group: regime-soc2-cc1-0001
order: 2
provenance:
  dependencies:
    - >-
      src/ai-context-engineering/external--public--cross-tenant--support--system--index.prompt.md
    - >-
      src/ai-context-engineering/regime/soc2/FII-SCF-HRS-0005.policy-author.prompt.md
---

# Opsfolio

## What is Opsfolio and how does it work?

Opsfolio is a compliance automation platform that helps companies pass cybersecurity audits and obtain certifications like SOC2, HIPAA, ISO, CMMC, FedRAMP, and HITRUST. The company combines expert human guidance with AI automation and a "Compliance-as-Code" methodology to deliver guaranteed compliance outcomes rather than just providing software tools.

## Core Value Proposition

Opsfolio positions itself as "More than software. Better than consultants" by offering three integrated services:

1. **Expert-Guided Compliance**: Real compliance engineers provide fractional Chief Compliance Officer (CCO) services, compliance coaching, expert policy authoring, and audit preparation support.
2. **AI-Driven Policy & Evidence Tools**: Intelligent automation that generates compliance evidence from existing workflows, including automated evidence collection, policy generation, gap analysis, and real-time monitoring.
3. **Unified System of Record**: A centralized platform managing all compliance data, policies, controls, and audit trails with unified dashboards and audit readiness scoring.

## Compliance-as-Code Methodology

Opsfolio's distinctive approach treats compliance like software development. Individual Contributors (ICs) such as architects, engineers, QA specialists, and customer success teams can continue their regular work while Opsfolio automatically generates compliance evidence from artifacts they already produce - including code, test results, and customer feedback. This follows the DRY (Don't Repeat Yourself) principle, eliminating duplicate compliance work.

Key features include:

- Code-first compliance evidence generation
- Version-controlled policies treated like code
- Automated evidence collection from development workflows
- Team-centric approach that doesn't disrupt core responsibilities

## Technology Foundation: surveilr

The platform is powered by surveilr, a downloadable single binary that runs securely on Windows, Linux, and macOS within customer infrastructure. This creates a "Compliance Evidence Warehouse" - a SQL-queryable private data warehouse that can operate on laptops with minimal IT support.

surveilr provides:

- Local-first, edge-based evidence collection
- SQL queryable data warehouse
- Private and secure data handling (data stays with the customer)
- Continuous surveillance and evidence collection
- Machine attestable, auditable evidence
- Cross-platform compatibility

## Competitive Differentiation

Compared to traditional compliance tools like Vanta and Drata, Opsfolio offers:

- Compliance-as-Code approach vs. DIY software tools
- Guaranteed compliance outcomes vs. software license with uncertain results
- 60% faster implementation via automated evidence collection
- Fractional CCO support and AI-powered insights vs. documentation and chat support
- Machine attestation where CI/CD pipelines become compliance evidence engines

## Target Market and Results

Opsfolio serves companies needing regulatory compliance certifications, particularly those with engineering-focused teams. The company claims:

- 500+ client companies
- 98% audit pass rate
- Ability to achieve SOC2 Type 2 certification in 2 months
- 60% faster compliance implementation compared to traditional methods

## Business Model

The platform combines human expertise (fractional compliance officers), AI automation for evidence collection and policy generation, and a technical infrastructure (surveilr) that maintains customer data privacy while enabling automated compliance reporting and machine attestation for auditors.

# Role

You are an expert in cybersecurity, compliance, and policy architecture, with a deep understanding of automated evidence collection and validation systems, specifically **Surveilr**. Your task is to author a comprehensive and highly specific policy document for the following SOC2 control: - **Control Code:** CC1-0001 - **Control Question:** Are core values communicated from executive management to personnel through policies and the employee handbook? - **Internal ID (FII):** FII-SCF-HRS-0005

# Task

Author a comprehensive and machine-attestation-focused policy for SOC2 control CC1-0001. Your policy should prioritize automated verification of the existence and accessibility of the employee handbook, while also defining a clear human attestation process for validating the content and its approval by executive management.

Surveilr is a platform designed to automate the collection, storage, and querying of compliance evidence. Your policy must reflect this function by prioritizing machine-attestable methods while clearly documenting any unavoidable human attestation. 

This is evidence that can be automatically validated by a system. Instead of requiring SQL queries, you must describe how machine evidence would realistically be collected and verified. **Examples of methods:** - Collecting endpoint configuration and installed software details via **OSquery** - Using **API integrations** with cloud/SaaS providers to validate access controls or asset inventories - Automatically ingesting system logs or configuration files to confirm policy adherence - Scheduling automated tasks/scripts whose outputs serve as compliance evidence

Use this only when automation is impractical. Provide specific, verifiable actions a human must perform. **Examples of methods:** - A manager certifying quarterly that physical asset inventories were reviewed - A signed training completion log maintained by HR - A visual inspection of data center racks, documented in a review report **Crucial Note:** Surveilr can store the attestation artifacts (e.g., PDFs, scanned forms, emails) and make their metadata (reviewer name, date, outcome) queryable. The emphasis is on describing how the human evidence is documented and ingested, not on writing or embedding SQL queries.

Your response must be a single, complete policy document written in Markdown. 

Begin the document with the following metadata in a YAML header format: ```yaml --- title: Policy on Core Values Communication weight: 10 description: This policy outlines the process for communicating core values to all personnel. publishDate: YYYY-MM-DD publishBy: [Author Name] classification: Internal documentVersion: 1.0 documentType: Policy approvedBy: [Approver Name] category: - Human Resources - Governance satisfies: - FII-SCF-HRS-0005 merge-group: SOC2-CC1 order: 1 --- ```

Provide a concise purpose statement for the policy.

Use H2 headings (##) for each major section. The sections must be: - `## 1. Policy Statement` - `## 2. Scope` - `## 3. Responsibilities` - `## 4. Evidence Collection Methods` - `## 5. Verification Criteria` - `## 6. Exceptions`

Describe practical, automatable methods within the `Evidence Collection Methods` section. - *Example:* "Verify that all production servers have asset tags by ingesting **OSquery** data into Surveilr." - *Example:* "Check for unauthorized software by comparing ingested software inventory against an approved list."

Clearly define the precise steps, the required artifact, and how it is ingested into Surveilr within the `Evidence Collection Methods` section. - *Example:* "The IT manager must sign off on the quarterly software inventory report." - *Example:* "Signed report is uploaded to Surveilr with metadata (review date, reviewer name)."

Use standard paragraphs, bullet points, **bold text for emphasis**, and `inline code` for technical terms.

End the document with a final `### _References_` section. Use the following format for any external citation links: `[Link Text](URL)`.

Your policy must address the following aspects of core values communication: 

- Existence and accessibility verification through automated systems - Version control and approval tracking - Distribution mechanisms and employee acknowledgment - Content validation for core values inclusion

- Automated collection of policy documents containing core values - Executive approval tracking and documentation - Policy distribution and access verification - Regular review and update processes

- Multiple communication methods for core values dissemination - Training programs and completion tracking - Employee understanding and acknowledgment verification - Feedback mechanisms and effectiveness measurement

Ensure your descriptions of evidence collection are concrete and align with the capabilities of Surveilr: 

- Automated verification of employee handbook availability on company intranet - API integration with document management systems to track policy versions - Automated collection of training completion records from LMS systems - Integration with email systems to verify policy distribution - Automated monitoring of intranet access logs for handbook usage

- Executive management quarterly certification of core values communication - HR manager signed verification of employee handbook content accuracy - Department heads' attestation of core values training completion - Employee survey results on core values understanding and awareness

The final output should be a complete markdown document, including: 1. YAML header with all specified metadata 2. Introduction section explaining the policy's purpose 3. All six required policy sections with H2 headings 4. Detailed evidence collection methods prioritizing machine attestation 5. Clear human attestation processes where automation is not feasible 6. References section at the end 7. Consistent markdown formatting throughout 8. Concrete, Surveilr-compatible evidence collection descriptions