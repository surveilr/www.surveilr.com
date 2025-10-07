---
title: "Periodic Review of System Configurations Policy"
weight: 1
description: "Establishes a comprehensive framework for regularly reviewing and securing system configurations to enhance organizational security and compliance."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "CM.L2-3.4.7"
control-question: "Does the organization periodically review system configurations to identify and disable unnecessary and/or non-secure functions, ports, protocols and services?"
fiiId: "FII-SCF-CFG-0003.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

# Policy for Control: CM.L2-3.4.7 (FII: FII-SCF-CFG-0003.1)

## Introduction
The purpose of this policy is to establish a framework for the periodic review of system configurations within the organization. This review aims to identify and disable unnecessary and/or non-secure functions, ports, protocols, and services to enhance the security posture and compliance with regulatory requirements. By implementing this policy, we ensure that organizational systems are configured securely and that potential vulnerabilities are minimized.

## Policy Statement
The organization is committed to regularly reviewing system configurations as an integral part of its Configuration Management process. This commitment includes the identification and disabling of unnecessary and non-secure functionalities, which helps to mitigate risks associated with security breaches and compliance failures.

## Scope
This policy applies to all organizational systems, including but not limited to:
- On-premises servers
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems that interact with organizational data

All employees, contractors, and third-party vendors who have access to these systems are expected to comply with this policy.

## Responsibilities
- **Compliance Officer**: **Quarterly policy approval** and oversight of compliance with this policy.
- **IT Security Team**: 
  - **Daily log review** for unauthorized changes to system configurations.
  - **Monthly assessment** of identified configurations to ensure necessary functions are enabled and unnecessary ones are disabled.
- **System Administrators**: 
  - **Weekly configuration audits** to ensure compliance with the policy.
- **Risk Management Team**: 
  - **Bi-annual risk assessment** to evaluate the impact of configurations on organizational security.

All roles must adhere to established escalation procedures and disciplinary actions as outlined in the organizational Incident Response and Compliance Plans.

## Evidence Collection Methods
1. **REQUIREMENT**: Conduct periodic reviews of system configurations.
   - **MACHINE ATTESTATION**: Utilize OSquery to automate the collection of configuration data and API integrations with cloud providers to validate secure configurations.
   - **HUMAN ATTESTATION**: System Administrators must document their review findings in Surveilr, including screenshots of configuration settings and any corrective actions taken.

2. **REQUIREMENT**: Disable unnecessary services and protocols.
   - **MACHINE ATTESTATION**: Implement automated scripts to identify and report on active services and protocols across systems.
   - **HUMAN ATTESTATION**: IT Security Team must provide a monthly summary report of disabled services to Surveilr, including justifications for any exceptions.

3. **REQUIREMENT**: Maintain a log of configuration changes.
   - **MACHINE ATTESTATION**: Configure centralized logging to capture all configuration changes and store these logs securely.
   - **HUMAN ATTESTATION**: Compliance Officer must review and sign off on the logs quarterly to ensure accuracy and completeness.

## Verification Criteria
Compliance validation will be assessed based on the following **KPIs/SLAs**:
- Percentage of systems reviewed for configuration compliance on a quarterly basis (target: **100%**).
- Number of unauthorized configuration changes identified during daily log reviews (target: **0**).
- Timeliness of disabling unnecessary services and protocols (target: actions taken within **1 week** of identification).

## Exceptions
Exceptions to this policy may be granted under specific circumstances, such as legacy systems that cannot be modified without significant impact. Any exceptions must be documented in writing and approved by the Compliance Officer, including:
- Justification for the exception
- Duration of the exception
- Mitigating controls implemented

## Lifecycle Requirements
- **Data Retention**: Evidence and logs must be retained for a minimum of **6 years**.
- **Annual Review**: This policy must be reviewed and updated at least **annually** to reflect any changes in regulatory requirements or organizational practices.

## Formal Documentation and Audit
All workforce members are required to acknowledge and attest to their understanding and compliance with this policy. Comprehensive audit logging must be maintained for all critical actions related to configuration changes, and formal documentation must be kept for all granted exceptions to ensure accountability and traceability.

## References
- CMMC Framework
- NIST SP 800-53 Security and Privacy Controls
- Organizational Incident Response Plan
- Compliance and Risk Management Guidelines