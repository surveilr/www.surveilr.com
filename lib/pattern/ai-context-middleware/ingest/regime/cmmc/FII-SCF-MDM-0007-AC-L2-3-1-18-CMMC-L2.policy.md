---
title: "Prohibition of Unauthorized Application Installations"
weight: 1
description: "Prohibits the installation of non-approved applications to ensure the security and integrity of the organization’s information systems and ePHI."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.18"
control-question: "Does the organization prohibit the installation of non-approved applications or approved applications not obtained through the organization-approved application store?"
fiiId: "FII-SCF-MDM-0007"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Mobile Device Management"
category: ["CMMC", "Level 2", "Compliance"]
---

# Policy for Control: AC.L2-3.1.18 (FII: FII-SCF-MDM-0007)

## Introduction
This policy establishes the requirements for prohibiting the installation of non-approved applications or approved applications not obtained through the organization-approved application store. This is essential to ensure the security and integrity of the organization’s information systems, particularly concerning the protection of electronic Protected Health Information (ePHI).

## Policy Statement
The organization strictly prohibits the installation of any applications that are not approved or not obtained through the designated organization-approved application store. This includes both cloud-hosted systems and all third-party vendor systems. Compliance is mandatory for all personnel using organization devices.

## Scope
This policy applies to:
- All employees, contractors, and third-party vendors accessing organizational systems.
- All environments including on-premises, cloud-hosted systems, and Software as a Service (SaaS) applications.
- All channels used to create, receive, maintain, or transmit ePHI.

## Responsibilities
- **IT Security Team**: Responsible for maintaining the approved application list and facilitating machine attestation methods.
- **Compliance Officer**: Oversees adherence to this policy and manages audit logging.
- **End Users**: Required to comply with the policy and report any non-compliance incidents.

## Evidence Collection Methods
### 1. REQUIREMENT:
Prohibit the installation of non-approved applications or approved applications not obtained through the organization-approved application store.

### 2. MACHINE ATTESTATION:
- Utilize OSquery to automatically collect data on installed applications across devices and generate compliance reports.
- Integrate API checks to validate application approval status against the organization’s application repository.

### 3. HUMAN ATTESTATION:
- Users must submit a signed acknowledgment form confirming their understanding of this policy.
- Documentation of compliance must be ingested into Surveilr within 7 days of signing.

## Verification Criteria
- Compliance will be validated based on the successful completion of machine attestation methods with a target of **95% compliance** within a **30-day review period**.
- Non-compliance incidents must be reported and addressed with documented actions taken within **5 business days**.

## Exceptions
Exceptions to this policy must be formally documented and approved by the Compliance Officer. All exceptions will be logged and reviewed during the **Annual Review** of this policy.

## Lifecycle Requirements
- **Data Retention**: Evidence and logs must be retained for a minimum of **3 years** from the date of collection.
- This policy must undergo an **Annual Review** to ensure its effectiveness and compliance with current regulations.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding of this policy through a documented signature. Comprehensive audit logs for all critical actions must be maintained, and formal documentation of any exceptions must be provided to the Compliance Officer.

## References
### References
None