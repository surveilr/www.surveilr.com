---
id: dod-cmmc-emass-2025
title: "CMMC eMASS"
summary: "Introduction to the CMMC Enterprise Mission Assurance Support Service (eMASS), a tailored DoD system for storing, tracking, and reporting CMMC Level 2 and Level 3 assessment data, including pre-assessment records, results, POA&Ms, appeals, and metrics"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: "2.0"
  features: ["data-repository", "assessment-tracking", "poa-m-tracking", "appeals-management", "metrics-reporting"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/CMMC-eMASS.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 13
---

# CMMC Enterprise Mission Assurance Support Service (eMASS)

## What is CMMC eMASS and what is its primary purpose?

CMMC eMASS (Enterprise Mission Assurance Support Service) is a specialized, tailored version of the Department of Defense's eMASS system designed specifically for managing Cybersecurity Maturity Model Certification (CMMC) Level 2 and Level 3 assessments. Accessible at https://cmmc.emass.apps.mil/, it serves as the authoritative data repository for CMMC assessment information, tracking assessment workflows, Plans of Actions and Milestones (POA&Ms), appeals processes, and CMMC program metrics.

**Core Function**: CMMC eMASS stores and manages assessment data without containing proprietary information such as assessment evidence, ensuring secure handling of certification processes while maintaining comprehensive tracking capabilities.

## Key System Roles and Access Levels

**Government Roles**:
- **CMMC Program Management Office (PMO)**: Full system access with reporting capabilities across all assessment data
- **CMMC PMO Administrator**: System administration including user account creation and access configuration

**Assessment Organization Roles**:
- **CMMC Accreditation Body (AB)**: Uploads authorized C3PAO data, assessor information, and training partner details
- **C3PAO (CMMC Third-Party Assessment Organization)**: Manages Level 2 assessments, uploads pre-assessment data, results, certificates, and tracks appeals for their assessed companies only
- **DIBCAC (Defense Industrial Base Cybersecurity Assessment Center)**: Handles Level 3 assessments with access to all assessment data, reports, and metrics

## Assessment Data Standards and Technical Requirements

**Data Format Standards**:
- **Pre-Assessment Data**: CMMC.PreAssessment.schema.json
- **Assessment Results**: CMMC.AssessmentResults.schema.json
- **Alternative Templates**: CMMC_Level2_PreAssessment_Template.xlsx and CMMC_Level2_AssessmentResults_Template.xlsx

**Technical Integration**: System API enables data transfer to SPRS (Supplier Performance Risk System) for completed assessments, ensuring seamless integration with DoD's broader supplier performance tracking infrastructure.

## Five-Step Assessment Workflow Process

**Step 1**: Create Assessment Record/Package with OSC (Organization Seeking Certification) coordination
**Step 2**: Upload Pre-Assessment planning information using standardized data formats
**Step 3**: Upload Assessment Results after conducting evaluation and internal quality review
**Step 4**: Upload CMMC Certificate following assessment completion
**Step 5**: Upload Assessment Findings Report with detailed documentation

**Automated Scoring**: System automatically calculates scores and determines CMMC Status (Final, Conditional, or No CMMC Status) based on uploaded results.

## Status Types and Validity Periods

**Final Status**: 3-year validity period for assessments meeting all requirements
**Conditional Status**: 180-day validity period requiring POA&M closeout assessment
**No CMMC Status**: Indicates assessment did not meet certification requirements

**Status Management**: CMMC eMASS auto-generates unique identifiers (UIDs), status dates, and expiration dates for all certified assessments.

## POA&M Closeout Assessment Process

Conditional assessments require closeout evaluations using identical data standards and workflows as initial assessments. Successful closeout converts Conditional status to Final status without changing the original status date. Failed closeout results in No CMMC Status designation.

**Flexibility**: Different C3PAOs may conduct POA&M closeout assessments for Level 2 certifications, providing organizational flexibility in assessment completion.

## System Administration and Support

**Official Portal**: https://cmmc.emass.apps.mil/
**Administrator Contact**: osd.pentagon.dod-cio.mbx.cmmc-emass-admin@mail.mil
**Program Inquiries**: osd.pentagon.dod-cio.mbx.cmmc-inquiries@mail.mil
**Documentation**: Comprehensive user job aids, concept of operations guides, and assessment data standards available through the portal

**Security Requirements**: All third-party assessment tools must comply with DoD security requirements and CMMC assessment data standards to ensure system compatibility and data integrity.

This system is essential for defense contractors and assessment organizations participating in the CMMC program, providing the authoritative platform for managing cybersecurity certification processes across the Defense Industrial Base.