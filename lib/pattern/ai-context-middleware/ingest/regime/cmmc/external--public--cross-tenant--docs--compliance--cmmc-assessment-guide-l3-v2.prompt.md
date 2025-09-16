---
id: dod-cmmc-assessment-guide-l3-v2-2024
title: "DoD CMMC Assessment Guide - Level 3 v2.13"
summary: "Official Department of Defense CMMC Level 3 assessment guidance for Organizations Seeking Certification (OSCs) conducting certification assessments"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: ""
  features: ["level-3-assessment", "certification-assessment", "enhanced-security-requirements", "assessment-methodology", "CUI-protection"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/AssessmentGuideL3v2.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 9
---
# CMMC Level 3 Assessment Guide

## What is the CMMC Level 3 Assessment Guide?

The CMMC Level 3 Assessment Guide is an official Department of Defense document (Version 2.13, September 2024) that provides comprehensive guidance for conducting Level 3 certification assessments under the Cybersecurity Maturity Model Certification (CMMC) Program. This guide is designed for assessors, Organizations Seeking Certification (OSCs), and cybersecurity professionals involved in the most stringent level of CMMC certification, which addresses protection against Advanced Persistent Threats (APTs).

## Assessment Authority and Prerequisites

**Exclusive Assessment Authority**: Level 3 certification assessments are conducted exclusively by the DCMA Defense Industrial Base Cybersecurity Assessment Center (DIBCAC), not by third-party assessment organizations (C3PAOs).

**Mandatory Prerequisite**: Organizations must first achieve a "Final Level 2 (C3PAO)" CMMC Status for all applicable information systems within the same CMMC Assessment Scope before proceeding to Level 3 assessment.

**Self-Assessment Limitation**: While organizations may use this guide for internal self-assessments (such as preparation for annual affirmations), only DIBCAC assessment results are accepted for official Level 3 certification.

## Level 3 Security Requirements Framework

**Foundation Standards**: Level 3 consists of 24 selected security requirements derived from NIST Special Publication 800-172 (Enhanced Security Requirements for Protecting CUI), building upon the NIST SP 800-171 requirements established at Level 2.

**Enhanced Protection Focus**: Level 3 provides additional protections against Advanced Persistent Threats and increased assurance for protecting Controlled Unclassified Information in multi-tier supply chain environments.

### Core Security Domains and Key Requirements

**Access Control (AC)**: 2 requirements focusing on organizationally controlled assets and secured information transfer between security domains.

**Awareness and Training (AT)**: 2 requirements emphasizing advanced threat awareness training and practical exercises tailored by user roles.

**Configuration Management (CM)**: 3 requirements covering authoritative repositories, automated detection/remediation of misconfigurations, and automated inventory management.

**Identification and Authentication (IA)**: 2 requirements for bidirectional authentication and blocking untrusted assets from organizational systems.

**Incident Response (IR)**: 2 requirements mandating 24/7 Security Operations Center capability and deployable Cyber Incident Response Team within 24 hours.

**Risk Assessment (RA)**: 7 requirements covering threat-informed risk assessment, threat hunting, advanced risk identification, security solution rationale/effectiveness, and supply chain risk management.

**Security Assessment (CA)**: 1 requirement for annual penetration testing using automated tools and subject matter experts.

**System and Communications Protection (SC)**: 1 requirement for employing physical or logical isolation techniques.

**System and Information Integrity (SI)**: 3 requirements addressing integrity verification, specialized asset security, and threat-guided intrusion detection.

**Personnel Security (PS)**: 1 requirement ensuring system protection when adverse information develops about personnel with CUI access.

## Assessment Methodology and Criteria

**NIST SP 800-172A Foundation**: Assessment procedures leverage NIST SP 800-172A methodology, incorporating assessment objectives, methods, and objects for each requirement.

**Three Assessment Methods**:

1. **Examine**: Reviewing specifications, mechanisms, and activities through documentation and demonstrations
2. **Interview**: Conducting discussions with organizational personnel at various levels
3. **Test**: Exercising assessment objects under specified conditions to verify actual versus expected behavior

**Assessment Findings**: Each requirement receives one of three findings:

- **MET**: All applicable assessment objectives satisfied with adequate evidence
- **NOT MET**: One or more objectives not satisfied (results in overall requirement failure)
- **NOT APPLICABLE**: Requirement does not apply to the current assessment scope

## Specialized Requirements and Considerations

**Organization-Defined Parameters (ODPs)**: Selected requirements contain DoD-specified parameters that customize security requirements, with additional organizational flexibility where needed.

**External Service Provider Integration**: Comprehensive guidance for incorporating ESP capabilities into assessments, including cloud service providers and managed security service providers.

**Specialized Asset Handling**: Specific requirements for Internet of Things (IoT), Industrial IoT (IIoT), Operational Technology (OT), Government Furnished Equipment (GFE), and test equipment integration.

**Enduring Exceptions**: Recognition that some specialized assets may have documented limitations preventing full compliance, requiring alternative security measures and documentation in the System Security Plan.

## Critical Assessment Documentation

**System Security Plan (SSP)**: Central document linking security requirements to implemented controls and solutions, with specific emphasis on risk-based security solution selection and rationale.

**Evidence Requirements**: All evidence must be in final form (not drafts or working papers) with clear traceability to assessment objectives.

**Threat Intelligence Integration**: Requirements mandate use of threat intelligence from open, commercial, and DoD-provided sources to inform security architectures, monitoring, and response activities.

## Advanced Security Capabilities

**24/7 Security Operations**: Mandatory Security Operations Center with continuous monitoring capability, including remote/on-call staff arrangements.

**Threat Hunting Program**: Ongoing aperiodic cyber threat hunting activities to search for indicators of compromise and detect threats that evade existing controls.

**Advanced Automation**: Employment of artificial intelligence, machine learning, and advanced analytics to support risk prediction and identification.

**Supply Chain Risk Management**: Comprehensive assessment, response, and monitoring of supply chain risks with documented management plans updated annually or upon threat intelligence receipt.

## Regulatory and Compliance Context

This guide implements requirements from 32 CFR § 170.18 and supports the DoD CMMC Program's mission to protect Controlled Unclassified Information in the Defense Industrial Base. The assessment process ensures organizations demonstrate capabilities commensurate with Advanced Persistent Threat risk levels while maintaining operational effectiveness in supporting DoD missions and contracts.
