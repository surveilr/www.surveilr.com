---
id: dod-cmmc-101-overview-2025
title: "DoD CMMC-101: Cybersecurity Maturity Model Certification Overview"
summary: "Official Department of Defense CMMC Program overview presentation covering requirements, implementation phases, ecosystem, and assessment procedures"
artifact-nature: system-instruction
function: support
audience: external
visibility: public
tenancy: cross-tenant
tenant-id: null
confidentiality: public
product:
  name: cmmc-program
  version: "2.0"
  features: ["cmmc-levels", "phased-implementation", "assessment-framework", "ecosystem-overview", "scoring-methodology", "poa-m", "standards-acceptance"]
provenance:
  source-uri: "https://dodcio.defense.gov/Portals/0/Documents/CMMC/CMMC-101.pdf"
  reviewers: ["user:cmmc-pmo", "user:dod-cio-office"]
merge-group: "regime-cmmc"
order: 3
---

# CMMC Model Overview

## What is the CMMC Model and what are its specific security requirements?

**The CMMC (Cybersecurity Maturity Model Certification) Model** is a structured cybersecurity framework consisting of 149 total security requirements across 14 domains, designed to protect Federal Contract Information (FCI) and Controlled Unclassified Information (CUI) within the Defense Industrial Base (DIB).

### Framework Structure
The CMMC Model incorporates security requirements from three foundational sources:
- **FAR 52.204-21**: Basic safeguarding requirements for FCI (15 requirements)
- **NIST SP 800-171 Rev 2**: Protecting CUI in nonfederal systems (110 requirements)  
- **NIST SP 800-172**: Enhanced security requirements for CUI (24 selected requirements with DoD parameters)

### Three-Level Architecture
**Level 1 (15 Requirements)**: Basic safeguarding of Federal Contract Information through FAR Clause 52.204-21 requirements. Assessment is binary (MET/NOT MET) with no scoring methodology.

**Level 2 (110 Requirements)**: Protection of Controlled Unclassified Information implementing all NIST SP 800-171 Rev 2 requirements. Uses point-based scoring (1, 3, or 5 points per requirement) with minimum passing score of 88 out of 110 total points.

**Level 3 (24 Requirements)**: Enhanced protection against Advanced Persistent Threats (APTs) using selected NIST SP 800-172 requirements with DoD-defined parameters. Requires perfect Level 2 score (110) as prerequisite, plus all Level 3 requirements (1 point each, total 24).

### Security Domains (14 Total)
1. **Access Control (AC)**: User authentication, authorization, and system access controls
2. **Awareness & Training (AT)**: Security education and role-based training programs
3. **Audit & Accountability (AU)**: System logging, monitoring, and audit record management
4. **Configuration Management (CM)**: Baseline configurations, change control, and system inventory
5. **Identification & Authentication (IA)**: User identity verification and multifactor authentication
6. **Incident Response (IR)**: Cybersecurity incident handling and response capabilities
7. **Maintenance (MA)**: System maintenance controls and equipment sanitization
8. **Media Protection (MP)**: Physical and digital media safeguarding and disposal
9. **Personnel Security (PS)**: Background screening and personnel risk management
10. **Physical Protection (PE)**: Physical access controls and facility security
11. **Risk Assessment (RA)**: Vulnerability scanning, threat hunting, and risk analysis
12. **Security Assessment (CA)**: Security control testing and system security planning
13. **System & Communications Protection (SC)**: Network security, encryption, and boundary protection
14. **System & Information Integrity (SI)**: Malware protection, system monitoring, and flaw remediation

### Key Implementation Details
**Requirement Identification Format**: Each requirement uses format DD.L#-REQ where DD is the domain abbreviation, L# is the level number, and REQ is the source requirement identifier.

**DoD-Approved Parameters**: Level 3 requirements include specific DoD-defined selections and parameters (indicated by underlining in official documentation) that modify base NIST SP 800-172 requirements.

**Scalability**: Organizations can implement CMMC for entire enterprise networks or specific enclaves, depending on where FCI/CUI is processed, stored, or transmitted.

**Compliance Alignment**: The model maintains alignment with existing DoD cybersecurity requirements under DFARS clauses 252.204-7012, 252.204-7019, and 252.204-7020, while introducing the new DFARS clause 252.204-7021.

### Assessment Requirements by Level
- **Level 1**: Covers basic safeguarding like authorized access control, media disposal, physical access limits, boundary protection, and malicious code protection
- **Level 2**: Comprehensive CUI protection including multifactor authentication, FIPS-validated cryptography, incident response capabilities, and network security controls
- **Level 3**: Advanced capabilities such as 24/7 Security Operations Center, threat hunting, penetration testing, advanced threat awareness training, and supply chain risk management

The CMMC Model serves as the technical foundation for the broader CMMC Program, providing the specific security requirements that defense contractors must implement to achieve certification levels required for DoD contract awards.
