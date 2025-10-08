---
title: "Continuous Anti-Malware Operational Integrity Policy"
weight: 1
description: "Establishes continuous operational integrity of anti-malware technologies to protect organizational systems from unauthorized alterations and malware threats."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "SI.L1-3.14.5"
control-question: "Does the organization ensure that anti-malware technologies are continuously running in real-time and cannot be disabled or altered by non-privileged users, unless specifically authorized by management on a case-by-case basis for a limited time period?"
fiiId: "FII-SCF-END-0004.7"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Endpoint Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# Policy Document for CMMC Control: SI.L1-3.14.5 (FII: FII-SCF-END-0004.7)

## 1. Introduction
This policy establishes the framework for ensuring that anti-malware technologies are continuously operational in real-time across the organization. The intent is to protect organizational information and systems from malware threats by ensuring that anti-malware solutions are not disabled or altered by unauthorized users.

## 2. Policy Statement
The organization is committed to maintaining the integrity and efficacy of its anti-malware technologies. These systems must operate continuously in real-time and cannot be disabled or modified by non-privileged users without explicit authorization from management, limited to specific cases and timeframes.

## 3. Scope
This policy applies to all organizational entities, including but not limited to:
- On-premises systems
- Cloud-hosted environments
- Software as a Service (SaaS) applications
- Third-party vendor systems

## 4. Responsibilities
- **IT Security Team**: Monitor anti-malware systems **Daily** for compliance and functionality.
- **System Administrators**: Configure and maintain anti-malware applications **Weekly** to ensure they are running as expected.
- **IT Manager**: Review and approve access requests for non-privileged users to alter anti-malware settings **Monthly**.
- **Compliance Officer**: Conduct an annual review of the anti-malware policy **Annually** and report findings to management.

## 5. Evidence Collection Methods
1. **REQUIREMENT**: Anti-malware technologies must operate continuously and in real-time without unauthorized alterations.
2. **MACHINE ATTESTATION**: Utilize OSquery to verify that anti-malware services are active on all endpoints **Daily**. Log results for audit purposes.
3. **HUMAN ATTESTATION**: The IT manager must sign a report each month confirming that all non-privileged users have restricted access to anti-malware settings, ensuring compliance with this policy.

## 6. Verification Criteria
Compliance with this policy will be measured against the following **KPIs/SLAs**:
- 100% of endpoints must have active anti-malware services at all times.
- Monthly reports from IT managers should indicate no unauthorized access to anti-malware settings.
- Annual reviews must show that no security incidents related to anti-malware settings occurred.

## 7. Exceptions
Any exceptions to this policy must be documented in writing, including the justification for the exception and the specific approval from management. Exceptions will be reviewed and reassessed on a quarterly basis.

## 8. Lifecycle Requirements
- **Data Retention**: All logs and evidence of compliance must be retained for a minimum of 12 months.
- **Annual Review**: This policy will undergo a comprehensive review annually to ensure its effectiveness and relevance in the evolving threat landscape.

## 9. Formal Documentation and Audit
All workforce members must acknowledge their understanding of this policy and their compliance through a signed document. Additionally, audit logs must be maintained for all critical actions related to anti-malware systems, including any alterations to their configuration.

## 10. References
None