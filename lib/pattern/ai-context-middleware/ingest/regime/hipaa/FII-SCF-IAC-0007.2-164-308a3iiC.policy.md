---
title: "HIPAA Access Termination - Policy"
weight: 1
description: "Policy document for HIPAA control 164.308(a)(3)(ii)(C)"
publishDate: "2025-09-22"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "164.308(a)(3)(ii)(C)"
control-question: "Have you implemented procedures for terminating access to EPHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section? (A)"
fiiId: "FII-SCF-IAC-0007.2"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

# Access Termination Policy

## Introduction
The purpose of this policy is to define the procedures for terminating access to Electronic Protected Health Information (EPHI) when an employee leaves the organization or when access is no longer needed. This ensures compliance with the HIPAA regulation 164.308(a)(3)(ii)(C) and protects sensitive health information from unauthorized access.

## Policy Statement
All access to EPHI must be terminated promptly when an employee leaves the organization or when their access is no longer required. This includes access to systems, applications, and physical spaces where EPHI is stored or processed.

## Scope
This policy applies to all employees, contractors, and third-party service providers who have been granted access to EPHI. It encompasses all systems and applications used to store, process, or transmit EPHI.

## Responsibilities
- **Human Resources (HR)**: Responsible for notifying IT of employee terminations and providing necessary documentation.
- **IT Department**: Responsible for executing access termination procedures and maintaining records of terminated access.
- **Managers**: Responsible for reviewing and approving access termination requests.

## Evidence Collection Methods

### Machine Attestation
- **Automated Access Revocation**: Integrate with the HR management system to automatically trigger access termination when an employee's status is updated to "terminated." This ensures that access to EPHI is revoked immediately.
  
- **API Integration**: Use API calls with cloud service providers to invalidate all access tokens associated with terminated employees, ensuring they no longer have access to EPHI.

- **Log Collection**: Utilize OSquery or similar tools to collect access logs of terminated employees to ensure all access points have been accounted for and terminated.

### Human Attestation
- **Termination Notice**: The HR department must provide a signed termination notice for each employee who leaves. This notice should be uploaded to Surveilr with relevant metadata, including review date and reviewer name.

- **Access Termination Report**: After access has been revoked, the IT administrator must verify the termination and document the process in a formal report. This report must be uploaded to Surveilr for record-keeping.

## Verification Criteria
- Verification of access termination must be performed within 24 hours of receiving the termination notice from HR.
- Regular audits should be conducted to ensure that all access terminations have been executed as per this policy and to identify any potential gaps in the process.

## Exceptions
Any exceptions to this policy must be documented and approved by the IT security officer. Exceptions may be granted in cases where immediate access termination is not feasible due to operational requirements, but access must be terminated as soon as possible thereafter.

---

This policy demonstrates a commitment to safeguarding EPHI by ensuring that access is effectively managed and terminated in a timely manner, thereby adhering to HIPAA regulations and protecting patient privacy.