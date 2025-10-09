---
title: "Author Prompt: Consecutive Invalid Login Attempts Policy"
weight: 1
description: "Enforces account lockout procedures to limit consecutive invalid login attempts, enhancing security and preventing unauthorized access to sensitive information."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.8"
control-question: "Does the organization enforce a limit for consecutive invalid login attempts by a user during an organization-defined time period and automatically locks the account when the maximum number of unsuccessful attempts is exceeded?"
fiiId: "FII-SCF-IAC-0022"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L2-3.1.8 (FII: FII-SCF-IAC-0022). 

### Policy Authoring Instructions:

1. **Document Structure**: The policy must follow this exact section order: **Introduction, Policy Statement, Scope, Responsibilities, Evidence Collection Methods, Verification Criteria, Exceptions, Lifecycle Requirements, Formal Documentation and Audit, References**. Ensure there are **NO References subsections** within the individual policy sections. The **References section must be the final section** of the document.

2. **Policy Content**:
   - Each section should clearly explain the control requirement related to limiting consecutive invalid login attempts and account lockout.
   - Include **MACHINE ATTESTATION** methods for collecting evidence, such as using OSquery for automated monitoring of account lockouts.
   - Specify **HUMAN ATTESTATION** methods where automation is impractical, like requiring managerial approval of user account lockout logs.

3. **SMART Instructions**: Ensure that the policy contains **Specific, Measurable, Actionable, Relevant, and Time-bound (SMART)** instructions for all processes:
   - For each requirement, include a bulleted list of **3-5 operational steps** with a **specific time-bound metric (KPIs/SLAs)** (e.g., "lock account after 5 unsuccessful login attempts within 15 minutes").

4. **Comprehensive Scope Definition**: Explicitly define the scope to cover all relevant environments, including cloud-hosted systems, SaaS applications, and third-party vendor systems related to user authentication.

5. **Detailed Responsibilities**: Clearly define specific **task-level duties (action verbs and frequency)** for roles responsible for enforcing account lockout policies, such as the Compliance Officer and IT Security personnel.

6. **Policy Lifecycle Requirements**: Include a subsection detailing **minimum data retention periods** for evidence (e.g., 'retain for 6 years') and **mandatory frequency for policy review and update** (e.g., 'reviewed at least annually').

7. **Formal Documentation and Audit**: Require **workforce member acknowledgment/attestation** of understanding and compliance, along with comprehensive audit logging for critical actions and formal documentation for exceptions.

8. **Verification Criteria**: Provide clear, measurable criteria for compliance validation, directly tied to the **KPIs/SLAs** defined in the policy.

9. **Markdown Formatting**: Use standard Markdown formatting including headings, bullets, and **bold text** for emphasis.

10. **Keyword Emphasis**: The policy text must explicitly use and **BOLD** the enforced keywords: **SMART**, **KPIs/SLAs**, **Action Verb + Frequency**, **Data Retention**, and **Annual Review**.

11. **Final Section Requirements**: Ensure that the **References section is the FINAL section** of the policy document. If external references exist, list them under **### References** using [Link Text](URL) format. If none exist, output "### References" followed by a single line containing "None". 

Remember, the policy should be robust, clear, and focused on maximizing machine attestability through Surveilr.