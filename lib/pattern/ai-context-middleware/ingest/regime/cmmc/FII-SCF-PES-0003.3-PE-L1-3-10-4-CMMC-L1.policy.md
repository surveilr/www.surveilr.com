---
title: "Access Logging Policy for Physical Security Control"
weight: 1
description: "Establishes a framework for logging access attempts at controlled points to enhance security, accountability, and regulatory compliance."
publishDate: "2025-10-06"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "PE.L1-3.10.4"
control-question: "Does the organization generate a log entry for each access attempt through controlled ingress and egress points?"
fiiId: "FII-SCF-PES-0003.3"
regimeType: "CMMC"
cmmcLevel: 1
domain: "Physical & Environmental Security"
category: ["CMMC", "Level 1", "Compliance"]
---

# Policy Document for Control: PE.L1-3.10.4  
**FII: FII-SCF-PES-0003.3**

## 1. Introduction  
The purpose of this policy is to establish a framework for generating log entries for all access attempts through controlled ingress and egress points within the organization. This policy is crucial for maintaining the integrity of our Physical & Environmental Security posture, ensuring accountability, and facilitating compliance with regulatory requirements. By documenting access attempts, we can enhance security monitoring, investigate incidents, and demonstrate compliance with established standards.

## 2. Policy Statement  
The organization mandates the generation of log entries for each access attempt through controlled ingress and egress points. This policy reflects our commitment to safeguarding sensitive information and enhancing security measures across all facilities and environments.

## 3. Scope  
This policy applies to all employees, contractors, and third-party vendors who access controlled ingress and egress points within the organization. It encompasses all relevant environments, including cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit electronic Protected Health Information (ePHI).

## 4. Responsibilities  
- **Compliance Officers**: Review access logs **monthly** to ensure compliance with this policy.
- **IT Security Personnel**: Monitor and maintain logging systems **continuously** to ensure they capture all access attempts.
- **Facility Managers**: Conduct quarterly audits of the access logs and provide reports to the Compliance Officers.

These roles must align their activities with the organizational plans for escalation and recovery, ensuring that any anomalies are documented and addressed promptly.

## 5. Evidence Collection Methods  
1. **REQUIREMENT**: All access attempts through controlled ingress and egress points must generate log entries that capture the date, time, user identity, and access outcome (successful/unsuccessful).
   
2. **MACHINE ATTESTATION**: Implement automated logging solutions that seamlessly integrate with existing systems to capture access attempts in real-time. This includes configuring logging systems to ensure that all events are recorded and stored securely.

3. **HUMAN ATTESTATION**: Facility Managers must review and sign off on log summaries **quarterly**. These summaries, along with metadata, should be uploaded to Surveilr for attestation.

## 6. Verification Criteria  
Compliance with this policy will be validated through the following **KPIs/SLAs**:
- **100%** of access attempts logged within **1 hour** of the attempt.
- **Monthly** reviews of log entries should demonstrate that all attempts are recorded accurately.

## 7. Exceptions  
Any exceptions to this policy must be documented and approved by the Compliance Officer. The exception documentation process must include the reason for the exception and the duration that the exception will be in effect.

## 8. Lifecycle Requirements  
Log entries must be retained for a minimum of **6 years** to comply with regulatory requirements. This policy will undergo a formal **annual review** to ensure its relevance and effectiveness, incorporating any necessary updates.

## 9. Formal Documentation and Audit  
All workforce members must acknowledge their understanding and compliance with this policy. Comprehensive audit logging must be maintained for all critical actions related to access attempts. Any documented exceptions must also be formally recorded and reviewed during audits.

## 10. References  
CMMC Control PE.L1-3.10.4; FII-SCF-PES-0003.3.