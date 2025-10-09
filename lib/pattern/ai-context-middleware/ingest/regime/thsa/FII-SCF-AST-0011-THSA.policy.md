---
title: "Control of Systems Access and Tracking Policy"
weight: 1
description: "Establishes systematic control and tracking of systems entering and exiting organizational facilities to safeguard assets and ensure compliance with ePHI regulations."
publishDate: "2025-10-03"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "FII-SCF-AST-0011"
control-question: "Does the organization authorize, control and track systems entering and exiting organizational facilities?"
fiiId: "FII-SCF-AST-0011"
regimeType: "THSA"
category: ["THSA", "Compliance"]
---

# Policy Document: Control of Systems Entering and Exiting Organizational Facilities

## Introduction
The purpose of this policy is to establish a systematic approach for the authorization, control, and tracking of systems that enter and exit organizational facilities. This policy aims to safeguard organizational assets, including hardware and software, by ensuring that all systems are accounted for and monitored throughout their lifecycle.

## Policy Statement
The organization shall authorize, control, and track all systems entering and exiting its facilities, including cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit electronic protected health information (ePHI). Compliance with this policy is mandatory for all workforce members.

## Scope
This policy applies to:
- All organizational facilities, including data centers and offices.
- Cloud-hosted systems and SaaS applications utilized by the organization.
- Third-party vendor systems (Business Associates).
- All methods of creating, receiving, maintaining, or transmitting ePHI.

## Responsibilities
- **IT Security Manager**: 
  - **Authorize** system entry and exit *weekly*.
  - **Monitor** compliance with this policy *daily*.
  - **Review** access logs for anomalies *monthly*.
  
- **Facility Security Officer**: 
  - **Control** physical access to facilities *continuously*.
  - **Conduct** checks of systems entering and exiting *daily*.
  
- **Compliance Officer**: 
  - **Ensure** policy adherence across all departments *quarterly*.
  - **Report** compliance status to management *monthly*.

## Evidence Collection Methods
### 1. REQUIREMENT:
The organization must maintain a comprehensive inventory of all systems entering and exiting the facilities.

### 2. MACHINE ATTESTATION:
- Utilize **OSquery** to collect asset inventories daily, ensuring all systems have unique asset tags.
- Implement automated logging of system entry and exit events to a centralized **Surveilr** dashboard.
  
### 3. HUMAN ATTESTATION:
- The IT Security Manager must sign off on the **quarterly asset inventory report** to confirm accuracy and completeness, with the signed document ingested into Surveilr.

### 1. REQUIREMENT:
All access to organizational facilities must be logged and monitored.

### 2. MACHINE ATTESTATION:
- Deploy automated logging systems to capture entry and exit timestamps of all systems and personnel, ingested into **Surveilr** for real-time monitoring.

### 3. HUMAN ATTESTATION:
- Facility Security Officer must review and sign the **monthly access log summary**, confirming adherence to access control policies, with documents uploaded to Surveilr.

## Verification Criteria
- Compliance will be measured against the following **SMART** criteria:
  - 100% of systems must have asset tags verified via OSquery daily.
  - All entry and exit logs must be reviewed and signed off within 48 hours of occurrence.
  - Monthly access log summaries must show no unauthorized entries.

## Exceptions
Exceptions to this policy may be granted by the IT Security Manager on a case-by-case basis, documented, and reviewed during the **Annual Review**.

## Lifecycle Requirements
- **Data Retention**: All asset inventories and access logs must be retained for a minimum of **6 years**.
- **Mandatory Frequency for Policy Review and Update**: This policy must be reviewed and updated at least **annually**.

## Formal Documentation and Audit
- All workforce members must acknowledge understanding and compliance with this policy through a signed attestation form, to be stored in Surveilr.
- Comprehensive audit logs must be maintained for all critical actions related to system access and inventory management.

## References
None