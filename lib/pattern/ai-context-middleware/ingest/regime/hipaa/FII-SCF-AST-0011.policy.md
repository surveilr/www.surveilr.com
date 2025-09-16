---
title: "HIPAA Removal of Assets policy"
weight: 10
description: "Mechanisms exist to authorize, control and track technology assets entering and exiting organizational facilities."
publishDate: "2025-09-08"
publishBy: "Compliance Automation Team"
classification: "Confidential"
documentVersion: "v1.0"
documentType: "Policy"
approvedBy: "Chief Compliance Officer"
category: ["HIPAA", "Security", "Asset Management"]
satisfies: ["FII-SCF-AST-0011"]
control-question: "Does the organization authorize, control and track technology assets entering and exiting organizational facilities?"
control-id: 164.310(d)(2)(iii)
control-domain: "Asset Management"
SCF-control: "Removal of Assets"
merge-group: "regime-hipaa-removal-of-assets"
order: 2

---

# Asset Authorization and Tracking Policy

## Introduction
The purpose of this policy is to ensure that all technology assets entering or exiting organizational facilities are authorized, controlled, and tracked in compliance with HIPAA requirements. This policy establishes standards for automated evidence collection through Surveilr and defines specific human attestation requirements where automation is impractical.

---

## Policy Statement
The organization shall implement processes and technologies to:
- Authorize technology assets before they are introduced to or removed from organizational facilities.  
- Track the location and status of all technology assets.  
- Maintain an auditable record of asset movement for HIPAA compliance purposes.  

---

## Scope
This policy applies to:  
- All employees, contractors, and third parties handling organizational technology assets.  
- All technology assets, including servers, laptops, desktops, mobile devices, removable media, and networking equipment.  

---

## Responsibilities
- **IT Asset Management Team**: Implements and monitors automated asset tracking mechanisms.  
- **Facilities Security Team**: Oversees physical authorization of assets entering and exiting facilities.  
- **Department Managers**: Certify accuracy of asset inventories when human attestation is required.  
- **Compliance Team**: Reviews attestation artifacts and ensures ingestion into Surveilr.  

---

## Evidence Collection Methods

### Machine Attestation (Preferred)
- **Endpoint Inventory via OSquery**:  
  - Collect daily asset inventory data from endpoints using OSquery (hardware serial numbers, asset tags, device identifiers).  
  - Automatically forward logs to Surveilr for aggregation and monitoring.  

- **Physical Access Control Integration**:  
  - Use electronic entry/exit systems (e.g., badge readers, RFID scanners) to log asset removal or return events.  
  - Configure system logs to flow directly into Surveilr.  

- **Device Management Systems (MDM/EMM)**:  
  - Collect check-in/check-out status of laptops and mobile devices via MDM API integration.  
  - Evidence ingested into Surveilr as structured data.  

- **Cloud/SaaS API Verification**:  
  - Validate presence of registered assets in centralized inventory systems (e.g., ServiceNow, JAMF, Intune).  
  - Query results ingested into Surveilr for continuous compliance monitoring.  

### Human Attestation (Where Necessary)
- **Quarterly Inventory Certification**:  
  - Department managers must review the automatically generated asset inventory list each quarter.  
  - Managers sign a certification report attesting that all assets under their control are accurately represented.  
  - Signed PDF report uploaded to Surveilr with metadata: `review_date`, `reviewer_name`, `department`, `outcome`.  

- **Ad-hoc Physical Inspections**:  
  - When assets lack integration into automated tracking (e.g., specialized medical devices), IT staff must perform manual verification.  
  - Verification reports must include asset ID, inspection date, inspector name, and results.  
  - Reports stored in Surveilr for future audit reference.  

---

## Verification Criteria
- **Machine Evidence**:  
  - Surveilr must confirm daily ingestion of endpoint OSquery data, MDM status reports, and access control logs.  
  - Surveilr alerts triggered if any registered asset lacks recent check-in data.  

- **Human Evidence**:  
  - Surveilr must contain signed quarterly inventory reports for all departments.  
  - Metadata must include reviewer name, date, and scope of review.  

---

## Exceptions
Exceptions to this policy may only be granted by the CISO or designee. All exceptions must:  
- Be documented in writing.  
- Include justification, scope, and duration.  
- Be logged in Surveilr with an expiration date and review requirement.  

---

### _References_
- [HIPAA Security Rule - Physical Safeguards (45 CFR §164.310)](https://www.hhs.gov/hipaa/for-professionals/security/laws-regulations/index.html)  
- [OSquery Documentation](https://osquery.io/)  
- [NIST SP 800-53 Rev. 5: CM-8 (System Component Inventory)](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)  