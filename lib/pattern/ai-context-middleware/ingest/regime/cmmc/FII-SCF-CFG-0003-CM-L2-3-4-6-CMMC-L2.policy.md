---
title: "CMMC Non-Essential Services Configuration Policy"
weight: 1
description: "Establishes guidelines to restrict non-essential ports, protocols, and services, enhancing the security of organizational information systems."
publishDate: "2025-10-07"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "CM.L2-3.4.6"
control-question: "Does the organization configure systems to provide only essential capabilities by specifically prohibiting or restricting the use of ports, protocols, and/or services?"
fiiId: "FII-SCF-CFG-0003"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Configuration Management"
category: ["CMMC", "Level 2", "Compliance"]
---

# CMMC Policy Document for Control: CM.L2-3.4.6

## Introduction
This policy establishes guidelines for configuring systems to provide only essential capabilities by specifically prohibiting or restricting the use of ports, protocols, and/or services. Compliance with this policy is critical for maintaining the security of our organization's information systems and ensuring adherence to the CMMC requirements.

## Policy Statement
All systems within the organization, including cloud-hosted systems, SaaS applications, and third-party vendor systems (Business Associates), must be configured to restrict non-essential capabilities. This includes the prohibition or restriction of unnecessary ports, protocols, and services to mitigate security risks.

## Scope
This policy applies to:
- All organizational information systems.
- Cloud-hosted environments.
- SaaS applications utilized by the organization.
- Third-party vendor systems (Business Associates) that interact with organizational data.

## Responsibilities
- **System Administrators:**
  - **Configure** systems to restrict non-essential ports, protocols, and services **monthly**.
  - **Review** configurations against the approved security baseline **quarterly**.
  - **Document** any changes made to system configurations **immediately** after implementation.

- **Compliance Officers:**
  - **Audit** system configurations for compliance with this policy **bi-annually**.
  - **Report** any non-compliance issues to upper management **within 5 business days** of detection.

- **IT Security Team:**
  - **Monitor** system activity logs for usage of prohibited ports, protocols, and services **daily**.
  - **Investigate** any anomalies **within 48 hours** of detection.

## Evidence Collection Methods

### 1. REQUIREMENT:
Configurations must prohibit or restrict the use of non-essential ports, protocols, and services.

### 2. MACHINE ATTESTATION:
- Automated scripts will validate configurations against the approved security baseline and generate a report every **24 hours**.
- Centralized logging will capture all configuration changes, accessible for automated review.

### 3. HUMAN ATTESTATION:
- System Administrators must **submit a signed attestation** form confirming compliance with configuration requirements to Surveilr following each monthly configuration update.
- Attestation must include the date, system name, and specific ports/protocols restricted.

## Verification Criteria
- Compliance is verified through automated reports of system configurations, ensuring non-essential ports, protocols, and services are restricted.
- Non-compliance will be measured against **KPIs/SLAs** including:
  - Configuration review completion within **30 days** of the scheduled date.
  - Anomaly investigations initiated within **48 hours** of detection.

## Exceptions
Any exceptions to this policy must be formally documented and approved by the IT Security Team. Exceptions will be reviewed and assessed for risk and must not expose the organization to undue risk.

## Lifecycle Requirements
- **Data Retention:** All configuration logs and evidence must be retained for a minimum of **2 years**.
- **Annual Review:** This policy must be reviewed and updated at least once per year to ensure continued relevance and compliance with regulatory requirements.

## Formal Documentation and Audit
- All workforce members must acknowledge their understanding and compliance with this policy via a digital attestation form stored in Surveilr.
- Comprehensive audit logging must be maintained for all critical actions related to configuration changes.
- Any approved exceptions must be formally documented and accessible for audit purposes.

## References
None