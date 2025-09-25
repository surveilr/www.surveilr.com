---
title: "ePHI Access Termination Policy"
weight: 1
description: "Establishes procedures for promptly terminating access to electronic Protected Health Information upon employee exit."
publishDate: "2025-09-25"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "164.308(a)(3)(ii)(C)"
control-question: "Have you implemented procedures for terminating access to EPHI when an employee leaves your organization or as required by paragraph (a)(3)(ii)(B) of this section? (A)"
fiiId: "FII-SCF-IAC-0007.2"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance"]
---


# Policy Document for Control 164.308(a)(3)(ii)(C)

## Introduction
The purpose of this policy is to establish procedures for terminating access to electronic Protected Health Information (ePHI) when an employee exits the organization or as mandated. This policy aims to ensure compliance with regulatory requirements and maintain the confidentiality, integrity, and availability of ePHI.

## Policy Statement
Access to ePHI must be terminated promptly to mitigate risks associated with unauthorized access. This policy outlines the procedures, responsibilities, and methods for both machine and human attestation regarding access termination.

## Scope
This policy applies to:
- **Cloud-hosted systems**: Any systems hosted on cloud platforms that store or process ePHI.
- **SaaS applications**: Software as a Service applications that provide access to ePHI.
- **Third-party vendor systems**: External vendors that have access to ePHI.
- **All channels**: Any channels used to create, receive, maintain, or transmit ePHI.

## Responsibilities
- **HR Department**: Responsible for notifying IT of employee terminations and maintaining signed termination acknowledgment forms.
- **IT Department**: Responsible for disabling access to ePHI and conducting audits of user accounts.
- **Compliance Officer**: Responsible for overseeing adherence to this policy and ensuring regular reviews.

## Evidence Collection Methods

### Machine Attestation Methods
- **Automated Access Log Collection**: 
  - Use `OSquery` to collect access logs daily and verify that employee access to ePHI is disabled within **24 hours** of termination.
  - Automate the ingestion of access logs into Surveilr for real-time monitoring.
  
- **Account Audits**:
  - Schedule automated weekly audits of user accounts to ensure compliance with access termination policies.
  - Use Surveilr to generate compliance reports that confirm appropriate access removal.

### Human Attestation Methods
- **Termination Checklist**:
  - The HR manager must sign off on a termination checklist upon employee exit.
  - Signed checklists are to be uploaded to Surveilr with metadata (review date, reviewer name) for traceability.

## Verification Criteria
- **Compliance Validation**:
  - Confirm that 100% of employee access to ePHI is disabled within **24 hours** of termination.
  - Ensure that weekly audits show no unauthorized access to ePHI by terminated employees.

## Operational Steps
1. **Notification**: HR notifies IT of an employee termination within **24 hours**.
2. **Access Termination**: IT disables ePHI access using automated tools within the next **24 hours**.
3. **Audit Logs**: Conduct weekly audits of account access and generate compliance reports.
4. **Documentation**: HR manager signs and uploads the termination checklist to Surveilr, including relevant metadata.
5. **Review and Update**: Compliance officer reviews the policy every **six months** and updates as necessary.

## Exceptions
Any exceptions to this policy must be formally documented and approved by the Compliance Officer. Documentation should include:
- The rationale for the exception.
- The duration of the exception.
- Any compensating controls that are in place.

## Policy Lifecycle Requirements
- **Data Retention**: Evidence and logs must be retained for a minimum of **six years**.
- **Policy Review**: This policy will be reviewed and updated at least every **six months** or as necessary.

## Formal Documentation and Audit
- Workforce members must acknowledge their understanding and compliance with this policy.
- Critical actions, including access termination, must be logged for audit purposes.
- Formal documentation must be maintained for all exceptions to this policy.

## Attestation Descriptions
- **Machine Attestation**: Automated processes for access termination and compliance checks using tools like OSquery and Surveilr.
- **Human Attestation**: Steps involving the HR manager's signed termination checklist, uploaded to Surveilr.

### References
None
```