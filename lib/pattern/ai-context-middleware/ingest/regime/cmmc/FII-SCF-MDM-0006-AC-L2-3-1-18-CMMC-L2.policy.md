---
title: "Mobile Device Connection Security Policy"
weight: 1
description: "Restricts personally-owned mobile devices from connecting to organizational systems to protect sensitive information and ensure compliance with security standards."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.18"
control-question: "Does the organization restrict the connection of personally-owned, mobile devices to organizational systems and networks?"
fiiId: "FII-SCF-MDM-0006"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Mobile Device Management"
category: ["CMMC", "Level 2", "Compliance"]
---

# Mobile Device Connection Policy

## Introduction
This policy outlines the requirements for restricting the connection of personally-owned mobile devices to organizational systems and networks, in compliance with CMMC Control AC.L2-3.1.18. The purpose of this policy is to safeguard sensitive information and ensure the integrity of organizational assets.

## Policy Statement
The organization restricts the connection of personally-owned mobile devices to its systems and networks. Only authorized devices that adhere to established security configurations will be permitted access. This policy ensures protection against data breaches and unauthorized access to sensitive information.

## Scope
This policy applies to all employees, contractors, and third-party vendors who may connect personally-owned mobile devices to organizational systems, including but not limited to:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- Any channels used to create, receive, maintain, or transmit electronic Protected Health Information (ePHI)

## Responsibilities
- **IT Security Team**: 
  - **Monitor** mobile device connections **daily** to ensure compliance.
  - **Enforce** security configurations through mobile device management (MDM) solutions **weekly**.
  - **Review** access logs for unauthorized connections **bi-weekly**.
  
- **Employees**:
  - **Sign** the Mobile Device Policy Acknowledgment Form before connecting any device **prior to connection**.
  - **Report** any unauthorized device attempts to the IT Security Team **immediately**.
  
- **Management**:
  - **Review** and approve exceptions to the policy **annually**.
  - **Conduct** employee training on mobile device security **quarterly**.

## Evidence Collection Methods
### 1. REQUIREMENT:
Restrict personally-owned mobile devices from connecting to organizational networks.

### 2. MACHINE ATTESTATION:
- Utilize MDM solutions to enforce device compliance and collect logs of all connected devices **daily**.
- Implement automated alerts for any unauthorized device connection attempts.

### 3. HUMAN ATTESTATION:
- Employees must complete and submit a Mobile Device Policy Acknowledgment Form, which will be ingested into Surveilr for record-keeping **prior to device connection**.

## Verification Criteria
- **Compliance will be validated through**:
  - Review of MDM logs showing zero unauthorized device connections within the last **30 days**.
  - Confirmation that 100% of employees have completed the Mobile Device Policy Acknowledgment Form within the required timeframe, as tracked by Surveilr.

## Exceptions
Exceptions to this policy must be formally documented, including the rationale for the exception. Each request for an exception must be approved by management and reviewed during the **Annual Review** of this policy.

## Lifecycle Requirements
- **Data Retention**: Evidence of device connections and compliance logs must be retained for a minimum of **6 years**.
- This policy will undergo an **Annual Review** to ensure its effectiveness and relevance. Any updates or amendments must be documented and communicated to all stakeholders.

## Formal Documentation and Audit
All employees must acknowledge their understanding and compliance with this policy. Audit logs will be maintained for all critical actions related to device connections, including attempts to access unauthorized devices. Any exceptions must be formally documented and reviewed.

## References
None