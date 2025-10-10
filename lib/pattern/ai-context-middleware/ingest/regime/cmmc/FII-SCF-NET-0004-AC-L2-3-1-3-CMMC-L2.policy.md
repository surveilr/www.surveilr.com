---
title: "Access Control List Compliance Policy"
weight: 1
description: "Implement Access Control Lists to restrict unauthorized network traffic and ensure compliance with CMMC standards for safeguarding sensitive information."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.3"
control-question: "Does the organization implement and govern Access Control Lists (ACLs) to provide data flow enforcement that explicitly restrict network traffic to only what is authorized?"
fiiId: "FII-SCF-NET-0004"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction

This policy outlines the implementation and governance of Access Control Lists (ACLs) to enforce data flow restrictions within the organization’s network. Compliance with the **CMMC** control AC.L2-3.1.3 is critical for safeguarding sensitive information and ensuring that only authorized network traffic is permitted. This document includes specific requirements for machine and human attestations that will enhance the organization’s compliance posture.

## Policy Statement

The organization shall implement ACLs on all network devices to explicitly restrict network traffic to authorized sources and destinations. This policy mandates regular reviews, updates, and verifications to ensure the effectiveness of ACLs and compliance with the **CMMC** standards.

## Scope

This policy applies to:
- All cloud-hosted systems.
- Software as a Service (SaaS) applications.
- All channels utilized to create, receive, maintain, or transmit data within the organization’s network.

## Responsibilities

- **Network Security Officer:** 
  - Conduct quarterly ACL reviews to ensure that all entries are valid and necessary.
  - Ensure that ACL configurations are documented and updated following any changes in network architecture.
  
- **System Administrator:**
  - Implement ACL changes as authorized by the Network Security Officer.
  - Maintain logs of ACL modifications and document the rationale for changes.
  
- **Compliance Officer:**
  - Oversee compliance with this policy and report on adherence during quarterly compliance reviews.
  - Facilitate training for relevant staff regarding ACL management and compliance expectations.

## Evidence Collection Methods

- **Machine Attestation:**
  - Use **OSquery** to collect ACL configurations and logs of changes made to these configurations on a daily basis.
  - Schedule automated scripts to check the ACL settings against a baseline and report any deviations.

- **Human Attestation:**
  - The Network Security Officer must sign off on the quarterly ACL review report, which is then uploaded to **Surveilr** for compliance tracking.
  - Maintain records of all training sessions conducted for staff responsible for ACL management, including dates and participant lists.

## Verification Criteria

Compliance will be validated using the following **SMART** criteria:
- **100% of ACLs must be reviewed quarterly** by the Network Security Officer, with documented evidence stored in **Surveilr**.
- **Decrease unauthorized access incidents by 20%** within 12 months, tracked through security incident reports.
- **All ACL changes must be logged and reviewed** within 48 hours of implementation.

## Exceptions

Any exceptions to this policy must be documented and formally approved by the Compliance Officer. Documentation of exceptions must include:
- Justification for the exception.
- Duration of the exception.
- Review date to evaluate the necessity of the exception.

## Lifecycle Requirements

- **Data Retention:** All evidence related to ACL modifications, including logs and review reports, must be retained for a minimum of **3 years**.
- This policy will undergo an **Annual Review** to ensure ongoing relevance and compliance with changes in technology and regulatory requirements.

## Formal Documentation and Audit

All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logs of all ACL changes must be maintained. Exceptions will be formally documented and reviewed during compliance audits. 

## References

None.