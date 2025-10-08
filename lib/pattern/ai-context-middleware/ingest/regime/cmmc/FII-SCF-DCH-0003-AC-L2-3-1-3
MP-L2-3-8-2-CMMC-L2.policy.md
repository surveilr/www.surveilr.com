---
title: "Media Access Control and Security Policy"
weight: 1
description: "Establishes guidelines to restrict access to sensitive digital and non-digital media, ensuring only authorized personnel can handle such information."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.3
MP.L2-3.8.2"
control-question: "Does the organization control and restrict access to digital and non-digital media to authorized individuals?"
fiiId: "FII-SCF-DCH-0003"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Data Classification & Handling"
category: ["CMMC", "Level 2", "Compliance"]
---

## Introduction

The purpose of this policy is to establish guidelines and procedures for controlling and restricting access to both digital and non-digital media within the organization. This policy aligns with Control: AC.L2-3.1.3, which mandates that access to sensitive media be limited to authorized personnel only. Effective implementation of this control is crucial for safeguarding sensitive information and maintaining compliance with the Cybersecurity Maturity Model Certification (CMMC) framework.

## Policy Statement

The organization shall control and restrict access to digital and non-digital media to authorized individuals. This policy applies to all forms of media that contain, transmit, or store sensitive information, including electronic documents, physical documents, and any other forms of media that may be used to handle electronic protected health information (ePHI).

## Scope

This policy applies to all employees, contractors, and third-party vendors who handle digital and non-digital media within the organization. It encompasses all relevant environments, including:

- On-premises systems
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems
- All channels used to create, receive, maintain, or transmit ePHI

## Responsibilities

- **IT Security Manager**: 
  - Ensure implementation of access controls for all media.
  - Conduct **Annual Review** of access control policies.
  
- **Data Owners**:
  - Identify sensitive media and determine access levels.
  - Review access permissions quarterly.

- **All Employees**:
  - Adhere to the guidelines set forth in this policy.
  - Report any unauthorized access attempts to the IT Security Manager.

## Evidence Collection Methods

### 1. REQUIREMENT:
Access to digital and non-digital media must be restricted to authorized individuals only.

### 2. MACHINE ATTESTATION:
- Use OSquery to monitor and report on access logs for digital media. Set up automated alerts for any unauthorized access attempts.
- Implement role-based access controls (RBAC) in all systems handling ePHI to ensure that only authorized personnel can access sensitive data.

### 3. HUMAN ATTESTATION:
- The Data Owner must sign an access control approval form for each new media item that requires restricted access, which will be ingested into Surveilr as evidence of compliance.
- Conduct quarterly reviews of access permissions, documented in a report signed by the IT Security Manager.

## Verification Criteria

- Successful machine attestation will require that 100% of access logs are monitored and reported on a **weekly** basis.
- Human attestation must be documented quarterly, with a target of 100% completion of access reviews and signed approval forms.
- Any unauthorized access attempts must trigger an immediate investigation, with findings reported within 48 hours.

## Exceptions

Any exceptions to this policy must be documented formally and approved by the IT Security Manager. Exceptions must include:

- Rationale for the exception
- Duration of the exception
- A plan for remediation or review

## Lifecycle Requirements

- **Data Retention**: All access logs and attestation records must be retained for a minimum of **three years**.
- Policies must undergo an **Annual Review** to ensure relevance and compliance with current regulations.

## Formal Documentation and Audit

All workforce members must acknowledge their understanding and compliance with this policy by signing a compliance attestation form. Comprehensive audit logging must be maintained for all critical actions related to media access. Exceptions must be formally documented, reviewed, and approved.

## References

### References
None