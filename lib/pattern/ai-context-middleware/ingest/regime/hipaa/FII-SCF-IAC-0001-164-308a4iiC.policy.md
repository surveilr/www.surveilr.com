---
title: "User Access Authorization Policy"
weight: 1
description: "Establishes access authorization controls for user access to enhance security and ensure compliance."
publishDate: "2025-09-25"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "164.308(a)(4)(ii)(C)"
control-question: "Have you implemented policies and procedures that are based upon your access authorization policies, established, document, review, and modify a user's right of access to a workstation, transaction, program, or process? (A)"
fiiId: "FII-SCF-IAC-0001"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance"]
---

# Policy for Control 164.308(a)(4)(ii)(C) (FII: FII-SCF-IAC-0001)

## Introduction
The purpose of this policy is to establish comprehensive access authorization controls for user access to workstations, transactions, programs, and processes across our organization. This policy ensures compliance with relevant regulations and enhances the security of sensitive information by defining clear roles, responsibilities, and methods for managing user access rights.

## Policy Sections

### Access Authorization Control Requirement
**Policy Statement**: All user access rights must be established, documented, reviewed, and modified in accordance with defined access authorization policies. Access rights will be assigned based on the principle of least privilege, ensuring users have only the necessary rights to perform their job functions.

### Machine Attestation Methods
**Evidence Collection Methods**  
- **OSquery**: Utilize OSquery to automatically collect user access logs, including login timestamps, accessed resources, and user permission changes. This data will be ingested into Surveilr for ongoing monitoring and compliance validation.
- **Automated Alerts**: Implement automated alerts for any changes in user access rights, ensuring that modifications are logged and reviewed in real-time.
  
### Human Attestation Methods
**Evidence Collection Methods**  
- **Manager Certification**: In instances where automation is impractical, managers must conduct quarterly reviews of user access rights. This review should be documented and signed by the manager, confirming that all access rights have been reviewed and are appropriate for each user.
  - **Artifacts**: Review logs and certification forms must be ingested into Surveilr within one week of completion.

## Scope
This policy applies to:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems

## Responsibilities
- **IT Security Team**: 
  - Conduct quarterly audits of user access logs (using OSquery) to ensure compliance with access authorization policies.
  - Frequency: Quarterly
- **Managers**: 
  - Certify user access rights for their teams every quarter.
  - Frequency: Quarterly
- **Compliance Officer**: 
  - Review and update this policy annually to ensure it meets compliance and regulatory requirements.
  - Frequency: Annually

## Evidence Collection Methods
### Machine Attestation
1. **Log Access**: Collect access logs using OSquery every month.
2. **Automated Review**: Generate a compliance report based on collected logs to identify any discrepancies.
3. **Ingestion**: Automate ingestion of OSquery results into Surveilr.

### Human Attestation
1. **Certification Form**: Managers must complete a user access rights certification form, detailing their review findings.
2. **Submission**: Submit the certification form to the Compliance Officer via email.
3. **Ingestion**: Documented certifications must be ingested into Surveilr within 7 days post-review.

## Verification Criteria
- **Compliance Validation**: Compliance with this policy will be validated through quarterly audits of OSquery logs and manager certification forms. 
- **Success Metric**: 100% of user access rights must be certified by managers within the required timeframe.

## Exceptions
Exceptions to this policy must be formally documented, including the rationale for the exception and approval from the Compliance Officer. Documentation must be retained in Surveilr.

## Policy Lifecycle Requirements
- **Data Retention**: User access logs must be retained for a minimum of 3 years.
- **Policy Review Frequency**: This policy must be reviewed and updated at least annually or as needed based on significant changes to the organization or regulatory requirements.

## Formal Documentation and Audit
All workforce members must acknowledge understanding of this policy in writing. Comprehensive audit logs for critical actions, including access modifications and exception approvals, must be maintained and monitored.

### References
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)
- [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)