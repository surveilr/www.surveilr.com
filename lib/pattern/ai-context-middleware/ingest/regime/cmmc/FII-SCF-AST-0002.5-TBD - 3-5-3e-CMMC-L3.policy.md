---
title: "Automated Network Access Control Policy"
weight: 1
description: "Implement automated mechanisms for Network Access Control to detect unauthorized devices and ensure compliance with CMMC standards."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "TBD - 3.5.3e"
control-question: "Does the organization use automated mechanisms to employ Network Access Control (NAC), or a similar technology, which is capable of detecting unauthorized devices and disable network access to those unauthorized devices?"
fiiId: "FII-SCF-AST-0002.5"
regimeType: "CMMC"
cmmcLevel: 3
domain: "Asset Management"
category: ["CMMC", "Level 3", "Compliance"]
---

# CMMC Compliance Policy for Control: TBD - 3.5.3e

## Introduction
This policy outlines the organization's commitment to utilizing automated mechanisms for Network Access Control (NAC) to detect unauthorized devices and manage network access. The importance of this policy lies in its role in ensuring compliance with the Cybersecurity Maturity Model Certification (CMMC) requirements, thereby safeguarding sensitive information and maintaining the integrity of our network infrastructure.

## Policy Statement
The organization mandates the use of automated mechanisms for Network Access Control (NAC) to effectively identify unauthorized devices attempting to access the network. This proactive approach is essential for maintaining a secure environment and ensuring compliance with CMMC standards.

## Scope
This policy applies to all organizational entities, including but not limited to:
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems
All personnel and systems interacting with these environments must adhere to this policy.

## Responsibilities
- **Compliance Officer**: Quarterly policy review and approval.
- **IT Security Team**: Monthly monitoring of NAC systems and reporting of unauthorized access attempts.
- **Network Administrators**: Daily configuration and maintenance of NAC mechanisms.
- **All Employees**: Immediate reporting of any suspected unauthorized devices or access attempts.

## Evidence Collection Methods
1. **REQUIREMENT**: The organization must implement automated mechanisms for NAC that can detect unauthorized devices and restrict their access to the network.
2. **MACHINE ATTESTATION**: Utilize OSquery to automate the monitoring of network devices, generating logs that indicate unauthorized access attempts and compliance status.
3. **HUMAN ATTESTATION**: Personnel must document any incidents of unauthorized access, including details of the event, actions taken, and submit this documentation into the Surveilr system for ingestion and review.

## Verification Criteria
Compliance validation will be measured against the following Key Performance Indicators (KPIs):
- **Unauthorized Access Detection Rate**: At least 95% of unauthorized access attempts must be detected and logged by NAC mechanisms.
- **Incident Response Time**: Unauthorized devices must be isolated within 5 minutes of detection.
- **Documentation Accuracy**: 100% of incidents must be accurately documented and submitted to Surveilr within 24 hours.

## Exceptions
Any exceptions to this policy must be documented in writing, including a clear justification for the exception and the approval of the Compliance Officer. This documentation must be retained for audit purposes.

## Lifecycle Requirements
- **Data Retention**: All evidence and logs related to NAC must be retained for a minimum of 12 months.
- **Annual Review**: This policy will undergo an annual review to ensure its effectiveness and relevance to current security practices.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding of this policy and their compliance obligations. Comprehensive audit logging will be required for all critical actions related to NAC, ensuring accountability and traceability.

## References
None