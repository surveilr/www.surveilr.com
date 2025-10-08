---
title: "Least Privilege Access Control Policy"
weight: 1
description: "Implement least privilege access controls to minimize security risks and ensure compliance with CMMC control AC.L2-3.1.5 across all organizational systems."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "AC.L2-3.1.5"
control-question: "Does the organization utilize the concept of least privilege, allowing only authorized access to processes necessary to accomplish assigned tasks in accordance with organizational business functions?"
fiiId: "FII-SCF-IAC-0021"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

# CMMC Compliant Policy Document for Control: AC.L2-3.1.5 (FII: FII-SCF-IAC-0021)

## Introduction
This policy outlines the requirements and procedures necessary to implement the principle of least privilege within the organization. Adopting this principle is crucial for minimizing security risks, ensuring that individuals have only the access necessary to perform their job functions, thereby supporting compliance with CMMC control AC.L2-3.1.5. 

## Policy Statement
The organization is committed to implementing the principle of least privilege by allowing only authorized access to processes that are essential for accomplishing assigned tasks. This commitment fosters a secure environment, mitigating potential risks associated with unauthorized access and ensuring compliance with regulatory standards.

## Scope
This policy applies to all organizational entities and environments, including:
- **Cloud-hosted systems**
- **SaaS applications**
- **Third-party vendor systems**
- **On-premises systems**

## Responsibilities
- **Compliance Officer**: 
  - **Review** access control policies **annually**.
  - **Ensure** alignment with CMMC requirements and organizational standards **quarterly**.
  
- **IT Security**:
  - **Implement** access control measures **monthly**.
  - **Monitor** access logs and detect unauthorized access attempts **daily**.

- **Managers**:
  - **Evaluate** and approve access requests **within 3 business days**.
  - **Conduct** access reviews for their teams **semi-annually**.

## Evidence Collection Methods

### 1. REQUIREMENT
The organization must enforce least privilege access controls, ensuring that users are granted the minimum level of access required for their roles.

### 2. MACHINE ATTESTATION
Utilize Surveilr to automatically log and report:
- User access levels within systems.
- Changes in access permissions.
- Automated alerts for unauthorized access attempts.

### 3. HUMAN ATTESTATION
Conduct regular reviews where managers:
- Validate access levels for their team members.
- Document the review process and findings.
- Submit this documentation into Surveilr for compliance tracking.

## Verification Criteria
To ensure compliance with this policy, the following **KPIs/SLAs** will be monitored:
- Access reviews completed on time (≥95%).
- Unauthorized access attempts detected and reported (≤2%).
- Access requests approved or denied within the stipulated time frame (≥90%).

## Policy Lifecycle Requirements
- **Data Retention**: All access logs and evidence must be retained for a minimum of **6 years**.
- **Annual Review**: This policy must be reviewed and updated at least **annually** to ensure ongoing compliance and relevance.

## Formal Documentation and Audit
- All workforce members must acknowledge and attest to their understanding and compliance with this policy.
- Comprehensive audit logging must be maintained for all critical actions regarding access controls.
- Any exceptions to this policy must be formally documented and approved by the Compliance Officer.

## References
- CMMC Compliance Guidelines
- NIST Special Publication 800-53: Security and Privacy Controls for Information Systems and Organizations
- Organizational Security Policy Document