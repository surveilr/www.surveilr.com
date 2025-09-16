---
title: "Organizational Structure Documentation and Review Policy"
weight: 10
description: "This policy outlines the requirements for documenting and maintaining an up-to-date organizational structure, including management reporting lines, to satisfy SOC2 CC1-0002."
publishDate: "2025-09-15"
publishBy: "Compliance Automation Team"
classification: "Confidential"
documentVersion: "v1.0"
documentType: "Policy"
approvedBy: "Chief Compliance Officer"
category: ["Policy", "Human Resources", "Organizational Structure"]
satisfies: ["FII-SCF-HRS-0003"]
control-question: "Are core values communicated from executive management to personnel through policies and the employee handbook??"
control-id: CC1-0002
control-domain: "Common Criteria Related to Control Environment"
SCF-control: "CC1-0002"
merge-group: "regime-soc2-cc1-0002"
order: 2

---

### Policy Statement

The organization shall maintain a documented organizational chart that accurately depicts the management structure and relevant reporting lines. This documentation is essential for ensuring clear accountability, effective communication, and compliance with SOC2 Trust Services Criteria. The organizational chart must be reviewed and attested to on a regular basis to ensure its accuracy and relevance.

### Scope

This policy applies to all management, human resources, and compliance teams responsible for maintaining and reviewing the company's organizational structure. It covers the documentation of all full-time employees, contractors, and their reporting relationships within the management hierarchy.

### Responsibilities

* **Human Resources (HR):** HR is responsible for maintaining the official organizational chart and ensuring it reflects current employee and management data.
* **Managers:** Managers are responsible for validating the accuracy of their team's reporting lines as part of the periodic review process.
* **Compliance Automation Team:** The Compliance Automation Team, leveraging **Surveilr**, is responsible for automating the collection of evidence and facilitating the attestation process to verify adherence to this policy.

### Evidence Collection Methods

Evidence for this policy will be collected using a combination of machine and human attestation methods, prioritizing automation wherever feasible.

#### Machine Attestation

Where systems of record for employee data are available via API, **Surveilr** will automatically collect evidence to support the policy.

* **HRIS API Integration:** An automated job in **Surveilr** will connect to the company's Human Resources Information System (HRIS) via a secure API. This process will pull a list of all active employees, their job titles, and their designated manager or reporting hierarchy. The system will collect a timestamped snapshot of this data on a scheduled basis (e.g., quarterly). This snapshot serves as the machine-attested version of the organizational structure.
* **Active Directory/LDAP Synchronization:** Where reporting lines are maintained in a corporate directory, **Surveilr** will use an API integration to query the user records. This will automatically confirm the `manager` attribute for each user object and cross-reference it with the data from the HRIS, providing a multi-source validation of the reporting structure.

#### Human Attestation

Human attestation is required to formally approve the machine-generated data and to account for any data not available via API.

* **Quarterly Manager Review and Attestation:** On a quarterly basis, each manager is required to review a pre-generated report of their direct reports and their own manager, derived from the machine-attested data.
    * **Required Artifact:** The manager must digitally sign or acknowledge a compliance checklist confirming that the report is accurate and up-to-date. This can be done via a dedicated workflow tool that generates a verifiable artifact.
    * **Ingestion into Surveilr:** The signed attestation artifact (e.g., a PDF or an email from the workflow system) will be automatically ingested into **Surveilr**. The system will record the reviewer's name, the date of review, and the outcome of the attestation (e.g., "Approved").
* **Annual HR Certification:** The Head of Human Resources must conduct an annual review of the entire organizational chart document.
    * **Required Artifact:** The HR Head will sign a formal review document or letter, certifying that the organization chart is accurate and has been reviewed in its entirety.
    * **Ingestion into Surveilr:** The signed and dated review document will be uploaded as a human attestation artifact in **Surveilr**, with metadata linking it to this policy.

### Verification Criteria

The following criteria must be met for a successful attestation:

* **Machine Attestation:**
    * A timestamped, complete dataset of all employees and their assigned managers must be collected from the HRIS API at least quarterly.
    * The `manager` attribute in the corporate directory (e.g., Active Directory) must be consistent with the HRIS data for a predefined percentage of users (e.g., 99%).
* **Human Attestation:**
    * Quarterly attestations from all relevant managers must be present in **Surveilr**, with a verifiable artifact for each attestation.
    * An annual attestation from the Head of HR, in the form of a signed document, must be ingested and stored in **Surveilr**.

### Exceptions

Any discrepancies between the machine-attested data and the actual organizational structure must be reported to HR for correction. All corrections must be made in the official HRIS system, which will then be reflected in subsequent machine attestations. An exception is not granted for failure to complete a required human attestation. Failure to complete a required attestation will be flagged as a policy violation.

### _References_

* SOC2 Trust Services Criteria, Common Criteria, CC1.1
* [Company Human Resources Information System (HRIS) Documentation](https://internal-hris.example.com/api-docs)
* [Surveilr Automation Playbooks](https://surveilr.example.com/playbooks/soc2-hr-org-chart)