---
title: "HIPAA Authorization and Supervision - Policy"
weight: 1
description: "Policy document for HIPAA control 164.308(a)(3)(ii)(A)"
publishDate: "2025-09-22"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "164.308(a)(3)(ii)(A)"
control-question: "Have you implemented procedures for the authorization and/or supervision of employees who work with EPHI or in locations where it might be accessed? (A)"
fiiId: "FII-SCF-IAC-0007"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

# HIPAA Compliance Policy Document: Authorization and Supervision

## Policy Statement
This policy establishes the procedures for the **authorization** and **supervision** of employees who work with **Electronic Protected Health Information (EPHI)** or in locations where EPHI might be accessed. Its purpose is to ensure that only authorized personnel have access to sensitive information, thereby safeguarding patient privacy and ensuring compliance with HIPAA regulations.

## Scope
This policy applies to:
- All employees who have access to EPHI.
- All locations where EPHI may be accessed or stored, including but not limited to:
  - Physical offices
  - Remote workstations
  - Shared environments (e.g., conference rooms with EPHI access)

## Responsibilities
- **Management**:
  - Ensure that authorization procedures are documented and implemented.
  - Regularly review and update access control lists.
  - Supervise employee compliance with this policy.

- **Human Resources (HR)**:
  - Maintain records of employee access to EPHI.
  - Conduct quarterly audits of access privileges.

- **IT Department**:
  - Implement technical controls to enforce access restrictions.
  - Monitor system access logs for unusual activity.

- **Employees**:
  - Adhere to the access policies and report any unauthorized access immediately.
  - Complete training programs on HIPAA compliance and data security.

## Evidence Collection Methods

### Machine Attestation Methods
- **API Integrations**: Use API integrations to validate that employee access to EPHI is limited to those authorized. This includes automated checks against role-based access control lists.
- **Access Logs**: Automatically extract user access logs from systems handling EPHI and ingest them into **Surveilr** for daily review. This process ensures real-time monitoring of access and alerts to any unauthorized attempts.

### Human Attestation Methods
Where automation is impractical, the following human attestation methods will be employed:
- **Quarterly Reports**: The HR manager must maintain and sign a quarterly report that lists all employees with access to EPHI. This report should include:
  - Employee names
  - Job titles
  - Description of EPHI access
- **Surveilr Upload**: Upload the signed report to **Surveilr** along with metadata including:
  - Reviewer name
  - Review date
  - Outcome of the review (e.g., compliant, non-compliant)

## Verification Criteria
Compliance with this policy will be verified through:
- **Automated Checks**: Regular reports generated from API integrations and access logs must show that employee access is restricted to authorized individuals only.
- **Human Attestation Reviews**: Quarterly reports from HR will be reviewed for completeness and accuracy.
- **Audit Trails**: Regular audits of system access logs will be conducted to identify any discrepancies or unauthorized access attempts.

## Exceptions
Exceptions to this policy may be granted under the following circumstances:
- **Temporary Access for Special Projects**: Employees may be granted temporary access to EPHI for specific projects with managerial approval and must be logged in Surveilr.
- **Emergency Situations**: In cases where immediate access to EPHI is required to prevent harm, access must be logged and reviewed post-event to ensure compliance.

## References
- HIPAA Privacy Rule, 45 CFR Part 164
- NIST Special Publication 800-53: Security and Privacy Controls for Information Systems and Organizations
- Organization-specific training materials on HIPAA compliance and EPHI security.

This policy will be reviewed annually or as needed to ensure its effectiveness and compliance with applicable regulations.