---
title: "Together.Health Backup Storage Policy"
weight: 1
description: "Establishes requirements for secure alternate storage sites to ensure effective backup recovery and enhance organizational resilience against data loss."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "FII-SCF-BCD-0008"
control-question: "Does the organization establish an alternate storage site that includes both the assets and necessary agreements to permit the storage and recovery of system backup information?"
fiiId: "FII-SCF-BCD-0008"
regimeType: "THSA"
category: ["THSA", "Compliance"]
---

# Together.Health Security Assessment (THSA) Policy Document

## Introduction
In the context of Business Continuity and Disaster Recovery (BCDR), the establishment of alternate storage sites for system backup information is critical to ensure that an organization can recover from unforeseen incidents. This policy focuses on the requirements for alternate storage sites, which safeguard backup assets and facilitate their recovery. By complying with this policy, the organization can mitigate risks associated with data loss, enhance its resilience, and maintain operational continuity.

## Policy Statement
The organization shall establish and maintain an alternate storage site that includes both the necessary assets and agreements to permit the secure storage and recovery of system backup information. This storage must be regularly validated to ensure availability and compliance with established agreements.

## Scope
This policy applies to all organizational entities, including:
- On-premises systems
- Cloud-hosted systems
- Software-as-a-Service (SaaS) applications
- Third-party vendor systems

All personnel involved in data management, backup, and recovery processes must adhere to this policy.

## Responsibilities
- **Compliance Officer**: 
  - Conduct quarterly reviews of backup storage agreements and ensure compliance with the policy.
- **IT Security Team**: 
  - Perform monthly validations of all backup locations and related agreements.
- **Data Owners**: 
  - Ensure that data categorized for backup is compliant with the policy and that necessary agreements are in place.
- **Backup Administrators**: 
  - Implement and manage the backup processes, ensuring data is stored at the alternate site as per the defined schedule.

## Evidence Collection Methods
1. **REQUIREMENT**: The organization must identify and maintain an alternate storage site with agreements for storage and recovery of backups.
   
2. **MACHINE ATTESTATION**:
   - Utilize API integrations with cloud providers to automatically confirm the existence of backup agreements and validate storage locations.

3. **HUMAN ATTESTATION**:
   - A designated manager must sign off on the annual review of the alternate storage site agreements, with documentation retained for audit purposes.

## Verification Criteria
- **SMART Objective**: 
  - Ensure that 100% of backup storage agreements are reviewed and validated quarterly.
- **KPIs/SLAs**: 
  - Achieve a monthly validation success rate of 95% for backup locations.
  - Maintain documentation of backup recovery drills, with at least one drill conducted bi-annually.

## Exceptions
Exceptions to this policy may be granted under extraordinary circumstances. Approval must be obtained from the Compliance Officer, who will document the reason for the exception and the proposed mitigation strategies. Such exceptions will be reviewed on a case-by-case basis.

## Lifecycle Requirements
- **Data Retention**: 
  - Backup agreements must be retained for a minimum of 6 years.
- **Policy Review Frequency**: 
  - This policy shall be reviewed at least annually to ensure ongoing relevance and effectiveness.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logs must be maintained for all critical actions regarding backup storage. Any exceptions must be formally documented and retained for audit purposes.

## References
- FII: FII-SCF-BCD-0008
- Together.Health Security Assessment (THSA) guidelines on Business Continuity & Disaster Recovery