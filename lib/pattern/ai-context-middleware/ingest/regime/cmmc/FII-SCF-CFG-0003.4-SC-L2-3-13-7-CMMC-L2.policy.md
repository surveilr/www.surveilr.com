---
title: "Remote Device Split Tunneling Prevention Policy"
weight: 1
description: "Establishes guidelines to prevent split tunneling on remote devices, ensuring secure access to organizational resources and protecting sensitive data."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "SC.L2-3.13.7"
control-question: "Does the organization prevent split tunneling for remote devices unless the split tunnel is securely provisioned using organization-defined safeguards?

Prevent split tunneling for remote devices unless the split tunnel is securely provisioned using organization-defined safeguards?"
fiiId: "FII-SCF-CFG-0003.4"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

# Policy for Preventing Split Tunneling on Remote Devices

## Introduction
The purpose of this policy is to establish clear guidelines for preventing split tunneling for remote devices within the organization. Split tunneling, which allows simultaneous access to both local and remote networks, poses significant security risks by exposing sensitive data to potential interception. Preventing unsanctioned split tunneling is crucial for maintaining compliance with security standards and protecting sensitive information across all organizational environments.

## Policy Statement
The organization is committed to preventing split tunneling for remote devices unless securely provisioned with organization-defined safeguards. This commitment ensures that all remote connections are monitored and controlled, thus mitigating risks associated with unauthorized access to sensitive data.

## Scope
This policy applies to all remote devices accessing organizational resources, encompassing:
- Cloud-hosted systems
- SaaS applications
- Third-party vendor systems (Business Associates)
- All channels used to create, receive, maintain, or transmit sensitive data

## Responsibilities
- **IT Security**: Daily review of tunnel configurations to ensure compliance.
- **Network Administrators**: Weekly monitoring of network traffic to detect unauthorized split tunneling attempts.
- **Compliance Officer**: Quarterly policy approval and annual review of compliance metrics.
- **User Training Coordinator**: Semi-annual training sessions for all employees on the importance of preventing split tunneling.

## Evidence Collection Methods
1. **REQUIREMENT**: The organization mandates the prevention of split tunneling for remote devices.
2. **MACHINE ATTESTATION**: Automated tools will be employed to monitor network configurations and routing tables, ensuring that any split tunneling is identified and logged in real-time.
3. **HUMAN ATTESTATION**: Management will conduct regular reviews and document secure tunnel provisioning processes, maintaining records for compliance verification.

## Verification Criteria
Compliance will be validated through defined **KPIs/SLAs**, including:
- 100% of remote connections must be reviewed weekly for split tunneling configurations.
- 0% unauthorized split tunneling incidents reported monthly.
- Annual training completion rate for employees must be at least 95%.

## Exceptions
Exceptions to this policy may be granted under specific conditions, such as business necessity. Documentation required for exception approval includes:
- A formal request outlining the justification for the exception
- Risk assessment demonstrating the mitigated risks associated with the exception

## Lifecycle Requirements
- **Data Retention**: All logs and evidence of compliance must be retained for a period of 6 years.
- **Annual Review**: This policy will undergo a mandatory annual review to ensure relevance and effectiveness in mitigating split tunneling risks.

## Formal Documentation and Audit
All workforce members must acknowledge and attest to their understanding and compliance with this policy. Comprehensive audit logging will be maintained for all critical actions related to remote connections, and formal documentation will be required for any exceptions granted.

### References
None