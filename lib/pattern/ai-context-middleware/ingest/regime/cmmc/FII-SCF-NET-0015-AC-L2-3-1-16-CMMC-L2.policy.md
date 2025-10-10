---
title: "Wireless Access Security and Monitoring Policy"
weight: 1
description: "Establishes guidelines to control authorized wireless access and monitor unauthorized connections, ensuring network security and data protection."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.16"
control-question: "Does the organization control authorized wireless usage and monitor for unauthorized wireless access?"
fiiId: "FII-SCF-NET-0015"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# Wireless Usage and Monitoring Policy

## Introduction  
This policy aims to establish a framework for controlling authorized wireless usage and monitoring unauthorized access within the organization. With the increasing reliance on wireless technologies, it is crucial to ensure that only approved devices connect to organizational networks. This policy supports the organization's commitment to maintaining network security and safeguarding sensitive data against unauthorized access.

## Policy Statement  
The organization strictly prohibits unauthorized wireless access and mandates the use of approved wireless devices for any network connectivity. All personnel must adhere to established procedures for monitoring wireless access to ensure compliance and protect organizational resources.

## Scope  
This policy applies to all employees, contractors, and third-party vendors operating within the organization. It encompasses all environments, including:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems
- Any channels used to create, receive, maintain, or transmit data

## Responsibilities  
- **Compliance Officer**: Quarterly review of access controls related to wireless usage.  
- **IT Security**: Daily monitoring of wireless traffic and unauthorized access attempts.  
- **Network Administrator**: Weekly audits of wireless device registrations and compliance with access policies.  
- **Department Managers**: Monthly verification of authorized devices within their teams.

## Evidence Collection Methods  

### 1. REQUIREMENT  
The organization must control authorized wireless access by ensuring only approved devices can connect to the network.

### 2. MACHINE ATTESTATION  
Utilize OSquery to monitor authorized wireless device connections and generate automated reports for compliance verification.

### 3. HUMAN ATTESTATION  
The IT manager will certify a monthly review of wireless access logs. This documentation will be signed and uploaded to Surveilr for record-keeping.

## Verification Criteria  
Compliance validation will be measured against the following **KPIs/SLAs**:
- Percentage of authorized devices connected to the network (target: **95%**).
- Number of unauthorized access attempts detected and mitigated (target: **0** incidents per month).
- Timeliness of access control reviews (target: completed within **15 days** of the scheduled date).

## Exceptions  
Any exceptions to this policy must be approved by the Compliance Officer. A formal request must be submitted detailing the rationale for the exception and any associated risks.

## Lifecycle Requirements  
- **Data Retention**: All evidence and logs related to wireless access must be retained for a minimum of **6 years**.  
- **Annual Review**: This policy will be reviewed at least **annually** to ensure its effectiveness and relevance.

## Formal Documentation and Audit  
All workforce members must acknowledge their understanding of this policy. Comprehensive audit logging will be maintained for critical actions related to wireless access, and documentation will be required for all approved exceptions.

## References  
[Cybersecurity Maturity Model Certification (CMMC)](https://www.acq.osd.mil/cmmc/)  
[NIST Special Publication 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)  
[OSquery](https://osquery.io/)