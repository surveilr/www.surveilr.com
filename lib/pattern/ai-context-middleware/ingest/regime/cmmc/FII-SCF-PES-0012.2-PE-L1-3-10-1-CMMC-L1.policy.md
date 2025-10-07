---
title: "Printer Access Control and Compliance Policy"
weight: 1
description: "Implement access controls to printers and output devices, ensuring only authorized personnel retrieve sensitive documents and maintain compliance with CMMC standards."
publishDate: "2025-10-06"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "PE.L1-3.10.1"
control-question: "Does the organization restrict access to printers and other system output devices to prevent unauthorized individuals from obtaining the output?"
fiiId: "FII-SCF-PES-0012.2"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 1", "Compliance"]
---

## Introduction

This policy outlines the requirements for restricting access to printers and other system output devices to prevent unauthorized individuals from obtaining sensitive output. Compliance with this document ensures adherence to CMMC Control PE.L1-3.10.1 and is crucial for protecting sensitive information within the organization. 

## Policy Statement

The organization shall implement access controls to printers and other output devices to ensure that only authorized personnel can retrieve printed documents. This policy mandates both machine and human attestation methods to ensure a robust compliance structure.

## Scope

This policy applies to:
- All organizational facilities housing printers and output devices.
- All cloud-hosted systems and SaaS applications that utilize printing services.
- All third-party vendor systems that interact with organizational output devices.

## Responsibilities

- **Facilities Manager**: Ensure compliance with access control policies for printers and output devices.
- **IT Security Team**: Implement machine attestation methods and monitor compliance.
- **All Employees**: Acknowledge understanding of the policy and follow access controls.

## Evidence Collection Methods

### Machine Attestation
- Utilize **OSquery** to collect access logs from printers to track who accessed the devices and when.
- Implement automated alerts for any unauthorized access attempts to output devices.

### Human Attestation
- The Facilities Manager must sign the quarterly access control report, which includes a summary of access logs and violations. This report will be uploaded to Surveilr with relevant metadata, including the date of acknowledgment and the individuals involved.

## Verification Criteria

- Access logs from printers must be reviewed monthly, with 100% of logs validated for compliance.
- Human attestations must be documented and submitted within **5 business days** of the quarterly review.
- Any unauthorized access incidents must be reported and investigated within **24 hours**.

## Exceptions

Any exceptions to this policy must be formally documented and approved by the IT Security Team. Documentation should include:
- The reason for the exception.
- Duration of the exception.
- Any mitigating controls put in place.

## Lifecycle Requirements

- **Data Retention**: Access logs must be retained for a minimum of 2 years.
- An **Annual Review** of access control effectiveness must be conducted to ensure ongoing compliance and to update policies as necessary.

## Formal Documentation and Audit

All workforce members must acknowledge understanding and compliance with this policy through a digital signature on Surveilr. 
- Comprehensive audit logging is required for critical actions, including access to sensitive output.
- Any exceptions must also be formally documented, including the approval process and relevant dates.

## References

None.