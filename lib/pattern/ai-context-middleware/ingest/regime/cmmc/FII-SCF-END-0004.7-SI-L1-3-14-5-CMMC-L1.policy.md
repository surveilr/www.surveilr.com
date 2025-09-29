---
title: "Anti-Malware Technology Compliance Policy"
weight: 1
description: "Establishes continuous anti-malware technology operation on all endpoints to protect sensitive data and ensure compliance with CMMC control SI.L1-3.14.5."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "SI.L1-3.14.5"
control-question: "Does the organization ensure that anti-malware technologies are continuously running in real-time and cannot be disabled or altered by non-privileged users, unless specifically authorized by management on a case-by-case basis for a limited time period?"
fiiId: "FII-SCF-END-0004.7"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Endpoint Security"
category: ["CMMC", "Level 1", "Compliance"]
---

# Anti-Malware Technology Policy

## Introduction
This policy outlines the organization's commitment to maintaining endpoint security through the continuous operation of anti-malware technologies. The importance of this policy lies in its role in protecting sensitive data from malicious threats, ensuring compliance with CMMC control SI.L1-3.14.5, and fostering a secure operational environment.

## Policy Statement
The organization is committed to ensuring that anti-malware technologies are continuously running in real-time on all endpoints. These technologies must not be disabled or altered by non-privileged users without specific authorization from management. This measure is crucial for safeguarding our systems and data integrity.

## Scope
This policy applies to:
- All organizational endpoints, including desktops, laptops, and servers.
- Cloud-hosted systems and SaaS applications utilized by the organization.
- Third-party vendor systems that handle sensitive data on behalf of the organization.
- All channels used to create, receive, maintain, or transmit sensitive data.

## Responsibilities
- **Compliance Officer**: Approve policy quarterly and ensure alignment with regulatory requirements.
- **IT Security**: 
  - Review anti-malware logs daily to ensure compliance.
  - Conduct monthly audits of anti-malware systems to verify operational status.
- **System Administrators**: 
  - Implement and maintain anti-malware solutions on all endpoints.
  - Document any changes to anti-malware configurations immediately.
- **Managers**: Approve any exceptions to the policy on a case-by-case basis.

## Evidence Collection Methods
1. **REQUIREMENT**: Anti-malware technologies must operate continuously and in real-time on all endpoints.
2. **MACHINE ATTESTATION**: Utilize tools like `OSquery` to automate evidence collection, verifying that anti-malware solutions are active and functioning on all endpoints.
3. **HUMAN ATTESTATION**: Managers must document any exceptions to the policy, including the rationale and duration, and submit this documentation for ingestion into Surveilr.

## Verification Criteria
Compliance will be validated against the following criteria:
- **KPI**: 100% of endpoints must have anti-malware technologies running at all times.
- **SLA**: Any downtime must be reported and documented, with a maximum allowable downtime of 1 hour per month.

## Exceptions
Requests for exceptions to this policy must be submitted in writing to the Compliance Officer. Each request will be documented, including:
- The reason for the exception.
- The duration for which the exception is requested.
- Management approval.

## Lifecycle Requirements
- **Data Retention**: Logs and evidence of anti-malware operations must be retained for a minimum of 2 years.
- **Annual Review**: This policy must be reviewed and updated annually to ensure its effectiveness and relevance.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding of this policy and their compliance with its terms. Comprehensive audit logs must be maintained for all critical actions related to anti-malware technologies. Documentation for all exceptions must be formally recorded and made accessible for review.

## References
- CMMC Control SI.L1-3.14.5
- FII-SCF-END-0004.7
- Organizational Security Policies and Procedures