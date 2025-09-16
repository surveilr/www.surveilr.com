---
id: dod-cmmc-scoping-guide-l1-v2-2024
title: "DoD CMMC Scoping Guide - Level 1 v2.13"
summary: "Official Department of Defense CMMC Level 1 scoping guidance for Organizations Seeking Assessment (OSAs) conducting self-assessments"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: ""
  features: ["level-1-scoping", "self-assessment", "asset-categorization", "fci-protection", "scope-determination"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/ScopingGuideL1v2.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 4
---
# CMMC Level 1 Scoping Guide

## How do you determine the scope for a CMMC Level 1 self-assessment?

**CMMC Level 1 Scoping** defines which assets within an organization's environment must be assessed against the 15 basic safeguarding requirements for Federal Contract Information (FCI) protection. The scoping process is streamlined for Level 1, requiring no formal documentation but establishing clear boundaries for self-assessment.

### Core Scoping Principle

The fundamental scoping rule for Level 1 assessments is: **All assets that process, store, or transmit Federal Contract Information (FCI) are in scope** unless they qualify as Specialized Assets.

### FCI Asset Activities Definition

**Process**: FCI is actively used by an asset through accessing, entering, editing, generating, manipulating, or printing activities.

**Store**: FCI is inactive or at rest on an asset, including electronic media, system component memory, or physical formats like paper documents.

**Transmit**: FCI is being transferred between assets using physical or digital transport methods (data in transit).

### In-Scope vs Out-of-Scope Assets

**In-Scope Assets**: All systems, devices, and components that process, store, or transmit FCI must be assessed against all 15 Level 1 security requirements per 32 CFR § 170.19(b).

**Out-of-Scope Assets**: Systems and devices that do not handle FCI in any capacity are excluded from the CMMC assessment scope per 32 CFR § 170.19(b)(2).

### Specialized Assets (Automatically Excluded)

Level 1 assessments exclude specific asset categories that cannot be fully secured, as defined in 32 CFR § 170.19(b)(2)(ii):

**Government Furnished Equipment (GFE)**: Government-owned property provided to contractors for contract performance, including spares and maintenance items.

**Internet of Things (IoT/IIoT)**: Interconnected devices with sensing, actuation, and programmability features, including smart building systems like lighting, HVAC, and fire detection.

**Operational Technology (OT)**: Programmable systems controlling physical environments, including industrial control systems, building management systems, SCADA systems, and physical access controls.

**Restricted Information Systems**: Systems configured entirely by government security requirements and used to support contracts, including fielded systems and obsolete systems.

**Test Equipment**: Hardware and IT components specifically used for testing products, system components, and contract deliverables.

### Four-Category Assessment Framework

Organizations must consider these categories when determining scope per 32 CFR § 170.19(b)(3):

**People**: Employees, contractors, vendors, and external service provider personnel who handle FCI.

**Technology**: Servers, client computers, mobile devices, network appliances (firewalls, switches, access points, routers), VoIP devices, applications, virtual machines, and database systems.

**Facilities**: Physical locations including offices, satellite offices, server rooms, datacenters, manufacturing plants, and secured rooms where FCI is processed or stored.

**External Service Providers (ESP)**: Third-party entities providing comprehensive IT or cybersecurity services that handle FCI on the organization's behalf.

### Level 1 Scoping Requirements

**No Documentation Required**: Unlike higher levels, Level 1 self-assessments do not require formal documentation of In-Scope, Out-of-Scope, or Specialized Assets.

**Self-Assessment Focus**: The streamlined approach allows Organizations Seeking Assessment (OSAs) to conduct efficient self-evaluations while ensuring comprehensive FCI protection.

**Assessment Validity**: Scoping remains valid until significant architectural or boundary changes occur (network expansions, mergers, acquisitions). Operational changes within existing boundaries are covered by annual compliance affirmations.

### Practical Scoping Examples

**People Identification** supports requirements like IA.L1-b.1.v (user identification) by determining who needs system access.

**Technology Inventory** informs requirements such as AC.L1-b.1.iii (external system connections) and SC.L1-b.1.x (boundary protection) by mapping network assets and communication paths.

The Level 1 scoping approach prioritizes practical implementation while maintaining focus on FCI protection across the organization's operational environment.
