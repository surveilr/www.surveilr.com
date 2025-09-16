---
id: dod-cmmc-hashing-guide-v2-2024
title: "DoD CMMC Artifact Hashing Tool User Guide - v2.13"
summary: "Guidance for using the CMMC Artifact Hashing Tool to generate cryptographic references for evidence artifacts during CMMC assessments"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: "2.0"
  features: ["artifact-hashing", "evidence-integrity", "assessment-support", "sha-256-tool"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/HashingGuidev2.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 10
---

# CMMC Artifact Hashing Guide

## What is the CMMC Artifact Hashing Tool?

The CMMC Artifact Hashing Tool is an official Department of Defense PowerShell script (Version 2.13, September 2024) designed to generate cryptographic hashes of assessment artifacts collected during CMMC certification assessments. This tool ensures the integrity and authenticity of evidence used in CMMC assessments while protecting proprietary organizational information by allowing artifacts to remain with the Organization Seeking Assessment (OSA).

## Purpose and Assessment Integration

**Assessment Artifact Protection**: During CMMC assessments, assessment teams collect objective evidence through three methods: examination of artifacts, affirmations through interviews, and observations of actions. Because these artifacts often contain proprietary information, they cannot be retained off-site by assessors.

**Integrity Verification Requirement**: Per 32 CFR § 170.17 and 32 CFR § 170.18, a cryptographic reference (hash) must be generated for each artifact used in assessments. This allows future integrity verification without compromising confidentiality.

**Mandatory Usage Scope**: Hashing is required only for formal assessments conducted by CMMC Third-Party Assessment Organizations (C3PAOs) and DCMA Defense Industrial Base Cybersecurity Assessment Center (DIBCAC). Self-assessments do not require artifact hashing.

## Technical Specifications and Requirements

**Cryptographic Algorithm**: Uses SHA-256 hashing algorithm to generate unique fingerprints for each assessment artifact.

**System Compatibility**: 
- Requires Microsoft PowerShell (available for Windows, Linux, and macOS)
- Tested on Windows 11 (23H2), Windows 10 (1904), Linux (Ubuntu 20.04), and macOS (10.15.7)
- May require administrator permissions to execute PowerShell scripts

**Dual-Hash Architecture**: 
1. **Primary Hash**: Generates SHA-256 hash for each individual artifact file
2. **Integrity Hash**: Creates a hash of the complete artifact list to protect the integrity of the entire evidence collection

## Tool Operation Process

**File Organization Requirements**: Assessment artifacts must be consolidated into a central location, either as a single root directory or organized in subdirectories. The tool can accommodate both flat and hierarchical file structures.

**Generated Output Files**:
- **CMMCAssessmentArtifacts.log**: Contains algorithm type, hash value, and file path for each artifact
- **CMMCAssessmentLogHash.log**: Contains single hash value of the artifacts log file

**Command Execution**:
```
Windows: powershell -ExecutionPolicy ByPass .\ArtifactHash.ps1 -ArtifactRootDirectory .\ -ArtifactOutputDirectory .\
Linux/macOS: pwsh -ExecutionPolicy ByPass ./ArtifactHash.ps1 -ArtifactRootDirectory ./ -ArtifactOutputDirectory ./
```

## Integration with CMMC Assessment Workflow

**Assessment Planning Phase**: OSA and assessment team jointly determine secure artifact storage location accessible only to those with need-to-know.

**Evidence Collection Phase**: Artifacts gathered during interviews, examinations, and observations are consolidated into the designated central location.

**Hash Generation Phase**: After all assessment activities conclude, OSA runs the hashing tool on collected artifacts.

**Record Retention**: Both OSA and assessor retain copies of the hash files. OSA must maintain original artifacts for six (6) years from assessment date.

**eMASS Integration**: Hash outputs are entered into specific data fields in the CMMC instantiation of eMASS (Enterprise Mission Assurance Support Service):
- **Hashed Data List field**: Filename from CMMCAssessmentArtifacts.log
- **Hash Value field**: Hash string from CMMCAssessmentLogHash.log

## Security and Confidentiality Considerations

**Hashing vs. Encryption Distinction**: The tool provides integrity verification but does not encrypt or provide confidentiality protection for artifacts. Organizations must implement separate encryption mechanisms for confidentiality protection.

**Data Protection Requirements**: Organizations must consider appropriate data protection requirements when selecting artifact archival locations, as the hashing process does not secure the actual content.

**Access Control**: Artifact storage locations should be secured and accessible only to personnel with legitimate need-to-know, given the potentially sensitive or proprietary nature of assessment evidence.

## Operational Parameters and Flexibility

**Three Configurable Parameters**:
1. **ExecutionPolicy**: Recommended "ByPass" value to override PowerShell execution restrictions
2. **ArtifactRootDirectory**: Specifies location of assessment artifacts (supports Windows paths, UNC paths, or current directory)
3. **ArtifactOutputDirectory**: Defines where hash log files will be generated

**File Naming Standards**: Recommends standardized naming patterns or grouping by CMMC requirement to facilitate future audits or retrospective reviews.

**Recursive Processing**: Tool automatically processes all files within specified directory structure, including subdirectories, ensuring comprehensive coverage of assessment evidence.

## Compliance and Regulatory Context

This hashing process supports the CMMC Program's evidence preservation requirements while balancing the need to protect organizational intellectual property. The tool ensures compliance with federal regulations governing CMMC assessments while enabling organizations to maintain control over their sensitive information throughout the six-year retention period.

The hashing methodology provides a cryptographically sound approach to evidence integrity verification that supports potential future audits or reviews without compromising the confidentiality of proprietary organizational data.
