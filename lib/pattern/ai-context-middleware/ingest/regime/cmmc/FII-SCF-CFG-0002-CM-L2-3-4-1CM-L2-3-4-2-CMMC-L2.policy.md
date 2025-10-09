---
title: "Secure Baseline Configuration Management Policy"
weight: 1
description: "Establishes secure baseline configurations for technology platforms to enhance security and ensure compliance with CMMC controls."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "CM.L2-3.4.1
CM.L2-3.4.2"
control-question: "Does the organization develop, document and maintain secure baseline configurations for technology platforms that are consistent with industry-accepted system hardening standards?"
fiiId: "FII-SCF-CFG-0002"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

# Configuration Management Policy for Secure Baseline Configurations

## Introduction
This policy establishes the requirements for developing, documenting, and maintaining secure baseline configurations for technology platforms within the organization. It aims to ensure compliance with industry-accepted system hardening standards, thereby enhancing the security posture of our systems and data.

## Policy Statement
The organization shall develop, document, and maintain secure baseline configurations for all technology platforms, including cloud-hosted systems, SaaS applications, and third-party vendor systems, in accordance with industry standards. These configurations will be consistently reviewed and updated to mitigate vulnerabilities and maintain compliance with **CMMC** controls: **CM.L2-3.4.1** and **CM.L2-3.4.2**.

## Scope
This policy applies to:
- All technology platforms owned or operated by the organization, including:
  - On-premises servers
  - Cloud-hosted environments
  - SaaS applications
  - Third-party vendor systems
- All personnel responsible for managing, configuring, or overseeing these systems.

## Responsibilities
- **IT Security Team**: 
  - Develop baseline configurations for all platforms **(Quarterly)**.
  - Conduct assessments of existing configurations **(Monthly)**.

- **System Administrators**: 
  - Implement baseline configurations on systems and ensure compliance **(Ongoing)**.
  - Document deviations and corrective actions **(As needed)**.

- **Compliance Officer**: 
  - Review and update the policy and ensure adherence to regulatory requirements **(Annual Review)**.

## Evidence Collection Methods

1. **REQUIREMENT**: Maintain secure baseline configurations.
   
   **MACHINE ATTESTATION**:
   - Utilize tools such as OSquery to automate the collection of configuration data and compare against established baselines.
   - Implement API integrations to gather logs from configuration management tools, allowing for real-time compliance monitoring.

   **HUMAN ATTESTATION**:
   - System Administrators must complete a configuration compliance checklist, documenting any deviations and corrective measures taken. This checklist will be ingested into Surveilr for record-keeping.

2. **REQUIREMENT**: Conduct regular reviews of configurations.

   **MACHINE ATTESTATION**:
   - Schedule automatic scans via configuration management tools to identify compliance status and generate reports that highlight deviations from the baseline configuration.

   **HUMAN ATTESTATION**:
   - The IT Security Team must produce a quarterly report detailing findings and corrective actions taken, which will be submitted to Surveilr.

## Verification Criteria
- Compliance will be validated based on the successful completion of the following **KPIs/SLAs**:
  - **90%** of systems must comply with the secure baseline configurations at all times.
  - All configuration checks must be completed as per the defined schedule (**Monthly** for assessments, **Quarterly** for baseline updates).
  - Documentation of deviations must occur within **24 hours** of identification.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer. Exceptions should detail the reason for deviation and the mitigation strategy in place.

## Lifecycle Requirements
- **Data Retention**: Evidence and logs must be retained for a minimum of **3 years**.
- **Annual Review**: This policy and its associated procedures must undergo a formal review at least **once a year** to ensure continued relevance and compliance.

## Formal Documentation and Audit
All personnel must acknowledge their understanding and compliance with this policy through documented attestation. Comprehensive audit logs will be maintained for all critical actions, including configuration changes and any deviations from baseline configurations.

### References
None