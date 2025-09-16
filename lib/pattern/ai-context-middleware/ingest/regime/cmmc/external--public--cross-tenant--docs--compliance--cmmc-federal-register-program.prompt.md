---
id: federal-register-cmmc-final-rule-2024-10-15
title: "Federal Register: CMMC Program Final Rule (32 CFR Part 170)"
summary: "Official Department of Defense final rule establishing the Cybersecurity Maturity Model Certification (CMMC) Program requirements, effective December 16, 2024"
artifact-nature: policy
function: legal
audience: external
visibility: public
tenancy: cross-tenant
tenant-id: null
confidentiality: public
product:
  name: cmmc-program
  version: ""
  features: ["level-1-self", "level-2-self", "level-2-c3pao", "level-3-dibcac", "fci-protection", "cui-protection", "nist-800-171", "nist-800-172", "assessment-requirements", "poa-m", "affirmation"]
provenance:
  source-uri: "https://www.federalregister.gov/documents/2024/10/15/2024-22905/cybersecurity-maturity-model-certification-cmmc-program"
  reviewers: ["user:legal-team", "user:compliance-officer", "user:regulatory-affairs"]
merge-group: "regime-cmmc"
order: 2
---
# DoD Cybersecurity Maturity Model Certification (CMMC) Program

## What is the CMMC Program?

The Department of Defense (DoD) Cybersecurity Maturity Model Certification (CMMC) Program is a mandatory cybersecurity framework established under 32 CFR Part 170 that verifies defense contractors and subcontractors have implemented required security measures to protect Federal Contract Information (FCI) and Controlled Unclassified Information (CUI).

## Key Program Purpose and Goals

- **Move away from self-attestation**: Replace contractor self-reporting with verified assessments
- **Protect sensitive information**: Safeguard FCI and CUI processed by defense contractors
- **Strengthen Defense Industrial Base**: Enhance cybersecurity across the entire defense supply chain
- **Risk-based approach**: Apply appropriate security levels based on information sensitivity
- **Third-party verification**: Use independent assessors to validate compliance

## CMMC Certification Levels and Requirements

### Level 1 (Self-Assessment)

- **Information Type**: Federal Contract Information (FCI)
- **Requirements**: 15 basic security requirements from FAR clause 52.204-21
- **Assessment**: Annual self-assessment by the organization
- **Validation**: All requirements must be fully met (no exceptions)
- **Use Case**: Basic federal contracts involving FCI

### Level 2 (Self-Assessment or Third-Party)

- **Information Type**: Controlled Unclassified Information (CUI)
- **Requirements**: 110 security requirements from NIST SP 800-171 R2
- **Assessment Options**:
  - Self-assessment every 3 years
  - Third-party assessment by C3PAO every 3 years
- **Flexibility**: 80% minimum score allowed with Plan of Action & Milestones (POA&M)
- **Remediation**: 180 days to address deficiencies
- **Use Case**: Defense contracts involving CUI processing

### Level 3 (Government Assessment)

- **Information Type**: CUI for critical programs/high-value assets
- **Requirements**: Level 2 requirements PLUS 24 enhanced requirements from NIST SP 800-172
- **Assessment**: Government-conducted by DCMA DIBCAC every 3 years
- **Prerequisites**: Must first achieve Level 2 (C3PAO) certification
- **Use Case**: High-sensitivity defense contracts and critical programs

## Implementation Timeline (4-Phase Rollout)

- **Phase 1**: Self-assessments begin (effective December 16, 2024)
- **Phase 2**: Level 2 C3PAO assessments required (Year 2)
- **Phase 3**: Level 3 DIBCAC assessments implemented (Year 3)
- **Phase 4**: Full program implementation across all applicable contracts (Year 4)

## Key Stakeholder Ecosystem

### CMMC Accreditation Body (AB)

- Single authorized entity overseeing the program
- Accredits Third-Party Assessment Organizations (C3PAOs)
- Must comply with international accreditation standards

### C3PAOs (CMMC Third-Party Assessment Organizations)

- Licensed organizations conducting Level 2 certification assessments
- Must employ certified assessors and meet strict security requirements
- Subject to government oversight and quality assurance

### DCMA DIBCAC

- Defense Contract Management Agency's cybersecurity assessment center
- Conducts Level 3 assessments and oversees high-risk contractor evaluations
- Maintains assessment records and certification tracking

## Compliance Requirements for Contractors

### Assessment Scoping

- Identify all systems processing, storing, or transmitting FCI/CUI
- Categorize assets as Contractor Risk Managed, Security Protection, or Specialized Assets
- Include External Service Providers (ESPs) and Cloud Service Providers (CSPs)
- Document assessment boundaries and information flows

### Certification Process

1. **Implementation**: Deploy required security controls
2. **Assessment**: Conduct or undergo required assessment type
3. **Scoring**: Achieve minimum score thresholds
4. **POA&M**: Document and remediate any deficiencies within 180 days
5. **Affirmation**: Submit annual compliance attestations
6. **Maintenance**: Maintain certification through reassessments and ongoing compliance

### Subcontractor Flow-Down

- Prime contractors must ensure subcontractors achieve appropriate CMMC levels
- Requirements flow down based on information types handled
- Verification of subcontractor compliance required before contract award

## Regulatory Integration

- **Complements existing requirements**: Works alongside FAR 52.204-21 and DFARS 252.204-7012
- **NIST framework alignment**: Built on established NIST SP 800-171 and 800-172 standards
- **Contract integration**: CMMC requirements specified in solicitations via 48 CFR Part 204
- **SPRS integration**: Results tracked in Supplier Performance Risk System

## Business Impact Considerations

- **Market access**: CMMC certification required for contract eligibility
- **Cost implications**: Assessment costs, remediation expenses, ongoing maintenance
- **Timeline planning**: Multi-year certification cycles requiring advance preparation
- **Supply chain**: All tiers of subcontractors must achieve appropriate certification levels
- **Competitive advantage**: Early compliance can provide market differentiation

## Who Must Comply?

- Defense contractors processing, storing, or transmitting FCI or CUI
- Subcontractors at all tiers handling sensitive information
- Cloud service providers and external service providers supporting defense contracts
- Organizations seeking to participate in the Defense Industrial Base

This summary provides the essential framework for understanding CMMC requirements, implementation approaches, and business implications for defense industry stakeholders.
