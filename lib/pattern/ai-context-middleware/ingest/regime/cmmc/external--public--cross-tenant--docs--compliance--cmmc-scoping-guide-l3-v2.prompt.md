---
id: dod-cmmc-scoping-guide-l3-v2-2024
title: "DoD CMMC Scoping Guide - Level 3 v2.13"
summary: "Official Department of Defense CMMC Level 3 scoping guidance for Organizations Seeking Certification (OSCs) conducting certification assessments"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: ""
  features: ["level-3-scoping", "certification-assessment", "asset-categorization", "scope-determination", "CUI-protection"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/ScopingGuideL3v2.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 8
---
# CMMC Level 3 Scoping Guide

## What is the CMMC Level 3 Scoping Guide?

The CMMC Level 3 Scoping Guide is an official Department of Defense document (Version 2.13, September 2024) that provides comprehensive guidance for Organizations Seeking Certification (OSCs) on defining assessment boundaries and asset categorization for Cybersecurity Maturity Model Certification Level 3 assessments. This guide is specifically designed for defense contractors who handle Controlled Unclassified Information (CUI) and require the highest level of CMMC certification.

## Purpose and Requirements

**Primary Purpose**: Define which assets within an organization's environment will be assessed during a Level 3 CMMC certification assessment conducted by the Defense Industrial Base Cybersecurity Assessment Center (DIBCAC).

**Prerequisites**: Organizations must have a Final Level 2 (C3PAO) CMMC Status for the same assessment scope, with all Level 2 Plan of Action and Milestones (POA&M) items closed before initiating Level 3 assessment.

## Four Critical Asset Categories

### 1. CUI Assets (In-Scope)

- **Definition**: Assets that process, store, or transmit Controlled Unclassified Information
- **Includes**: Previously designated Contractor Risk Managed Assets (CRMAs) from Level 2
- **Assessment**: Limited Level 2 check plus full Level 3 security requirements assessment
- **Requirements**: Document in asset inventory, System Security Plan (SSP), and network diagram

### 2. Security Protection Assets (In-Scope)

- **Definition**: Assets providing security functions regardless of CUI processing capability
- **Examples**: SIEM solutions, VPN services, cloud security tools, security consultants, SOCs
- **Assessment**: Level 3 requirements relevant to security capabilities provided
- **Special Data**: Security Protection Data (logs, configurations, vulnerability data) requires protection

### 3. Specialized Assets (In-Scope)

- **Types**: IoT/IIoT devices, Operational Technology (OT), Government Furnished Equipment (GFE), Restricted Information Systems, Test Equipment
- **Limitations**: May be unable to fully implement security controls
- **Accommodation**: Intermediary devices (proxies, boundary devices) permitted to meet requirements
- **Assessment**: All Level 3 requirements unless physically/logically isolated

### 4. Out-of-Scope Assets (Excluded)

- **Definition**: Cannot process, store, or transmit CUI and provide no security protections
- **Requirements**: Must justify inability to handle CUI; no assessment requirements
- **Note**: VDI clients configured for keyboard/video/mouse only are considered out-of-scope

## External Service Provider (ESP) Considerations

**Critical Distinction**: ESPs are categorized as either Cloud Service Providers (CSPs) or non-CSPs:

- **CSPs with CUI**: Must meet FedRAMP requirements (DFARS 252.204-7012)
- **Non-CSPs with CUI**: Require CMMC assessment as part of OSC's scope
- **ESPs without CUI**: Services included in OSC assessment scope but ESP not separately assessed

**Documentation Requirements**: Customer Responsibility Matrix (CRM) and service descriptions must clearly delineate security responsibilities between OSC and ESP.

## Key Compliance Requirements

1. **Asset Inventory**: All in-scope assets must be documented
2. **System Security Plan (SSP)**: Asset treatment and ESP relationships documented
3. **Network Diagram**: Visual representation of CMMC Assessment Scope
4. **Boundary Definition**: Clear logical and physical separation of in-scope vs. out-of-scope assets

## Assessment Validity and Scope Changes

- **Scope Stability**: Assessments valid for defined scope until significant architectural changes
- **Scope Changes Requiring New Assessment**: Network expansions, mergers, acquisitions
- **Operational Changes**: Adding/removing resources within existing boundary covered by annual compliance affirmations

## Regulatory Foundation

This guidance implements requirements from 32 CFR § 170.19 and supports DoD's CMMC Program for protecting CUI in the Defense Industrial Base. The document carries Distribution Statement A (approved for public release, unlimited distribution) and serves as official DoD policy guidance for Level 3 CMMC scoping decisions.
