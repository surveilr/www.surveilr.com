---
title: "Firewall and Router Security Configuration Policy"
weight: 1
description: "Establishes a default deny configuration for firewalls and routers to enhance network security by permitting only authorized traffic."
publishDate: "2025-10-10"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "SC.L2-3.13.6"
control-question: "Does the organization configure firewall and router configurations to deny network traffic by default and allow network traffic by exception (e.g., deny all, permit by exception)?"
fiiId: "FII-SCF-NET-0004.1"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Network Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# Firewall and Router Configuration Policy

## Introduction
The purpose of this policy is to establish a framework for configuring firewall and router settings within the organization, ensuring a robust security posture against unauthorized access and network threats. By implementing a default deny configuration, the organization can effectively manage network traffic, minimizing risks associated with vulnerabilities and potential exploits. This policy aligns with the CMMC control SC.L2-3.13.6, reinforcing our commitment to maintaining a secure network environment.

## Policy Statement
The organization shall configure all firewall and router settings to deny network traffic by default and allow network traffic by exception. This principle of least privilege ensures that only authorized traffic is permitted, thereby enhancing the security of the network infrastructure.

## Scope
This policy applies to all firewalls and routers operated within the organization, including but not limited to:
- On-premises network devices
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems

## Responsibilities
- **Network Engineers**: Configure and maintain firewall and router settings to comply with this policy. **[Configure] [As needed]**
- **Security Compliance Team**: Monitor compliance with the policy and conduct regular audits. **[Audit] [Quarterly]**
- **IT Management**: Review and approve any exceptions to the policy. **[Review] [As needed]**
- **All Employees**: Acknowledge understanding of this policy and report any observed violations. **[Acknowledge] [Annually]**

## Evidence Collection Methods
1. **REQUIREMENT**: The organization mandates that all firewall and router configurations shall be set to deny all network traffic by default, allowing only explicitly permitted traffic.
   
2. **MACHINE ATTESTATION**: Compliance will be validated using configuration management tools that automatically monitor and report on firewall and router settings. These tools will generate alerts for any deviations from the default deny configuration.

3. **HUMAN ATTESTATION**: Network engineers shall provide signed validation reports confirming that all configurations adhere to the policy. These reports will be submitted on a quarterly basis to the Security Compliance Team.

## Verification Criteria
Compliance with this policy will be evaluated using the following SMART criteria:
- **Specific**: All firewalls and routers must have default deny configurations.
- **Measurable**: At least 95% of devices must be validated as compliant during quarterly audits.
- **Achievable**: Configuration management tools must be implemented and operational across all systems.
- **Relevant**: This policy aligns with the organization's overall security strategy.
- **Time-bound**: Compliance reports must be submitted within one week following each quarterly audit.

## Exceptions
Any exceptions to this policy must be formally requested by submitting a request to IT Management. The request must include justification for the exception and potential impacts on network security. Exceptions will be evaluated on a case-by-case basis.

## Lifecycle Requirements
- **Data Retention**: Evidence of compliance, including configuration logs and validation reports, must be retained for a minimum of three years.
- **Annual Review**: This policy shall undergo an annual review to ensure its continued relevance and effectiveness in addressing network security needs.

## Formal Documentation and Audit
All workforce members must acknowledge their understanding of this policy through a formal documentation process. Additionally, comprehensive audit logs of all critical actions related to firewall and router configurations must be maintained to ensure traceability and accountability.

## References
- [CMMC Control SC.L2-3.13.6](https://www.acq.osd.mil/cmmc/) 
- [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) 
- [CIS Controls](https://www.cisecurity.org/controls/)