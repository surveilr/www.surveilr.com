---
id: dod-cmmc-assessment-guide-l1-v2-2024
title: "DoD CMMC Assessment Guide - Level 1 v2.13"
summary: "Official Department of Defense CMMC Level 1 assessment guidance for Organizations Seeking Assessment (OSAs) conducting self-assessments"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: "2.0"
  features: ["level-1-assessment", "self-assessment", "practice-implementation", "evidence-collection", "assessment-process"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/AssessmentGuideL1v2.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 5
---

# CMMC Level 1 Assessment Guide

## How do you conduct a CMMC Level 1 self-assessment and what are the specific requirements?

**CMMC Level 1 Self-Assessment** is a self-conducted evaluation process where Organizations Seeking Assessment (OSAs) determine their compliance with 15 basic safeguarding requirements for Federal Contract Information (FCI) protection, as specified in FAR Clause 52.204-21 and codified in 32 CFR § 170.15.

### Assessment Framework and Methodology
Level 1 self-assessments use **NIST SP 800-171A assessment objectives** modified for FCI rather than CUI, employing three assessment methods:

**Examine Method**: Review, inspect, observe, study, or analyze assessment objects including specifications (policies, procedures, security plans), mechanisms (hardware, software, firmware safeguards), activities (protection-related actions), and individuals.

**Interview Method**: Hold discussions with personnel to facilitate understanding, achieve clarification, or obtain evidence from staff at different organizational levels.

**Test Method**: Exercise assessment objects under specified conditions to compare actual with expected behavior, providing hands-on demonstration of requirement implementation.

### Assessment Findings and Scoring
Level 1 assessments result in three possible findings per 32 CFR § 170.24:

**MET**: All applicable objectives satisfied based on final-form evidence (no drafts or working papers accepted). Includes Enduring Exceptions documented in system security plans and temporary deficiencies with operational plans of action.

**NOT MET**: One or more objectives not satisfied. A single NOT MET assessment objective causes failure of the entire security requirement.

**NOT APPLICABLE (N/A)**: Security requirement doesn't apply at assessment time. Equivalent to MET for scoring purposes.

**Compliance Requirement**: All 15 Level 1 requirements must achieve MET or N/A status for successful assessment completion.

### 15 Level 1 Security Requirements by Domain

**Access Control (AC) - 4 Requirements**:
- AC.L1-b.1.i: Limit system access to authorized users, processes, and devices
- AC.L1-b.1.ii: Limit access to authorized transactions and functions 
- AC.L1-b.1.iii: Verify and control external system connections
- AC.L1-b.1.iv: Control information on publicly accessible systems

**Identification and Authentication (IA) - 2 Requirements**:
- IA.L1-b.1.v: Identify system users, processes, and devices
- IA.L1-b.1.vi: Authenticate user, process, and device identities

**Media Protection (MP) - 1 Requirement**:
- MP.L1-b.1.vii: Sanitize or destroy media containing FCI before disposal/reuse

**Physical Protection (PE) - 2 Requirements**:
- PE.L1-b.1.viii: Limit physical access to authorized individuals
- PE.L1-b.1.ix: Escort visitors, maintain access logs, control physical access devices

**System and Communications Protection (SC) - 2 Requirements**:
- SC.L1-b.1.x: Monitor, control, and protect communications at system boundaries
- SC.L1-b.1.xi: Implement separated subnetworks for publicly accessible components

**System and Information Integrity (SI) - 4 Requirements**:
- SI.L1-b.1.xii: Identify, report, and correct system flaws timely
- SI.L1-b.1.xiii: Provide malicious code protection at appropriate locations
- SI.L1-b.1.xiv: Update malicious code protection when new releases available
- SI.L1-b.1.xv: Perform periodic and real-time malicious code scanning

### Key Assessment Considerations
**Evidence Requirements**: All evidence must be in final form - drafts, working papers, and unofficial policies are unacceptable. Organizations must demonstrate actual implementation, not just documentation.

**External Service Provider (ESP) Compliance**: Requirements may be satisfied through enterprise components or ESPs, including cloud providers, managed service providers, or cybersecurity-as-a-service providers.

**Assessment Flexibility**: Organizations determine appropriate assessment methods and objects to accomplish objectives in the most cost-effective manner with sufficient confidence.

**Scope Definition**: Assessment scope must be defined per 32 CFR § 170.19, covering all assets that process, store, or transmit FCI, excluding Specialized Assets (IoT, IIoT, OT, GFE, Restricted Information Systems, Test Equipment).

### Assessment Deliverables
**SPRS Submission**: Primary result is submission of Level 1 compliance results into the Supplier Performance Risk System.

**Self-Assessment Report**: Contains findings associated with the self-assessment, documenting MET/NOT MET/N/A determinations for each requirement.

**Third-Party Assistance**: Organizations may engage third parties to assist with self-assessment while maintaining self-assessment status (not certification).

### Implementation Examples and Practical Application
Each requirement includes specific implementation examples, such as maintaining authorized user lists (AC.L1-b.1.i), establishing visitor escort procedures (PE.L1-b.1.ix), implementing firewall boundary protection (SC.L1-b.1.x), and configuring automated malware updates (SI.L1-b.1.xiv).

The Level 1 self-assessment process emphasizes practical cybersecurity implementation over extensive documentation, making it accessible to organizations of all sizes while ensuring fundamental FCI protection capabilities are established and maintained.
