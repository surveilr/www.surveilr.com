---
title: "EPHI Access Control Policy"
weight: 1
description: "Establish guidelines for granting access to electronic protected health information based on legitimate needs and documented procedures."
publishDate: "2025-09-25"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "164.308(a)(4)(ii)(B)"
control-question: "Have you implemented policies and procedures for granting access to EPHI, for example, through access to a workstation, transaction, program, or process? (A)"
fiiId: "FII-SCF-IAC-0001"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance"]
---

# Policy Document for Control: 164.308(a)(4)(ii)(B)

## Introduction
The purpose of this policy is to establish guidelines for granting access to electronic protected health information (EPHI) in compliance with the control 164.308(a)(4)(ii)(B). This policy aims to ensure that access to EPHI is granted based on established procedures, which are both machine-attestable and include necessary human attestations where automation is not feasible.

## Policy Sections

### Control Requirement
The control requires the implementation of policies and procedures for granting access to EPHI through various means, including workstations, transactions, programs, or processes. Access must be based on a legitimate need and documented within the organization’s access control framework.

### Machine Attestation Methods
- **Use OSquery to collect endpoint access logs daily**: Automate the collection of access logs from endpoints to ensure that all access events are recorded and can be reviewed for compliance.
- **Integrate API calls with cloud service providers**: Validate and monitor user access by retrieving access logs and user activity reports from cloud environments automatically.
- **Automated user role validation**: Implement scripts that regularly check and confirm user roles against the organization’s role-based access control system.

### Human Attestation Methods (if unavoidable)
- **Manager signs quarterly access review report**: In cases where automation cannot fully cover access review, the respective manager must manually sign off on quarterly reports summarizing access events and any changes made to user permissions.
- **Documented approval for access modifications**: Any changes to user access must be documented through a formal approval process requiring signatures from relevant stakeholders.

## Scope
This policy applies to all employees, contractors, and third-party vendors who have access to EPHI within the organization. It encompasses all systems and environments, including cloud-hosted systems, SaaS applications, and third-party vendor systems that store or process EPHI.

## Responsibilities
- **Compliance Officer**: Responsible for overseeing policy implementation and ensuring adherence to access control procedures, linking to the Incident Response Plan.
- **IT Security Team**: Tasked with configuring and maintaining automated access logging systems and validating user access through API integrations.
- **Department Managers**: Required to conduct access reviews and provide human attestations where necessary.

## Evidence Collection Methods

### Requirement Explanation
The organization must maintain a record of who has access to EPHI and the process by which access is granted or modified.

### Machine Attestation Approach
- **Automated logging of access events**: Use tools such as OSquery to capture detailed logs of user access to EPHI, ensuring that data is timestamped and stored securely.

### Human Attestation (if unavoidable)
- **Quarterly review documentation**: Managers must sign a report summarizing user access changes and access justification, which will be stored securely in Surveilr with relevant metadata.

## Verification Criteria
- Access logs must be reviewed and validated at least quarterly to ensure compliance with the access control policy.
- All human attestations should be documented and available for audit purposes.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. Such exceptions must include rationale and be reviewed annually.

## Policy Lifecycle Requirements
- Minimum data retention period for access logs: **5 years**.
- Policy review and update frequency: **annually** or as required by changes in regulations or business processes.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logging must be maintained, and formal documentation must be provided for any exceptions, including the date, reason, and approval signatures.

## References
- [HIPAA Compliance](https://www.hhs.gov/hipaa/for-professionals/privacy/index.html)
- [OSquery Documentation](https://osquery.readthedocs.io/en/stable/)
- [NIST Access Control Standards](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)