---
title: "Account Management and Access Control Policy"
weight: 1
description: "Establishes structured account management practices to protect ePHI and ensure compliance with regulatory standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L1-3.1.2"
control-question: "Does the organization proactively govern account management of individual, group, system, service, application, guest and temporary accounts?"
fiiId: "FII-SCF-IAC-0015"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

# Account Management Policy for Control AC.L1-3.1.2 (FII: FII-SCF-IAC-0015)

## Introduction
In today's digital landscape, proactive governance in account management is crucial to safeguarding sensitive information and ensuring compliance with regulatory frameworks. This policy establishes a structured approach for the management of individual, group, system, service, application, guest, and temporary accounts, thereby minimizing the risks associated with unauthorized access to electronic protected health information (ePHI). By implementing robust account management practices, the organization reinforces its commitment to data security and regulatory compliance.

## Policy Statement
The organization is committed to effectively managing all types of accounts, including individual, group, system, service, application, guest, and temporary accounts. Through diligent oversight and governance, the organization aims to ensure that all accounts are created, maintained, and terminated in a manner that protects ePHI and adheres to compliance requirements.

## Scope
This policy applies to all personnel and systems within the organization, including but not limited to:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems (Business Associates)
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities
- **Compliance Officer:** Approve policy quarterly.
- **IT Security:** Review account activity logs daily.
- **System Administrators:** Create, modify, and deactivate accounts as needed, ensuring compliance with policy.
- **HR Department:** Notify IT of personnel changes impacting account status within 24 hours.
- **Audit Team:** Conduct semi-annual account audits to ensure compliance with this policy.

## Evidence Collection Methods
1. **REQUIREMENT:** Monitor and manage account access to ensure compliance with organizational policies.
   - **MACHINE ATTESTATION:** Use OSquery to collect account activity logs daily.
   - **HUMAN ATTESTATION:** The IT manager must sign off on the quarterly account review report and submit it to the Compliance Officer.

2. **REQUIREMENT:** Review accounts for appropriateness and necessity.
   - **MACHINE ATTESTATION:** Automate account access reports using system logging tools on a monthly basis.
   - **HUMAN ATTESTATION:** HR must provide a monthly report on personnel changes impacting account access.

## Verification Criteria
Compliance will be validated using the following **SMART** criteria:
- All account activity logs must be collected daily, with a minimum of **95%** accuracy in data collection.
- Quarterly account reviews must be signed off by the IT manager with a completion rate of **100%**.
- Audit findings must result in actionable remediation within **30 days** for any identified issues.

## Exceptions
Any deviations from this policy must be documented and approved by the Compliance Officer. Exceptions may be permissible for temporary accounts used for specific projects, provided they are reviewed and deactivated post-project.

## Lifecycle Requirements
- All evidence/logs must be retained for a minimum of **6 years**.
- This policy must be reviewed and updated at least **annually**, or more frequently as required by changes in regulations or organizational needs.

## Formal Documentation and Audit
- All workforce members must acknowledge and attest their understanding and compliance with this policy.
- Comprehensive audit logging must be maintained for all critical account actions, including account creation, modification, and deletion.
- All exceptions to this policy must be formally documented and reviewed during audits.

## References
[Cybersecurity Maturity Model Certification (CMMC)](https://www.acq.osd.mil/cmmc)