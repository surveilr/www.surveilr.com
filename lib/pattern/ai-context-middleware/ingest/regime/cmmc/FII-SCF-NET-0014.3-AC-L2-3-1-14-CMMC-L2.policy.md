---
title: "Remote Access Security Policy for CMMC Compliance"
weight: 1
description: "Establishes secure remote access protocols to protect sensitive data by routing connections through managed network access control points."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.14"
control-question: "Does the organization route all remote accesses through managed network access control points (e.g., VPN concentrator)?"
fiiId: "FII-SCF-NET-0014.3"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction
The purpose of this policy is to establish guidelines for managing remote access to the organization's network in compliance with CMMC control AC.L2-3.1.14. This control mandates that all remote accesses must be routed through managed network access control points, such as VPN concentrators, to ensure secure connectivity and protect sensitive information.

## Policy Statement
It is the policy of the organization to ensure that all remote access connections are strictly routed through designated managed network access control points. This is critical to safeguarding the integrity, confidentiality, and availability of sensitive data, particularly electronic Protected Health Information (ePHI).

## Scope
This policy applies to all employees, contractors, and third-party vendors who require remote access to the organization’s network environment. It encompasses all systems and applications, including cloud-hosted systems, Software as a Service (SaaS) applications, and any channel used to create, receive, maintain, or transmit ePHI.

## Responsibilities
- **Compliance Officer**: Approve the policy annually and ensure adherence to regulations.
- **IT Security**: Monitor and review access logs daily, ensuring that all remote connections comply with this policy.
- **Network Administrator**: Implement and maintain the VPN infrastructure and validate remote access configurations.
- **All Workforce Members**: Acknowledge and comply with remote access policies and procedures.

## Evidence Collection Methods
1. **REQUIREMENT:** Ensure all remote accesses are routed through managed network access control points.
2. **MACHINE ATTESTATION:** 
   - Use OSquery to automate daily collection of remote access logs, ensuring all logs are ingested into Surveilr for analysis.
   - Verify configurations on the VPN concentrator weekly using automated scripts that check for anomalies or unauthorized access attempts.
3. **HUMAN ATTESTATION:** 
   - The network administrator must sign off on the monthly remote access validation report, ensuring all documented access complies with policy requirements. This report must be uploaded to Surveilr for record-keeping.

## Verification Criteria
Compliance with the policy will be verified through:
- Automated reports indicating 100% of remote accesses routed through managed points.
- Monthly review of the VPN access logs showing no unauthorized access attempts.
- Signed documentation from network administrators confirming compliance, with a **KPI** of 100% completion on the monthly reports.

## Exceptions
Any exceptions to this policy must be formally documented and approved by the Compliance Officer. Exceptions will be reviewed on a quarterly basis to assess their necessity and impact on security.

## Lifecycle Requirements
- **Data Retention**: All remote access logs must be retained for a minimum of **12 months**.
- **Policy Review Frequency**: This policy must undergo an **annual review** to ensure it remains relevant and effective.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding of this policy through a formal attestation process. Comprehensive audit logging will be required for all critical actions related to remote access. Any exceptions must be formally documented and reviewed as part of the audit process.

## References
None