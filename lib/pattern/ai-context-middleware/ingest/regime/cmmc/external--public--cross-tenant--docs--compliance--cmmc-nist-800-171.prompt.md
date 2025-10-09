---
id: dod-cmmc-organization-defined-parameters-nist-sp800-171-2025
title: "DoD Organization-Defined Parameters for NIST SP 800-171 Revision 3"
summary: "Memorandum specifying DoD-mandated organization-defined parameter (ODP) values for selected NIST SP 800-171 Rev. 3 security requirements to ensure consistency and facilitate contractor tailoring"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
product:
  name: cmmc-program
  version: "
  features: ["organization-defined-parameters", "nist-sp-800-171-rev-3", "ODP-values", "tailoring-guidance"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/OrgDefinedParmsNISTSP800-171.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 17
---
# Department of Defense Organization-Defined Parameters for NIST SP 800-171 Revision 3

## What are Organization Defined Parameters (ODPs) and why are they important for NIST SP 800-171 compliance?

Organization Defined Parameters (ODPs) are customizable security control values within NIST SP 800-171 Revision 3 that allow organizations to tailor select security controls to their specific security requirements and risk management strategies. The Department of Defense has established standardized ODP values to ensure consistent implementation across the Defense Industrial Base, eliminating ambiguity and providing clear compliance benchmarks for defense contractors handling Controlled Unclassified Information (CUI).

**Purpose**: These DoD-defined ODP values serve as policy requirements for contractors, replacing the flexibility of organization-specific customization with mandatory, standardized parameters that ensure uniform security posture across the defense supply chain.

## Development Process and Authority

**Collaborative Development**: DoD established ODP values through input from DoD offices, external government agencies, subject matter experts from University-Affiliated Research Centers, Federally Funded Research and Development Centers, and appropriate industry stakeholders.

**Foundation Sources**: Initial values were derived from existing federal frameworks, ensuring alignment with established government security practices while meeting defense-specific requirements.

**Policy Authority**: These parameters represent DoD policy as established by the Deputy DoD CIO for Cybersecurity and DoD Chief Information Security Officer, making them mandatory for contractors rather than organizational choices.

## Key Access Control ODP Requirements

### System Account Management (3.1.1):

- **Account Inactivity**: Disable accounts after at most 90 days of inactivity
- **Notification Timeframes**: 24 hours for account terminations, transfers, and need-to-know changes
- **Session Logout**: Maximum 24 hours of inactivity, with privileged users logging out at work period end
- **Privileged Account Restrictions**: Limited to only defined and authorized personnel or administrative roles

### Authentication and Access Controls:

- **Invalid Logon Attempts**: Maximum 5 consecutive attempts within 5-minute period, with account lockout for at least 15 minutes
- **Device Lock**: Automatic activation after at most 15 minutes of inactivity
- **Session Termination**: Maximum 24 hours of inactivity, with termination for misbehavior and maintenance
- **Privilege Reviews**: At least every 12 months for role-based access validation

## Critical Security Requirements

### Password and Authentication Management:

- **Password Length**: Minimum 16 characters required
- **Password Composition**: Must not include user account name or full name
- **Password List Updates**: Quarterly updates of compromised password databases
- **Authenticator Refresh**: Never for passwords with MFA, 5 years for hard tokens, 3 years for other authenticators
- **Identifier Reuse Prevention**: At least 10 years before identifier reuse allowed

### Audit and Logging Requirements:

- **Event Types**: Comprehensive logging including authentication events, file operations, privilege escalation, system changes, and device access
- **Audit Review Frequency**: At least weekly analysis of audit records
- **Audit Failure Response**: Near real-time alerts with documentation and incident reporting requirements
- **Time Stamp Granularity**: One second or smaller for audit record timestamps

## Configuration and System Management

### Baseline and Configuration Controls:

- **Configuration Review**: At least every 12 months and after significant incidents
- **Software Inventory Updates**: At least quarterly reviews of authorized software
- **Component Inventory**: Quarterly updates of system component inventories
- **Vulnerability Scanning**: At least monthly with 24-hour update cycles for scan parameters

### Vulnerability Management Timeframes:

- **High-Risk Vulnerabilities**: 30 days for remediation (critical and high severity)
- **Moderate-Risk Vulnerabilities**: 90 days for remediation
- **Low-Risk Vulnerabilities**: 180 days for remediation
- **Security Updates**: Same timeframes apply for security-relevant software and firmware updates

## Training and Personnel Security

### Security Training Requirements:

- **Frequency**: At least every 12 months for both security literacy and role-based training
- **New User Training**: 10 days for privileged users, 30 days for other roles
- **Training Updates**: Following significant incidents or risk changes
- **Incident Response Testing**: At least every 12 months

### Personnel Management:

- **Termination Timeline**: Disable system access within 4 hours of employment termination
- **Facility Access Reviews**: At least every 12 months or after significant incidents
- **Physical Access Log Reviews**: At least every 45 days
- **Rescreening Requirements**: When significant incidents or status changes occur

## Cryptographic and Communications Protection

### Cryptography Requirements:

- **Encryption Standards**: FIPS Validated Cryptography required for CUI confidentiality protection
- **Key Management**: Policy and procedures aligned with latest cryptographic key management guidance
- **Network Session Termination**: Maximum 15 minutes of inactivity before connection termination

### Remote and Collaborative Computing:

- **Remote Device Activation**: Only when enumerated in System Security Plan, no other options exist, and operationally critical
- **High-Risk Location Systems**: No CUI/FCI storage, comprehensive security examination upon return

## External Service Provider Requirements

### Cloud Service Providers:

- **FedRAMP Requirements**: Moderate baseline authorization or equivalent for CUI processing
- **Other External Providers**: Must meet NIST SP 800-171 R2 requirements

### System Media and Device Management:

- **Removable Media**: Prohibit any removable media not managed by or on behalf of the organization
- **Device Authentication**: All devices for identification, where feasible for authentication

## Implementation Guidance Categories

**Four Guidance-Only ODPs**: In specific instances, DoD provides implementation guidance rather than prescriptive values, allowing for organizational flexibility where technical specificity isn't required.

**Risk Assessment and Planning**: At least every 12 months for risk assessments, security requirements assessments, and plan reviews, with updates following significant incidents or risk changes.

**Supply Chain Risk Management**: Minimum requirements for supply chain security integration, resource allocation, control baseline definition, and supplier disclosure requirements.

These standardized ODP values eliminate implementation ambiguity while ensuring defense contractors maintain consistent, robust security postures appropriate for protecting controlled unclassified information within the defense industrial base ecosystem.
