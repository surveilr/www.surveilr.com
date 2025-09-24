---
title: "HIPAA 164.308(a)(3)(ii)(C) - Policy"
weight: 1
description: "Policy document for HIPAA control 164.308(a)(3)(ii)(C)"
publishDate: "2025-09-23"
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

# Termination of Access to EPHI Policy

## Introduction
The purpose of this policy is to establish procedures for terminating access to electronic Protected Health Information (EPHI) in compliance with HIPAA regulation 164.308(a)(3)(ii)(C). This ensures that access rights are revoked promptly and appropriately when an employee leaves the organization or as required by other specified conditions.

## Policy Statement
Our organization is committed to safeguarding EPHI by implementing robust procedures for terminating access to EPHI when employees no longer require access. This policy aims to minimize risks associated with unauthorized access and ensure compliance with HIPAA regulations.

## Scope
This policy applies to all employees, contractors, and third-party affiliates who have access to EPHI. It encompasses all forms of access, including physical and electronic methods.

## Responsibilities
- **HR Department**: Responsible for notifying IT of employee terminations and managing the access termination checklist.
- **IT Department**: Responsible for executing access termination procedures and maintaining audit logs.
- **Compliance Officer**: Responsible for oversight and periodic review of access termination processes to ensure compliance.

## Evidence Collection Methods

### Explanation
To ensure compliance with this policy, evidence must be collected to demonstrate that access to EPHI has been terminated for all departing employees.

### Machine Attestation
- **Integration with Identity Management Systems**: Access to EPHI will be automatically revoked through integration with identity management systems. Logs of access terminations will be ingested into Surveilr, providing machine-attestable evidence of compliance.
- **Endpoint Configuration Monitoring**: Utilize `OSquery` to monitor endpoints for any unauthorized access attempts post-termination.

### Human Attestation (if unavoidable)
- **Access Termination Checklist**: HR must complete the access termination checklist for departing employees. This checklist must be signed and uploaded to Surveilr, accompanied by metadata such as reviewer name, date, and outcome.

## Verification Criteria
Verification will be based on the timely and complete revocation of access as evidenced by:
- Machine logs from identity management systems in Surveilr.
- Completed and signed access termination checklists stored in Surveilr.

## Exceptions
Exceptions to this policy must be documented and approved by the Compliance Officer. Any deviations from the established procedures must be justified and assessed for risk.

## References
- [HIPAA Privacy Rule](https://www.hhs.gov/hipaa/for-professionals/privacy/index.html)
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)

### _References_
- [HIPAA Compliance Overview](https://www.hhs.gov/hipaa/for-professionals/compliance/index.html)
- [Surveilr Documentation](https://www.surveilr.com/docs)