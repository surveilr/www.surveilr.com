---
title: "Asset Management Security Policy for ePHI"
weight: 1
description: "Establishes comprehensive asset management controls to protect ePHI and ensure compliance with regulatory requirements within the organization."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "FII-SCF-AST-0001"
control-question: "Does the organization facilitate the implementation of asset management controls?"
fiiId: "FII-SCF-AST-0001"
regimeType: "THSA"
category: ["THSA", "Compliance"]
---

## Introduction

The purpose of this policy is to ensure the effective implementation of asset management controls within the organization. Asset management is critical for maintaining the integrity, confidentiality, and availability of electronic Protected Health Information (ePHI). By establishing robust asset management controls, the organization can better manage its resources, mitigate risks, and ensure compliance with applicable regulations.

## Policy Statement

The organization is committed to implementing comprehensive asset management controls to ensure the proper identification, classification, and management of assets that handle ePHI. This commitment helps safeguard sensitive information and supports the overall security posture of the organization.

## Scope

This policy applies to all organizational assets, including but not limited to:

- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems (Business Associates)
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities

- **IT Department**: Conduct an **annual** asset inventory review to ensure all assets are accounted for.
- **Security Team**: Perform **quarterly** assessments of asset management controls to identify any gaps and recommend improvements.
- **Business Units**: Update asset records **biannually** to reflect any changes in the assets they manage.
- **Compliance Officer**: Review and approve the asset management policy **annually** to ensure it meets regulatory requirements.

## Evidence Collection Methods

1. **REQUIREMENT**: The organization must maintain an accurate and up-to-date inventory of all assets handling ePHI.
   
2. **MACHINE ATTESTATION**: Use OSquery to collect asset inventories **daily**, ensuring that all assets are logged and categorized appropriately.

3. **HUMAN ATTESTATION**: The IT manager must sign off on the **quarterly** software inventory report, which will be ingested into Surveilr for compliance tracking.

## Verification Criteria

Compliance will be validated against the following **SMART** **KPIs/SLAs**:

- **Specific**: 100% of assets must be accounted for in the inventory.
- **Measurable**: Inventory discrepancies must be less than 2% across any given review period.
- **Achievable**: Asset management controls must be implemented and documented as per the established schedule.
- **Relevant**: The asset management controls must align with organizational security objectives.
- **Time-bound**: Reviews and updates must occur within the specified timeframes (e.g., **annually**).

## Exceptions

Any exceptions to this policy must be documented and approved by the Compliance Officer. The documentation will include the nature of the exception, justification, and any compensating controls that will be implemented to mitigate risks associated with the exception.

## Lifecycle Requirements

Evidence and logs must be retained for a minimum of **6 years** to comply with regulatory requirements. This policy will be reviewed and updated at least **annually** to ensure it remains effective and relevant.

## Formal Documentation and Audit

All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logging will be implemented for all critical actions related to asset management. Documentation for any exceptions must be formalized and maintained as part of the organization's compliance records.

## References

[HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)