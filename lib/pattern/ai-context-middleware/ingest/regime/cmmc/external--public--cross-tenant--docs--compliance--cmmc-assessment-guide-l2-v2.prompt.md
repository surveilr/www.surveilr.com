---
id: dod-cmmc-assessment-guide-l2-v2-2024
title: "DoD CMMC Assessment Guide - Level 2 v2.13"
summary: "Official Department of Defense CMMC Level 2 assessment guidance for Organizations Seeking Assessment (OSAs) and Organizations Seeking Certification (OSCs)"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: ""
  features: ["level-2-assessment", "self-assessment", "certification-assessment", "assessment-methodology", "CUI-protection"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/AssessmentGuideL2v2.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 7
---
# CMMC Assessment Guide Level 2 - Comprehensive Summary

## What is the CMMC Assessment Guide Level 2?

The CMMC (Cybersecurity Maturity Model Certification) Assessment Guide Level 2 is an official Department of Defense document (Version 2.13, September 2024) that provides comprehensive guidance for conducting cybersecurity assessments to protect Controlled Unclassified Information (CUI) in defense contractor environments.

## Key Purpose and Scope

**Primary Purpose:** This guide enables organizations to prepare for and conduct Level 2 cybersecurity assessments required for Department of Defense contracts involving CUI data protection.

## Key CMMC-Specific Terminology and Definitions

**Assessment Types and Pathways:**

- **Level 2 Self-Assessment:** Organization evaluates its own CMMC Level compliance internally
- **Level 2 Certification Assessment:** Third-party assessment conducted by Certified Third-Party Assessment Organizations (C3PAO)
- **POA&M Closeout Assessment:** Follow-up evaluation of previously NOT MET requirements

**CMMC Status Classifications:**

- **Conditional Level 2 (Self/C3PAO):** Temporary certification with approved Plan of Action and Milestones (POA&M) for remediation
- **Final Level 2 (Self/C3PAO):** Full certification meeting all security requirements without outstanding deficiencies

**Specialized Concepts:**

- **CMMC Assessment Scope:** Complete set of all assets in organization's environment assessed against security requirements
- **Enduring Exceptions:** Special circumstances where full compliance isn't feasible (medical devices, test equipment, OT/IoT systems)
- **Temporary Deficiencies:** Conditions where remediation is feasible and documented in operational plans of action
- **Security Protection Data (SPD):** Data used by Security Protection Assets to safeguard the assessed environment
- **External Service Providers (ESPs):** Cloud providers, managed service providers, or cybersecurity-as-a-service providers that can implement requirements on behalf of organizations

**Controlled Unclassified Information (CUI) Categories:**

- **CUI Basic:** Government information requiring safeguarding controls without specific implementation guidance
- **CUI Specified:** Government information with specific required controls for protection and handling

**Regulatory Foundation:** Based on NIST SP 800-171 Revision 2 requirements and codified in 32 CFR § 170.16-170.18.

## Core Security Domains Covered

The guide addresses 110 security requirements across 17 domains:

### Access Control (AC) - 22 requirements

Controls for authorized access, privilege management, remote access, mobile devices, and CUI data flow

### Audit and Accountability (AU) - 9 requirements

System auditing, event logging, audit protection, and accountability mechanisms

### Awareness and Training (AT) - 3 requirements

Role-based security training and insider threat awareness programs

### Configuration Management (CM) - 9 requirements

System baselines, change management, and security configuration enforcement

### Identification and Authentication (IA) - 11 requirements

User identification, multifactor authentication, and password management

### Incident Response (IR) - 3 requirements

Incident handling procedures, reporting, and response testing

### Maintenance (MA) - 6 requirements

System maintenance controls, equipment sanitization, and personnel oversight

### Media Protection (MP) - 9 requirements

Protecting storage media, encryption requirements, and data disposal

### Personnel Security (PS) - 2 requirements

Background screening and personnel action procedures

### Physical Protection (PE) - 6 requirements

Physical access controls, facility monitoring, and visitor management

### Risk Assessment (RA) - 3 requirements

Risk assessment processes, vulnerability scanning, and remediation

### Security Assessment (CA) - 4 requirements

Security control assessment, monitoring, and system security planning

### System and Communications Protection (SC) - 16 requirements

Network security, encryption, boundary protection, and secure communications

### System and Information Integrity (SI) - 7 requirements

Flaw remediation, malicious code protection, and system monitoring

## Assessment Methodology and Procedures

**NIST SP 800-171A Framework Implementation:**
Based on NIST Special Publication 800-171A assessment procedures, each requirement evaluation includes:

- **Assessment Objectives:** Specific determination statements that must be satisfied
- **Assessment Methods:** Three complementary approaches for evidence gathering
- **Assessment Objects:** Four categories of items to be evaluated

**Three-Method Assessment Approach:**

1. **Interview Method:** Process of holding discussions with individuals or groups to facilitate understanding, achieve clarification, or obtain evidence about security practices and implementation
2. **Examine Method:** Process of reviewing, inspecting, observing, studying, or analyzing assessment objects including specifications, mechanisms, and activities
3. **Test Method:** Process of exercising assessment objects under specified conditions to compare actual versus expected behavior and demonstrate functionality

**Four Assessment Object Categories:**

- **Specifications:** Document-based artifacts (policies, procedures, security plans, requirements, architectural designs)
- **Mechanisms:** Specific hardware, software, or firmware safeguards employed within systems
- **Activities:** Protection-related actions involving people (backups, contingency plans, monitoring)
- **Individuals:** People applying the specifications, mechanisms, or activities

**Assessment Findings Framework:**

- **MET:** All applicable assessment objectives satisfied based on evidence (including properly documented Enduring Exceptions and Temporary Deficiencies with operational plans)
- **NOT MET:** One or more objectives not satisfied, requiring remediation or POA&M documentation
- **NOT APPLICABLE (N/A):** Security requirement doesn't apply at time of assessment (equivalent to MET for scoring)

**Critical Assessment Rules:**

- All evidence must be in final form (no drafts or working papers accepted)
- One NOT MET objective results in failure of entire security requirement
- External Service Providers (ESPs) can satisfy requirements if adequate evidence provided
- DoD CIO adjudications for alternative measures must be documented in System Security Plan

## Target Audience and Use Cases

**Primary Users:**

- Defense contractors and subcontractors handling CUI
- Cybersecurity professionals conducting assessments
- C3PAO assessors performing certification evaluations
- Organizations preparing for DoD contract compliance

**Business Impact:**

- Required for DoD contract eligibility involving CUI
- Demonstrates cybersecurity maturity to government customers
- Protects sensitive government information in contractor systems
- Enables participation in defense supply chain

## Compliance Timeline and Requirements

Organizations must achieve either:

- **Conditional Level 2 (C3PAO):** Temporary certification with planned remediation
- **Final Level 2 (C3PAO):** Full certification meeting all requirements

The assessment scope must include all systems that process, store, or transmit CUI within the organization's information system boundary.

## Key Differentiators from Other Security Frameworks

Unlike general cybersecurity frameworks, CMMC Level 2 specifically:

- Focuses on protecting government CUI data
- Requires third-party validation for many contracts
- Integrates supply chain security considerations
- Mandates specific technical controls based on NIST 800-171
- Links cybersecurity compliance directly to contract eligibility

This guide serves as the authoritative resource for understanding, implementing, and assessing cybersecurity controls required for organizations seeking to handle Controlled Unclassified Information in support of Department of Defense missions.
