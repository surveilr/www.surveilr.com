---
title: "Incident Response and Compliance Policy"
weight: 1
description: "Establishes a comprehensive incident response program to enhance detection, reporting, and recovery of incidents involving ePHI in compliance with CMMC requirements."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "IR.L2-3.6.1
IR.L2-3.6.2"
control-question: "Does the organization cover the preparation, automated detection or intake of incident reporting, analysis, containment, eradication and recovery?"
fiiId: "FII-SCF-IRO-0002"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Incident Response"
category: ["CMMC", "Level 2", "Compliance"]
---

# Incident Response Policy

## Introduction
This policy outlines the requirements for the preparation, automated detection, and intake of incident reporting, analysis, containment, eradication, and recovery in accordance with CMMC controls IR.L2-3.6.1 and IR.L2-3.6.2. The goal is to enhance the organization's incident response capabilities through the integration of machine attestable compliance policies.

## Policy Statement
The organization shall implement a comprehensive incident response program that includes automated mechanisms for incident detection and reporting, as well as clear human attestation processes to ensure compliance with CMMC requirements. This program will encompass all environments, including cloud-hosted systems, SaaS applications, and third-party vendor systems dealing with ePHI.

## Scope
This policy applies to all employees, contractors, and third-party vendors accessing or managing systems that create, receive, maintain, or transmit ePHI within the organization. It covers all relevant environments, including on-premises infrastructure, cloud services, SaaS applications, and external partner systems.

## Responsibilities
- **Incident Response Team**: 
  - Monitor incidents and coordinate response efforts.
  - Execute incident containment and eradication procedures.
- **IT Security Staff**: 
  - Implement and maintain automated detection tools.
  - Regularly analyze incident data for trends.
- **All Employees**: 
  - Report potential incidents immediately to the Incident Response Team.

## Evidence Collection Methods

### 1. REQUIREMENT: Incident Reporting and Analysis
#### 2. MACHINE ATTESTATION:
- Utilize **Surveilr** to automatically collect incident reports from security tools (e.g., SIEM systems) within 5 minutes of detection.
- Employ **OSquery** to generate daily reports of security alerts from all endpoints and servers.
  
#### 3. HUMAN ATTESTATION:
- Incident Response Team members must review and sign an **Incident Analysis Report** within 24 hours of an incident. The signed report will be ingested into Surveilr for compliance tracking.

### 1. REQUIREMENT: Incident Containment and Eradication
#### 2. MACHINE ATTESTATION:
- Deploy automated scripts to contain identified threats within 10 minutes of detection, logging actions taken in Surveilr.
- Use network monitoring tools to ensure affected systems are isolated from the network within 15 minutes.

#### 3. HUMAN ATTESTATION:
- The Incident Response Team must complete a **Containment and Eradication Checklist** after each incident, signed by the team lead within 48 hours. The checklist must be uploaded to Surveilr.

### 1. REQUIREMENT: Incident Recovery
#### 2. MACHINE ATTESTATION:
- Schedule automated backups of critical systems every 24 hours and validate backup integrity using checksum comparisons.
- Use Surveilr to verify system configurations against baseline settings post-recovery.

#### 3. HUMAN ATTESTATION:
- A **Recovery Verification Report** must be signed by the IT Security Manager within 72 hours after recovery actions are completed. This report will be stored in Surveilr for auditing.

## Verification Criteria
Compliance with this policy will be validated against the following **KPIs/SLAs**:
- 95% of incidents must be reported and logged within 5 minutes.
- 100% of containment actions should be logged in Surveilr within 10 minutes.
- 100% of human attestations must be completed within specified timeframes (24, 48, and 72 hours).

## Exceptions
Any exceptions to this policy must be documented and formally approved by the Chief Information Security Officer (CISO). The documentation must include the rationale for the exception and the potential risks involved.

## Lifecycle Requirements
- All incident logs and related documentation must be retained for a minimum of **Data Retention** period of 7 years.
- This policy shall undergo an **Annual Review** to ensure its relevance and effectiveness, with updates made as necessary.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding and compliance with this policy through a digital attestation process. Comprehensive audit logs will be maintained for all critical actions taken under this policy, and formal documentation will be created for all exceptions.

## References
None