---
id: dod-cmmc-sprs-2025
title: "CMMC - SPRS"
summary: "Overview and guidance on using the DoD SPRS (Supplier Performance Risk System) to report and retrieve CMMC and NIST SP 800-171 assessment results"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: ""
  features: ["supplier-performance-risk-system", "sp rs-access", "assessment-reporting", "nist-sp-800-171", "CMMC-self-assessment"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/CMMC-SPRS.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 12
---
# CMMC Self-Assessments in SPRS System

## What is the CMMC-SPRS system and how does it work?

The Supplier Performance Risk System (SPRS) is the Department of Defense's authoritative database for evaluating contractor cybersecurity compliance and performance risks. Established in 2018 and managed by DISA, SPRS serves as the central repository for Cybersecurity Maturity Model Certification (CMMC) self-assessments that defense contractors must complete to demonstrate compliance with cybersecurity requirements.

**Core Purpose**: SPRS enables defense contractors to submit and manage CMMC Level 1 and Level 2 self-assessments, which are mandatory for companies handling Controlled Unclassified Information (CUI) or Federal Contract Information (FCI) under DoD contracts.

## Key Components and Capabilities

**SPRS tracks multiple risk categories**:

- Vendor performance metrics (quality, delivery, compliance)
- Cybersecurity assessments (NIST SP 800-171, CMMC)
- Supply chain risks and corporate hierarchies
- Price and item risks including counterfeit detection
- Vendor compliance status and threat mitigation

**CMMC Self-Assessment Types**:

- **Level 1**: Basic safeguarding of Federal Contract Information (FCI)
- **Level 2**: Enhanced protection of Controlled Unclassified Information (CUI) with detailed objective-level compliance tracking

## Assessment Process Workflow

**Prerequisites**:

1. Register in System for Award Management (SAM.gov)
2. Obtain Unique Entity Identifier (UEI) and CAGE codes
3. Access Procurement Integrated Enterprise Environment (PIEE)
4. Obtain "SPRS Cyber Vendor" user role permissions

**Assessment Steps**:

1. Create System Security Plan (SSP) using DPCAP methodology
2. Conduct NIST SP 800-171 basic assessment
3. Enter assessment results in SPRS portal
4. Submit to designated Affirming Official (AO)
5. AO reviews and affirms assessment completion
6. System generates assessment UID and expiration date

## Technical Implementation Details

**User Access**: Single sign-on through PIEE (piee.eb.mil) with role-based permissions
**Assessment Scope Options**: Enterprise-wide or specific enclave configurations
**Compliance Tracking**: Detailed objective-level scoring for Level 2 assessments
**Data Integration**: Connects with SAM, CAGE.mil, and WAWF systems

## Key Requirements and Compliance

- **FAR 52.204-21 compliance** verification required
- **Assessment validity period** with expiration tracking
- **Affirming Official process** ensures accountability and accuracy
- **CAGE hierarchy management** for complex organizational structures
- **Progress tracking** through requirement families and individual objectives

## Support Resources

**Official Website**: https://www.sprs.csd.disa.mil
**Help Desk**: nslcports-helpdesk@us.navy.mil
**Access Portal**: https://piee.eb.mil
**Documentation**: Comprehensive user guides, quick reference materials, and tutorial videos available

This system is critical for defense contractors seeking to maintain eligibility for DoD contracts requiring cybersecurity compliance, serving as both a compliance verification tool and a comprehensive supplier risk management platform.
