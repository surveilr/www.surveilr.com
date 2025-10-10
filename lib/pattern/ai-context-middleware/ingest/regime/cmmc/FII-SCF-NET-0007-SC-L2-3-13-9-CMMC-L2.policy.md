---
title: "Network Session Termination Security Policy"
weight: 1
description: "Establishes guidelines for automatically terminating network sessions to enhance security and reduce unauthorized access risks."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "SC.L2-3.13.9"
control-question: "Does the organization terminate network connections at the end of a session or after an organization-defined time period of inactivity?"
fiiId: "FII-SCF-NET-0007"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# Network Session Termination Policy

## 1. Introduction
The purpose of this policy is to establish guidelines for the termination of network connections at the end of a session or after a defined period of inactivity. This is significant in ensuring the security of sensitive information by reducing the risk of unauthorized access and potential data breaches. By implementing effective session termination practices, the organization aims to uphold the integrity and confidentiality of its network environments.

## 2. Policy Statement
The organization mandates the termination of network connections automatically at the end of a session or after a predefined period of inactivity. This policy is designed to safeguard sensitive information and ensure compliance with industry standards, thereby enhancing the overall security posture of the organization.

## 3. Scope
This policy applies to all employees, contractors, and third-party vendors utilizing the organization's network resources. It encompasses all environments including cloud-hosted systems, Software as a Service (SaaS) applications, and third-party vendor systems. Additionally, it covers all channels used to create, receive, maintain, or transmit sensitive information.

## 4. Responsibilities
- **IT Security Team**: Monitor compliance with session termination practices **Weekly**.
- **Network Administrators**: Configure session timeout settings across all systems **Quarterly**.
- **Compliance Officers**: Conduct audits of session termination practices **Annually**.
- **Employees**: Log off from systems after completing tasks **Immediately**.

## 5. Evidence Collection Methods
1. **REQUIREMENT**: The control requires organizations to terminate network connections at the end of a session or after a defined period of inactivity.
2. **MACHINE ATTESTATION**: Implement automated monitoring tools that log session activities and timeout events. Use scripts to verify compliance with session termination policies and generate reports for review.
3. **HUMAN ATTESTATION**: Employees must complete a session termination acknowledgment form and submit it to the IT Security Team. The forms will be collected and ingested into Surveilr via a secure upload process.

## 6. Verification Criteria
Compliance will be validated against established **KPIs/SLAs** that measure the effectiveness of session termination practices. The organization will consider a compliance rate of 95% or higher as satisfactory, with specific metrics tracking session timeout occurrences and user logoff reports.

## 7. Exceptions
Any exceptions to this policy must be documented and approved by the IT Security Team. Requests for exceptions should include justification and will be reviewed on a case-by-case basis.

## 8. Lifecycle Requirements
All evidence and logs related to session termination must be retained for a minimum of **Data Retention** period of 12 months. The policy itself is subject to an **Annual Review** to ensure its effectiveness and relevance to changing security landscapes.

## 9. Formal Documentation and Audit
All workforce members must acknowledge and attest to their understanding and compliance with this policy. Comprehensive audit logging will be maintained for all critical actions related to session termination, and formal documentation of all exceptions must be retained.

## 10. References
- CMMC Control SC.L2-3.13.9