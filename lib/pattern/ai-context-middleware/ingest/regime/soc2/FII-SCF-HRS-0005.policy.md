---
title: "Communication of Core Values and Employee Handbook"
weight: 10
description: "This policy ensures that the organization's core values are consistently communicated to all personnel, supporting a compliant and ethical culture in alignment with SOC 2 Trust Services Criteria.."
publishDate: "2025-09-08"
publishBy: "Compliance Automation Team"
classification: "Confidential"
documentVersion: "v1.0"
documentType: "Policy"
approvedBy: "Chief Compliance Officer"
category: ["SOC2", "Security", "Asset Management"]
satisfies: ["FII-SCF-HRS-0005"]
control-question: "Are core values communicated from executive management to personnel through policies and the employee handbook??"
control-id: CC1-0001
control-domain: "Common Criteria Related to Control Environment"
SCF-control: "CC1-0001"
merge-group: "regime-soc2-cc1-0001"
order: 2

---

# Policy on Communication of Core Values and Employee Handbook

## 1. Introduction

This policy outlines the commitment of **Surveilr** to effectively communicate its core values, ethical principles, and key policies to all employees. The objective is to ensure that all personnel understand their responsibilities and the company's expectations regarding ethical conduct and business practices, as documented in the official employee handbook.

## 2\. Policy Statement

All **Surveilr** personnel, including new hires and contractors, shall receive and acknowledge the company's core values and the official employee handbook. This communication shall be initiated by executive management and supported by the Human Resources (HR) department. The policy and handbook will be made available in a centrally accessible location, and acknowledgment of receipt will be recorded for audit purposes.

## 3\. Scope

This policy applies to all full-time and part-time employees, contractors, temporary staff, and interns of **Surveilr**. The requirements herein extend to all business units and geographic locations.

## 4\. Responsibilities

  * **Executive Management:** Responsible for defining and championing the core values and ensuring their communication is a priority.
  * **Human Resources (HR):** Responsible for the distribution of the employee handbook and for tracking and maintaining records of employee acknowledgment. This includes ensuring the handbook is accessible to all personnel and updated as necessary.
  * **Managers:** Responsible for reinforcing core values and handbook policies within their respective teams.
  * **All Personnel:** Responsible for reviewing and acknowledging their understanding of the core values and the employee handbook.

## 5\. Evidence Collection Methods

### 5.1. Machine Attestation

Automated evidence will be collected to verify the availability and distribution of the employee handbook.

  * **Availability of Documents:** An automated script or API integration will regularly check the designated internal document repository (e.g., SharePoint, Confluence, Google Drive) to verify that the most current version of the employee handbook is present and accessible to all employees. The script will ingest a report of the document's metadata (e.g., file name, last modified date, and access permissions) into **Surveilr**.
  * **Confirmation of Distribution:** **Surveilr**'s API integration with the HR Information System (HRIS) will collect records of new employee onboarding tasks. This integration will verify that the "Review Employee Handbook" task is a mandatory step in the new hire checklist. Evidence will include confirmation that the task exists and is marked as complete for each new hire profile.

### 5.2. Human Attestation

Where machine attestation is not feasible, specific human actions and artifacts are required to confirm compliance.

  * **Employee Acknowledgment:** The primary method for documenting acknowledgment is a digital or physical signed form. During the onboarding process, each new employee must digitally sign a statement of acknowledgment in the HRIS system, confirming they have received, reviewed, and understood the employee handbook. The HRIS will store the signed acknowledgment record.
  * **Review of Acknowledgment Records:** The HR Manager will conduct a semi-annual review of all new hire records to confirm that a signed acknowledgment for the employee handbook is on file for all personnel hired within the review period.
  * **Ingestion into Surveilr:** The signed acknowledgment records, whether physical scans or digital files, will be uploaded by the HR Manager to **Surveilr**'s secure evidence vault. The upload will be tagged with specific metadata, including `reviewer_name`, `attestation_date`, `employee_name`, and `document_type: employee__handbook_acknowledgment`. This ensures the artifacts are searchable and auditable within **Surveilr**.

## 6\. Verification Criteria

  * **Machine Verification:** **Surveilr** will automatically cross-reference the `employee_handbook` document in the repository with the `Review Employee Handbook` task completion records in the HRIS. A successful verification requires that a document exists and that each new hire has a corresponding completed task record.
  * **Human Verification:** The semi-annual review by the HR Manager must result in a signed attestation report. This report will confirm that all new hires have a verifiable, signed acknowledgment on file. The report will be stored in **Surveilr**, and its metadata will serve as evidence of the manual review process.

## 7\. Exceptions

Any exceptions to this policy, such as an inability to provide a digital signature due to technical issues, must be documented and approved by the HR Manager and the CISO. The documentation for the exception and its resolution must be stored in **Surveilr**.

### *References*

  * [AICPA Trust Services Criteria](https://www.google.com/search?q=https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/aicpa-trust-services-criteria.html)
  * [Surveilr Internal Onboarding Checklist - New Hires](https://www.google.com/search?q=https://internal.surveilr.com/docs/onboarding-checklist)