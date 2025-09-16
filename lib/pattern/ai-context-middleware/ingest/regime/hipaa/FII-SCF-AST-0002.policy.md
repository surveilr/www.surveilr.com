---
title: "HIPAA Asset Inventory Policy"
weight: 10
description: "Mechanisms exist to perform inventories of technology assets that:

        Accurately reflects the current systems, applications and services in use;
        Identifies authorized software products, including business justification details;
        Is at the level of granularity deemed necessary for tracking and reporting;
        Includes organization-defined information deemed necessary to achieve effective property accountability; and
        Is available for review and audit by designated organizational personnel."
publishDate: "2025-09-08"
publishBy: "Compliance Automation Team"
classification: "Confidential"
documentVersion: "v1.0"
documentType: "Policy"
approvedBy: "Chief Compliance Officer"
category: ["HIPAA", "Security", "Asset Management"]
satisfies: ["FII-SCF-AST-0002"]
control-question: "Does the organization perform inventories of technology assets that
        Accurately reflects the current systems, applications and services in use 
        Identifies authorized software products, including business justification details
        Is at the level of granularity deemed necessary for tracking and reporting
        Includes organization-defined information deemed necessary to achieve effective property accountability and
        Is available for review and audit by designated organizational personnel?"
control-id: 164.310(d)(2)(iii)
control-domain: "Asset Management"
SCF-control: "Asset Inventories"
merge-group: "regime-hipaa-asset-inventories"
order: 2

---
# Technology Asset Inventory Policy

## Introduction
This policy establishes requirements for maintaining a complete and accurate inventory of all technology assets within the organization, in compliance with HIPAA §164.310(d)(2)(iii). The inventory must cover systems, applications, services, and authorized software, including business justification details where required. The policy emphasizes automated collection and verification methods (machine attestation) via Surveilr, with supplemental human attestation only when automation is impractical.

---

## Policy Statement
The organization shall maintain an up-to-date inventory of all technology assets, ensuring:
- Accuracy in reflecting all systems, applications, and services in use.
- Identification of authorized software products with associated business justifications.
- Tracking at the appropriate level of granularity required for accountability.
- Inclusion of all organization-defined information necessary for compliance and reporting.
- Availability of inventories for review and audit by designated personnel.

---

## Scope
This policy applies to:
- All organizational technology assets (on-premise and cloud).
- All installed applications and services, whether internally hosted or SaaS.
- All workforce members who deploy, manage, or decommission technology assets.

---

## Responsibilities
- **IT Asset Management Team:** Ensure automated data collection tools are deployed and functioning.
- **System Owners:** Validate the accuracy of inventory records and provide business justifications for approved software.
- **Compliance Office:** Review inventory reports for HIPAA compliance and ensure Surveilr attestation evidence is retained.
- **CISO:** Approve exceptions and oversee policy enforcement.

---

## Evidence Collection Methods

### Machine Attestation (Preferred)
The following automated evidence collection methods shall be implemented:
- **System & Application Inventory:**  
  - Deploy `OSquery` or equivalent on all servers and endpoints to collect hardware identifiers, installed applications, and configuration data.  
  - Configure automated daily ingestion of collected data into Surveilr.  
  - Validate that asset tags, system hostnames, and assigned owners are consistently recorded.

- **Authorized Software Verification:**  
  - Maintain a centralized approved software list in the IT Asset Management System (ITAM).  
  - Use Surveilr to compare ingested OSquery software inventories against the approved list.  
  - Flag discrepancies automatically for compliance review.

- **Cloud & SaaS Services:**  
  - Integrate Surveilr with cloud provider APIs (e.g., AWS Config, Azure Resource Graph, Google Cloud Asset Inventory) to retrieve active services.  
  - Reconcile collected data with internal service registry for completeness.  

- **Granularity & Metadata:**  
  - Enforce ingestion of metadata such as business justification, system owner, and classification level through automated configuration management databases (CMDB).  
  - Ensure Surveilr retains a historical log of inventory changes for audit purposes.

### Human Attestation (When Unavoidable)
Where automation is not feasible, the following human attestation is required:
- **Quarterly Manual Validation:**  
  - IT managers must perform a quarterly review of inventory records for accuracy.  
  - The manager signs a validation report (digital or physical).  
  - The signed report is uploaded into Surveilr with metadata fields: `reviewer name`, `review date`, `scope of review`, and `outcome`.

- **Business Justification for Non-standard Software:**  
  - System Owners must provide written business justification for any non-standard or exception-approved software.  
  - Justifications are documented in an exception request form and uploaded into Surveilr.  

---

## Verification Criteria
Compliance with this policy shall be verified as follows:
- **Automated Checks (Machine Attestation):**
  - Surveilr verifies 100% of registered systems report inventory data daily.
  - Automated comparison detects unauthorized software within 24 hours of installation.
  - Cloud asset API integrations confirm alignment with internal service registry.

- **Manual Checks (Human Attestation):**
  - Quarterly signed review reports are stored in Surveilr with associated metadata.  
  - All exception justifications are documented and traceable to asset records.  

---

## Exceptions
- Exceptions must be approved in writing by the CISO.  
- Approved exceptions must include:  
  - Clear justification for non-compliance.  
  - Risk assessment results.  
  - Mitigation measures.  
- All exception records must be uploaded into Surveilr with appropriate metadata.

---

### _References_
- [HIPAA Security Rule – 45 CFR §164.310(d)(2)(iii)](https://www.ecfr.gov/current/title-45/part-164)  
- [OSquery Documentation](https://osquery.io/)  
- [NIST SP 800-53 Rev. 5 – CM-8 Information System Component Inventory](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)  