---
title: "Records Review Procedures Policy"
weight: 1
description: "Records Review Procedures This control requires the implementation of systematic procedures for the regular review of information systems activity records, including audit logs, access reports, and security incident tracking. These reviews are essential for identifying potential security incidents, ensuring compliance with HIPAA regulations, and enhancing overall information security management. Regular reviews help organizations maintain oversight of their information systems and promptly address any anomalies or unauthorized activities."
publishDate: "2025-09-24"
publishBy: "HIPAA Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Policy"
control-id: "164.308(a)(1)(ii)(D)"
control-question: "Have you implemented procedures to regularly review records of IS activity such as audit logs, access reports, and security incident tracking? (R)"
fiiId: "FII-SCF-RSK-0004"
regimeType: "HIPAA"
category: ["HIPAA", "Compliance", "Healthcare"]
---

# HIPAA Compliance Policy Document

## Introduction
This policy outlines the procedures for regularly reviewing records of information system (IS) activity, including audit logs, access reports, and security incident tracking, to ensure compliance with HIPAA regulations and to enhance the security posture of the organization.

## Policy Statement
The organization is committed to maintaining the integrity and confidentiality of protected health information (PHI) by implementing and enforcing procedures that facilitate regular reviews of IS activity records. This is to ensure compliance with HIPAA Control Code 164.308(a)(1)(ii)(D).

## Scope
This policy applies to all employees, contractors, and third-party service providers who have access to the organization’s information systems and are responsible for managing or accessing PHI.

## Responsibilities
- **Compliance Officer**: Responsible for overseeing the implementation of this policy, ensuring that review processes are followed and documented.
- **IT Security Team**: Responsible for conducting the reviews of IS activity records and reporting findings to the Compliance Officer.
- **All Staff**: Required to support the compliance efforts and report any discrepancies or security incidents to the IT Security Team.

## Evidence Collection Methods

### Explanation
Regular reviews of IS activity records are essential for identifying unauthorized access and ensuring compliance with HIPAA regulations. The organization will utilize automated tools and processes to facilitate these reviews.

### Machine Attestation
- **Audit Log Review**: Implement automated scripts to ingest audit log data into Surveilr for ongoing analysis. This process will ensure that access logs are reviewed regularly, with findings documented and stored as machine-attested evidence.
- **Access Reports**: Integrate with endpoint management systems via API to pull access reports regularly into Surveilr, enabling continuous monitoring and automated reporting of access patterns.
- **Security Incident Tracking**: Use automated log ingestion to track security incidents and maintain records within Surveilr for review.

### Human Attestation
- **Quarterly Review Report**: The Compliance Officer must review the findings from the automated processes quarterly. A report certifying the review must be signed and uploaded to Surveilr, including relevant metadata such as reviewer name, date, and outcome.

## Verification Criteria
- Evidence of regular IS activity record reviews will be verified through:
  - Ingested data from audit logs and access reports in Surveilr.
  - Signed quarterly review reports by the Compliance Officer.
  - Documentation of security incidents and their resolutions.

## Exceptions
Any exceptions to this policy must be documented and approved by the Compliance Officer, ensuring that alternative measures are in place to maintain compliance.

## References
- HIPAA Privacy Rule (45 CFR Part 160 and Part 164)
- NIST Special Publication 800-53: Security and Privacy Controls for Information Systems and Organizations

### _References_
- Control Code: 164.308(a)(1)(ii)(D)
- Internal ID: FII-SCF-RSK-0004

This policy will be reviewed and updated annually or as needed to reflect changes in regulatory requirements or organizational practices.