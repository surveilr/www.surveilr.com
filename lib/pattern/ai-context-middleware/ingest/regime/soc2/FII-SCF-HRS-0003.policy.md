---
title: "Organizational Structure Documentation and Review Policy"
weight: 10
description: "This policy outlines the requirements for documenting and maintaining an up-to-date organizational structure, including management reporting lines, to satisfy SOC2 CC1-0002."
publishDate: "2025-09-15"
publishBy: "Compliance Automation Team"
classification: "Confidential"
documentVersion: "v1.0"
documentType: "Policy"
approvedBy: "Chief Compliance Officer"
category: ["Policy", "Human Resources", "Organizational Structure"]
satisfies: ["FII-SCF-HRS-0003"]
control-question: "Are core values communicated from executive management to personnel through policies and the employee handbook??"
control-id: CC1-0002
control-domain: "Common Criteria Related to Control Environment"
SCF-control: "CC1-0002"
merge-group: "regime-soc2-cc1-0002"
order: 2

---

```yaml
title: Organizational Structure and Reporting Lines Policy
weight: 100
description: Defines how the organization maintains, verifies, and approves its organizational structure and reporting lines.
publishDate: 2025-09-17
publishBy: Cybersecurity Compliance Team
classification: Confidential
documentVersion: 1.0
documentType: Policy
approvedBy: Chief Compliance Officer
category: ['Organizational Structure']
satisfies: ['FII-SCF-HRS-0003']
merge-group: policy-documents
order: 100
```

# Organizational Structure and Reporting Lines Policy

## Introduction

This policy establishes requirements for maintaining and verifying the organizational structure and reporting lines. It ensures that reporting hierarchies are accurate, up-to-date, and consistently applied across systems to support operational clarity, accountability, and compliance with SOC 2 requirements.

## Policy Statement

The organization must define, maintain, and regularly validate a formal organizational structure, including reporting lines. This structure must be accessible, approved by management, and kept consistent across relevant systems (e.g., HRIS, Active Directory).

## Scope

This policy applies to:

* All departments, business units, and subsidiaries.
* All employees, contractors, and personnel with defined reporting relationships.
* All systems maintaining organizational structure data (e.g., HRIS, Identity Providers).

## Responsibilities

* **HR Department**: Maintain accurate organizational chart and reporting line data in the HRIS.
* **IT Department**: Ensure synchronization of organizational data across identity and directory services.
* **Compliance Team**: Facilitate reviews, evidence collection, and ensure timely attestation.
* **Executive Leadership**: Approve organizational chart annually or upon major structural changes.

## Evidence Collection Methods

### Machine Attestation

* **Existence and Timestamp Validation**:

  * Verify the organizational chart's presence via API integration with HRIS (e.g., Workday, BambooHR).
  * Query metadata for `lastModifiedDate` and ensure updates occurred within the past 365 days.

* **Reporting Line Consistency**:

  * Use API calls to fetch employee-manager relationships from HRIS.
  * Cross-reference with directory services (e.g., Active Directory/LDAP) to ensure manager attributes align.
  * Alert on any user accounts lacking a valid manager assignment.

* **Title and Hierarchy Validation**:

  * Confirm job titles and roles match predefined schemas.
  * Validate that direct reports do not exceed logical thresholds (e.g., no more than 20 direct reports unless exempted).

* **Organizational Unit Mapping**:

  * Validate that each employee belongs to a defined organizational unit within HRIS.
  * Check for orphaned units or inactive managers.

### Human Attestation

* **Annual Organizational Chart Approval**:

  * Executive Leadership must review and formally approve the organizational chart annually.
  * Approved version must be exported as PDF and signed by the Chief Information Officer (CIO) or designated executive.
  * The signed PDF is uploaded to **Surveilr** with metadata:

    * `reviewer_name`: Full name of the signing executive.
    * `review_date`: Date of approval.
    * `approval_status`: Confirmed or Rejected.

* **Quarterly Accuracy Attestation**:

  * Department heads submit a signed quarterly statement confirming the accuracy of their teams’ reporting lines.
  * Artifacts are uploaded to **Surveilr** in PDF format with the following metadata:

    * `department_name`
    * `attester_name`
    * `attestation_date`
    * `confirmation_statement`: Yes/No

* **Exception Documentation**:

  * Any deviations from standard reporting structures must be documented and approved by HR and Compliance.
  * Upload exception memos as PDFs with metadata:

    * `exception_type`
    * `approved_by`
    * `justification`
    * `effective_date`

## Verification Criteria

Compliance is met when:

* A current organizational chart exists in the HRIS with a modification date within the last 12 months.
* All employees have a valid manager assigned in both HRIS and identity systems.
* A signed PDF of the approved org chart is stored in **Surveilr** with complete metadata.
* Quarterly departmental attestations are collected and archived.
* All exceptions are documented and approved.

## Exceptions

Requests for exceptions must be submitted to the Compliance Team in writing. All approved exceptions must be documented in **Surveilr** with proper justification, approval, and expiration date.

### *References*

* SOC 2 Trust Services Criteria – CC2.0: Communication and Information
* FII-SCF-HRS-0003: Human Resource Structure Control
* [Workday API Documentation](https://community.workday.com)
* [BambooHR API Documentation](https://documentation.bamboohr.com)
