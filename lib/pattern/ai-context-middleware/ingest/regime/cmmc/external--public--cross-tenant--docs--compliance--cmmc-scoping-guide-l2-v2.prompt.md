---
id: dod-cmmc-scoping-guide-l2-v2-2024
title: "DoD CMMC Scoping Guide - Level 2 v2.13"
summary: "Official Department of Defense CMMC Level 2 scoping guidance for Organizations Seeking Assessment (OSAs) and Organizations Seeking Certification (OSCs)"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: "2.0"
  features: ["level-2-scoping", "self-assessment", "certification-assessment", "asset-categorization", "scope-determination"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/ScopingGuideL2v2.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 6
---

# CMMC Level 2 Scoping Guide

## How do you determine the scope for CMMC Level 2 self-assessments and certification assessments?

**CMMC Level 2 Scoping** establishes assessment boundaries for the 110 security requirements protecting Controlled Unclassified Information (CUI) per 32 CFR § 170.19(c). Unlike Level 1's simple FCI-based scoping, Level 2 uses a sophisticated five-category asset classification system that determines assessment requirements and depth.

### Five-Category Asset Classification Framework

**CUI Assets**: Systems that process, store, or transmit CUI through accessing, entering, editing, generating, manipulating, printing (process); storing on electronic media, system memory, or physical formats (store); or transferring between assets via physical or digital methods (transmit). **Assessment**: Full evaluation against all 110 Level 2 security requirements.

**Security Protection Assets**: Systems providing security functions or capabilities within the CMMC Assessment Scope, including cloud-based security solutions, SIEM systems, VPN services, SOCs, managed service provider personnel, and enterprise network administrators. **Assessment**: Evaluated against Level 2 requirements relevant to capabilities provided.

**Contractor Risk Managed Assets (CRMAs)**: Systems capable of, but not intended to, handle CUI due to implemented security policies, procedures, and practices. Not required to be physically or logically separated from CUI assets. **Assessment**: SSP documentation review; if insufficiently documented or findings raise questions, limited compliance checks conducted (cannot materially increase assessment duration or cost).

**Specialized Assets**: Systems that can process, store, or transmit CUI but cannot be fully secured, including IoT devices, IIoT systems, Operational Technology (OT), SCADA systems, Government Furnished Equipment (GFE), Restricted Information Systems, and Test Equipment. **Assessment**: SSP documentation review only; no technical security requirement assessment.

**Out-of-Scope Assets**: Systems that cannot process, store, or transmit CUI and provide no security protections for CUI assets. Must be physically or logically separated from CUI assets. **Assessment**: None (excluded from scope entirely).

### Required Documentation and Preparation
**Asset Inventory**: All in-scope assets (CUI, Security Protection, CRMA, Specialized) must be documented in comprehensive inventory.

**System Security Plan (SSP)**: Required documentation of asset treatment, security controls implementation, risk-based policies for CRMAs and Specialized Assets, and enterprise security architecture.

**Network Diagram**: Visual representation of CMMC Assessment Scope showing all in-scope assets and security boundaries to facilitate pre-assessment scoping discussions.

### Physical and Logical Separation Concepts
**Logical Separation**: Prevents data transfer between physically connected assets through non-physical means (firewalls, routers, VPNs, VLANs). Enables Out-of-Scope Asset classification.

**Physical Separation**: No wired or wireless connections between assets; data transfer only through manual methods (USB drives). Provides strongest separation assurance.

**Separation Benefits**: Effective separation per NIST SP 800-171 Rev 2 guidance can limit CMMC Assessment Scope by isolating CUI-handling components in separate security domains.

### External Service Provider (ESP) Considerations
**ESP Scope Criteria**: ESPs enter assessment scope when CUI or Security Protection Data resides on their assets per 32 CFR § 170.19(c)(2).

**Cloud Service Provider (CSP) Requirements**: 
- ESPs storing/processing/transmitting CUI must meet FedRAMP requirements per DFARS 252.204-7012
- ESPs not handling CUI have no FedRAMP requirement but services remain in OSA assessment scope

**Documentation Requirements**: ESP relationships, services, and responsibilities must be documented in SSP and Customer Responsibility Matrix (CRM) detailing security requirement allocation between OSA and ESP.

**Assessment Approach**: ESP portions providing services to OSA are assessed as part of OSA's CMMC evaluation; ESPs may voluntarily request independent C3PAO assessment.

### Assessment Type Differences
**Self-Assessment (OSA)**: Organization evaluates own systems per 32 CFR § 170.16 using identical security requirements as certification assessment.

**Certification Assessment (OSC)**: Independent evaluation by C3PAO per 32 CFR § 170.17 resulting in CMMC certification and official status recognition.

**Level 3 Preparation**: Organizations seeking Level 3 must achieve Final Level 2 (C3PAO) status and close all POA&Ms before initiating Level 3 assessment. CRMAs in Level 2 scope become CUI Assets in Level 3 scope.

### Scope Boundaries and Changes
**Assessment Validity**: Scope remains valid until significant architectural or boundary changes occur (network expansions, mergers, acquisitions).

**Operational Changes**: Adding/subtracting resources within existing boundaries following established SSP covered by annual compliance affirmations rather than new assessments.

**Enterprise vs. Enclave Implementation**: Security requirements may be satisfied enterprise-wide or within specific enclaves. OSAs determine inheritance relationships while ensuring all requirements achieve MET status.

### Use Case Scenarios
**FCI/CUI Co-location**: Level 2 assessment satisfies Level 1 requirements for same scope; Level 2 security implementations address Level 1 assessment objectives.

**FCI/CUI Separation**: Independent assessments required when FCI and CUI exist in separate environments with distinct security implementations.

**Security Protection Data (SPD)**: Logs, configuration data, and security-relevant information created by or used by Security Protection Assets; includes hot storage (immediate access) and cold storage (archived) considerations.

The Level 2 scoping framework balances comprehensive CUI protection with practical implementation flexibility, enabling organizations to align CMMC boundaries with business architecture while maintaining regulatory compliance.
