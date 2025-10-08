---
title: "Prohibition of Unidentified Portable Storage Devices Policy"
weight: 1
description: "Prohibits unauthorized portable storage devices without identifiable owners to safeguard sensitive information from data breaches."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "MP.L2-3.8.8"
control-question: "Does the organization prohibit the use of portable storage devices in organizational information systems when such devices have no identifiable owner?"
fiiId: "FII-SCF-DCH-0010.2"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

# CMMC Compliant Policy Document for Control: MP.L2-3.8.8

## Introduction
This policy establishes the guidelines for the prohibition of portable storage devices without identifiable owners in organizational information systems. The purpose is to protect sensitive information, including electronic Protected Health Information (ePHI), from unauthorized access and potential data breaches.

## Policy Statement
The organization prohibits the use of portable storage devices that lack identifiable owners within its information systems. Compliance with this policy is mandatory for all personnel and systems, ensuring adherence to the control requirements outlined in CMMC Control MP.L2-3.8.8.

## Scope
This policy applies to all organizational entities and environments, including but not limited to:
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems
- All channels utilized to create, receive, maintain, or transmit ePHI

## Responsibilities
- **Compliance Officer**: Quarterly policy approval
- **IT Security**: Daily log review for unauthorized device usage
- **System Administrators**: Monthly inventory checks of portable storage devices
- **All Employees**: Immediate reporting of any unidentified portable storage devices

## Evidence Collection Methods
1. **REQUIREMENT**: The organization must ensure all portable storage devices are tracked and have identifiable owners.
2. **MACHINE ATTESTATION**: Utilize OSquery to automate tracking of connected portable devices, logging their usage and ownership details.
3. **HUMAN ATTESTATION**: Managers will sign off on device inventory reports monthly, ensuring all portable storage devices are accounted for and associated with identifiable owners. Reports will be ingested into Surveilr for compliance tracking.

## Verification Criteria
Compliance will be validated through the following **KPIs/SLAs**:
- 100% of portable storage devices must have identifiable owners recorded in the inventory.
- Monthly audits must show no instances of unidentified portable devices.
- 95% of manager attestations on device inventory reports must be completed within the stipulated timeframe.

## Exceptions
Exceptions to this policy must be documented through a formal request process, including:
- Justification for the exception
- Approval from the Compliance Officer
All exceptions will be logged and reviewed during the **Annual Review** process.

## Lifecycle Requirements
- **Data Retention**: Evidence and logs related to portable storage device usage must be retained for a minimum of 6 years.
- Policy must be reviewed and updated at least **annually** to ensure continued relevance and compliance.

## Formal Documentation and Audit
All workforce members must acknowledge and attest to their understanding of this policy and their compliance responsibilities. Comprehensive audit logs must be maintained for all critical actions related to the use of portable storage devices, including any exceptions documented.

## References
None