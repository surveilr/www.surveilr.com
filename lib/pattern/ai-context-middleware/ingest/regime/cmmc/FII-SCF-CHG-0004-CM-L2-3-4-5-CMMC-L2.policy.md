---
title: "Configuration Restrictions for ePHI Security Management"
weight: 1
description: "Enforces configuration restrictions to prevent unauthorized changes, ensuring the integrity and security of electronic Protected Health Information (ePHI)."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "CM.L2-3.4.5"
control-question: "Does the organization enforce configuration restrictions in an effort to restrict the ability of users to conduct unauthorized changes?"
fiiId: "FII-SCF-CHG-0004"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Change Management"
category: ["CMMC", "Level 2", "Compliance"]
---

# Configuration Restrictions Policy for Control CM.L2-3.4.5

## 1. Introduction
This policy outlines the organization's commitment to enforcing configuration restrictions to prevent unauthorized changes to systems and applications that handle electronic Protected Health Information (ePHI). Configuration management is critical in maintaining the integrity, confidentiality, and availability of sensitive data. By implementing stringent configuration restrictions, the organization aims to mitigate risks associated with unauthorized modifications, thereby ensuring compliance with regulatory standards and protecting the interests of stakeholders.

## 2. Policy Statement
The organization is **committed** to enforcing **configuration restrictions** that prevent unauthorized changes to systems and applications. All personnel must adhere to this policy to maintain the security and integrity of ePHI and other sensitive data.

## 3. Scope
This policy applies to all entities and environments within the organization, including but not limited to:
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit ePHI

## 4. Responsibilities
- **Compliance Officer**: 
  - **Review** configuration management practices **quarterly** to ensure adherence to policy.
- **IT Security Personnel**: 
  - **Implement** automated configuration monitoring tools **monthly** to detect unauthorized changes.
  - **Conduct** configuration audits **bi-annually** to verify compliance with established restrictions.
- **System Administrators**: 
  - **Document** all configuration changes and obtain necessary approvals **prior to implementation**.

## 5. Evidence Collection Methods
1. **REQUIREMENT**: The organization must enforce configuration restrictions to prevent unauthorized changes to systems and applications.
2. **MACHINE ATTESTATION**: Utilize OSquery to collect configuration data and generate reports on system configurations, which can be automated to run daily.
3. **HUMAN ATTESTATION**: Managers must **sign off** on configuration audits and change requests, with documentation retained for verification.

## 6. Verification Criteria
Compliance will be validated through the following **KPIs/SLAs**:
- **100%** of configuration audits completed within the scheduled timeframe.
- **0** unauthorized changes detected during automated monitoring.
- **100%** of configuration changes documented and approved.

## 7. Exceptions
Exceptions to this policy may be granted under specific circumstances. The process for documenting exceptions includes:
- Submission of an exception request to the Compliance Officer.
- Review and approval by the IT Security personnel.
- Documentation of the exception must be retained for audit purposes.

## 8. Lifecycle Requirements
- **Data Retention**: All evidence and logs related to configuration management must be retained for a minimum of **three years**.
- **Annual Review**: This policy must be reviewed and updated **annually** to ensure continued relevance and effectiveness.

## 9. Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logs must be maintained for all critical actions related to configuration management. Any exceptions must be formally documented and reviewed.

## 10. References
[Cybersecurity Maturity Model Certification (CMMC)](https://www.acq.osd.mil/cmmc/)  
[Health Insurance Portability and Accountability Act (HIPAA)](https://www.hhs.gov/hipaa/index.html)  
[National Institute of Standards and Technology (NIST) Special Publication 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)  

This policy is designed to maximize machine attestability and ensure compliance with CMMC control CM.L2-3.4.5, thereby reinforcing the organization's commitment to secure configuration management practices.