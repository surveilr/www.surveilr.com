---
title: "Physical Access Control Policy for Sensitive Information"
weight: 1
description: "Establishes controls to identify and restrict physical access to sensitive systems and environments, ensuring the protection of electronic protected health information (ePHI)."
publishDate: "2025-10-06"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "PE.L1-3.10.5"
control-question: "Does the organization identify systems, equipment and respective operating environments that require limited physical access so that appropriate physical access controls are designed and implemented for offices, rooms and facilities?"
fiiId: "FII-SCF-PES-0004"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 1", "Compliance"]
---

# CMMC Policy Document for Control: PE.L1-3.10.5 (FII: FII-SCF-PES-0004)

## Introduction
This policy establishes the framework for identifying and controlling physical access to systems, equipment, and environments that require limited access to ensure the security of sensitive information, particularly electronic protected health information (ePHI). By maintaining stringent physical and environmental security measures, the organization mitigates risks associated with unauthorized access, safeguarding critical assets and complying with relevant regulatory requirements.

## Policy Statement
The organization is committed to identifying systems, equipment, and respective operating environments that require limited physical access. This commitment ensures that appropriate physical access controls are designed and implemented for offices, rooms, and facilities housing sensitive information.

## Scope
This policy applies to all relevant entities and environments, including but not limited to:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit electronic protected health information (ePHI)

## Responsibilities
- **Compliance Officer:** 
  - **Conduct** monthly assessments of physical access controls.
  - **Report** non-compliance issues to senior management within 48 hours of identification.
  
- **IT Security Personnel:**
  - **Implement** access controls for identified systems and environments **daily**.
  - **Review** security logs for anomalies **weekly**.

- **Facility Management:**
  - **Maintain** physical security measures and infrastructure **monthly**.
  - **Document** any incidents related to physical access **immediately**.

These roles are linked to related organizational plans for escalation and recovery or disciplinary actions as outlined in the organization's compliance framework.

## Evidence Collection Methods
- **1. REQUIREMENT:** Identify systems, equipment, and environments needing limited physical access.
  - **2. MACHINE ATTESTATION:** Use automated inventory management systems to track and validate locations of sensitive systems. Collect data on access logs through centralized logging solutions.
  - **3. HUMAN ATTESTATION:** Security officers must conduct physical inspections of access points and document findings in Surveilr, using a standardized inspection checklist.

- **1. REQUIREMENT:** Implement physical access controls.
  - **2. MACHINE ATTESTATION:** Utilize access control systems (e.g., badge readers) to log access attempts and maintain records that are automatically ingested into Surveilr.
  - **3. HUMAN ATTESTATION:** Personnel must submit monthly access control reports detailing compliance with physical access policies to the Compliance Officer via Surveilr.

## Verification Criteria
Compliance validation will be assessed based on **SMART** criteria linked to **KPIs/SLAs**:
- 95% of identified systems must have documented access control measures.
- 100% of physical access incidents must be reported and logged within 24 hours.
- 100% completion of monthly assessments by the Compliance Officer.

## Exceptions
Exceptions to this policy must be documented and require approval from the Compliance Officer. All exceptions will be reviewed during the **Annual Review** and must include:
- The reason for the exception
- Duration of the exception
- Any compensatory controls implemented

## Lifecycle Requirements
- Evidence and logs must be retained for a minimum **Data Retention** period of **6 years**.
- This policy must be reviewed and updated at least **annually** to ensure relevance and compliance with regulatory changes.

## Formal Documentation and Audit
All workforce members must acknowledge and attest to their understanding of this policy and their compliance responsibilities. Comprehensive audit logs must be maintained for all critical actions related to this policy, and formal documentation must be created for all exceptions to ensure accountability.

## References
- CMMC Control PE.L1-3.10.5
- FII-SCF-PES-0004
- Relevant organizational compliance frameworks and guidelines