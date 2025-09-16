---
id: dod-cmmc-levels-determination-brief-2025
title: "CMMC Levels Determination Brief"
summary: "Guidance for identifying the minimum required CMMC level (1, 2, or 3) based on the types of information handled (FCI, CUI, Defense-OIG CUI), including distinctions between self-assessment and certification requirements"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: ""
  features: ["level-determination", "FCI-CUI-criteria", "self-assessment-vs-certification", "defense-OIG-CUI"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/CMMC-LevelsDeterminationBrief.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 15
---
# CMMC Level Determination Criteria and Requirements

## How is the appropriate CMMC level determined for defense contractors?

CMMC (Cybersecurity Maturity Model Certification) level determination follows a systematic decision process based on the type of information handled by defense contractors. The primary determining factor is whether the contractor processes, stores, or transmits Federal Contract Information (FCI) only, or also handles Controlled Unclassified Information (CUI). The level determination directly impacts assessment requirements, with higher levels requiring more stringent certification processes.

**Decision Framework**: The determination process uses a flowchart-based approach that evaluates information types and their classification within government registries to assign the appropriate CMMC level and assessment type.

## CMMC Level 1 Requirements

**Applicable Contractors**: Organizations that process, store, or transmit only Federal Contract Information (FCI) must complete CMMC Level 1 requirements.

**Assessment Type**: Self-assessment conducted annually by the contractor
**Security Requirements**: 15 security requirements specified in FAR clause 52.204-21
**Information Type**: FCI includes information provided by or generated for the government under a contract that is not intended for public release

## CMMC Level 2 Requirements and Determination Criteria

**Primary Trigger**: Contractors or subcontractors who process, store, or transmit Controlled Unclassified Information (CUI) on their information systems must meet CMMC Level 2 requirements at minimum.

**Two Assessment Pathways for Level 2**:

### Level 2 Self-Assessment

- **Required For**: CUI that appears in the National Archives and Records Administration (NARA) CUI Registry but is NOT in the Defense Organizational Index Grouping (OIG)
- **Assessment Method**: Self-assessment conducted by the contractor
- **Frequency**: As determined by contract requirements

### Level 2 Certification

- **Required For**: CUI that appears in both the NARA CUI Registry AND the Defense Organizational Index Grouping (OIG)
- **Assessment Method**: Third-party certification assessment conducted by authorized CMMC Third-Party Assessment Organizations (C3PAOs)
- **Higher Assurance**: Requires external validation of cybersecurity implementation

## CUI Classification and Registry Determination

**NARA CUI Registry**: The authoritative source maintained by the National Archives and Records Administration that catalogs all categories and subcategories of Controlled Unclassified Information across the federal government.

**Defense Organizational Index Grouping (OIG)**: A subset within the NARA CUI Registry specifically identifying CUI categories that are particularly sensitive to Department of Defense operations and mission requirements.

**Multiple Criteria Impact**: When CUI meets multiple classification criteria, the contractor must align to the highest applicable CMMC level requirement.

## Decision Process Flowchart Logic

**Step 1**: Determine if the contractor processes, stores, or transmits CUI

- **No CUI**: CMMC Level 1 (Self-Assessment) for FCI only
- **Yes CUI**: Proceed to Step 2

**Step 2**: Verify if the CUI appears in the NARA CUI Registry and Defense OIG

- **CUI in NARA Registry only**: CMMC Level 2 (Self-Assessment)
- **CUI in both NARA Registry AND Defense OIG**: CMMC Level 2 (Certification)

## Higher CMMC Levels Consideration

**Level 3 Potential**: Information meeting specific criteria may require higher CMMC levels beyond Level 2. When CUI meets multiple sensitivity criteria, contractors must implement controls corresponding to the highest applicable CMMC level.

**Risk-Based Assessment**: The determination considers the sensitivity and criticality of the information to national security and defense operations.

## Implementation Requirements

**Contract Specification**: CMMC level requirements are specified in individual solicitations and contracts based on the information types the contractor will handle.

**System Scope**: The CMMC level applies to the contractor's information systems that will process, store, or transmit the specified government information.

**Compliance Timeline**: Contractors must achieve the required CMMC level before contract award or within specified timeframes outlined in contract terms.

## Key References and Validation

**Authoritative Sources**:

- NARA CUI Registry for definitive CUI categorization
- DoD memoranda specifying CMMC level selection criteria
- Federal Acquisition Regulation (FAR) clause 52.204-21 for Level 1 requirements

**Verification Process**: Contractors should consult the official DoD CMMC documentation and the NARA CUI Registry to accurately determine their required CMMC level based on the specific information types they will handle under contract.

This systematic approach ensures defense contractors implement appropriate cybersecurity measures commensurate with the sensitivity of government information they handle, supporting the overall security of the Defense Industrial Base.
