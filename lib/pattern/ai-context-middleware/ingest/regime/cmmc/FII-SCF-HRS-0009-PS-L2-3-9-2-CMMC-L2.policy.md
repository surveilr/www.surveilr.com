---
title: "Employment Termination Security Management Policy"
weight: 1
description: "Establishes a structured framework for the compliant and secure termination of employment, safeguarding organizational assets and sensitive information."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "PS.L2-3.9.2"
control-question: "Does the organization govern the termination of individual employment?"
fiiId: "FII-SCF-HRS-0009"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Human Resources Security"
category: ["CMMC", "Level 2", "Compliance"]
---

# Employment Termination Policy

## 1. Introduction
The purpose of this policy is to establish a framework for the controlled and compliant termination of individual employment within the organization. It is crucial to ensure that employee terminations are conducted in a manner that protects both the organization's assets and the confidentiality of sensitive information. This policy aims to mitigate risks associated with unauthorized access to systems and data following an employee's departure.

## 2. Policy Statement
The organization is committed to ensuring that all employment terminations are executed in compliance with applicable laws, regulations, and corporate standards. This policy mandates a structured approach to manage the termination process in a controlled manner, safeguarding organizational resources and maintaining the integrity of sensitive information.

## 3. Scope
This policy applies to all employees, contractors, and third-party vendors across all relevant environments, including but not limited to:
- On-premises systems
- Cloud-hosted systems
- Software as a Service (SaaS) applications
- Third-party vendor systems

## 4. Responsibilities
- **HR Manager**: Initiate termination procedures **upon receipt of termination notice** and ensure compliance with this policy.
- **IT Security Team**: Disable access to systems and applications **within 24 hours of termination** notification received from HR.
- **Line Manager**: Conduct exit interviews and collect company property **on the last working day** of the employee.
- **Compliance Officer**: Review termination procedures and documentation **monthly** to ensure adherence to policy standards.

## 5. Evidence Collection Methods

### 1. REQUIREMENT
The organization must document the termination of employment, including the reasons for termination and the date of termination.

### 2. MACHINE ATTESTATION
Automated systems will log all access changes and the disabling of accounts. Security Information and Event Management (SIEM) tools will monitor and report on access revocation actions taken by IT Security.

### 3. HUMAN ATTESTATION
HR will maintain a termination checklist, including signed acknowledgments from the employee regarding the return of company property. This checklist will be documented and ingested into Surveilr for validation.

### 1. REQUIREMENT
Ensure that all company property is retrieved from the departing employee.

### 2. MACHINE ATTESTATION
Inventory management systems will track the return of company assets. Automated alerts will be generated if items are not returned by the stipulated deadline.

### 3. HUMAN ATTESTATION
Line Managers will complete a property return form, signed by the departing employee, which will be stored in Surveilr as evidence of compliance.

### 1. REQUIREMENT
Conduct exit interviews to gather feedback and ensure understanding of termination responsibilities.

### 2. MACHINE ATTESTATION
Survey tools will automatically send exit interview invitations, with results compiled for analysis.

### 3. HUMAN ATTESTATION
Line Managers will document exit interview notes and feedback in Surveilr, ensuring a record of the conversation is maintained.

## 6. Verification Criteria
Compliance will be validated through:
- **KPIs**: 100% of terminations documented within 48 hours.
- **SLAs**: 95% of access deactivations completed within 24 hours of notification.
- **Audit Reports**: Quarterly audits will review adherence to this policy with a target compliance rate of 98%.

## 7. Exceptions
Exceptions to this policy may be approved under extenuating circumstances, such as legal holds or ongoing investigations. All exceptions must be documented and approved by the HR Manager and Compliance Officer, with a detailed rationale provided.

## 8. Lifecycle Requirements
- **Data Retention**: All termination-related documentation must be retained for a minimum of 7 years.
- **Annual Review**: This policy will be reviewed annually, with updates made as necessary to reflect changes in regulations or organizational practices.

## 9. Formal Documentation and Audit
All workforce members involved in the termination process are required to acknowledge and attest to their understanding of this policy. Comprehensive audit logs will be maintained to track compliance and any deviations from the established procedures.

## 10. References
- [CMMC](https://www.acq.osd.mil/cmmc/)
- [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [ISO/IEC 27001](https://www.iso.org/isoiec-27001-information-security.html)