-----

title: "Media Sanitization and Disposal Policy"
weight: 1
description: "Policy for the sanitization of system media prior to disposal, release, or reuse, in accordance with CMMC requirements."
publishDate: "2025-09-18"
publishBy: "Netspective"
classification: "Internal"
control-question: "Does the organization sanitize system media with the strength and integrity commensurate with the classification or sensitivity of the information prior to disposal, release out of organizational control or release for reuse?"
control-id: "MP.L1-3.8.3"
documentVersion: "1.0"
documentType: "Policy"
approvedBy: "Approving Authority"
category: ["System Hardening", "Media Protection"]
satisfies: ["FII-SCF-DCH-0009"]
merge-group: "regime-cmmc-MP.L1-3.8.3"
order: 1

-----

## Introduction

This policy establishes the requirements for sanitizing system media to protect Controlled Unclassified Information (CUI) and other sensitive data prior to disposal, release, or reuse. Adherence to these procedures ensures compliance with CMMC practice MP.L1-3.8.3, preventing unauthorized disclosure of information.


## Policy Statement

All organizational and user-owned system media containing CUI or other sensitive information must be sanitized or destroyed using approved methods with strength and integrity commensurate with the highest data classification before being disposed of, released from organizational control, or prepared for reuse.

-----

## Scope

This policy applies to all users and all organizational and user-owned system media capable of storing electronic information. This includes, but is not limited to:

  - Hard Disk Drives (HDDs) and Solid State Drives (SSDs)
  - Removable media (e.g., USB drives, CDs, DVDs)
  - Mobile devices (e.g., smartphones, tablets)
  - Backup tapes and other archival media
  - System components with persistent memory (e.g., printers, copiers)

-----

## Responsibilities

  - **System and Data Owners:** Responsible for identifying all media under their control and initiating the sanitization or destruction process.
  - **IT Department:** Responsible for performing and documenting the sanitization and destruction procedures, as well as maintaining a list of approved sanitization software and hardware tools.
  - **All Employees:** Responsible for following proper procedures when disposing of or reusing any system media.

-----

## Evidence Collection Methods

This section defines the methods for collecting verifiable evidence of media sanitization and destruction, leveraging both automated and manual processes for attestation in the Surveilr platform.

### Machine Attestation Methods

  - **Approved Software Inventory:** An API integration with the organization's endpoint management solution will be used to automatically check and verify that all IT-managed endpoints have approved sanitization software, such as `DBAN` or `SDelete`, installed and configured correctly.
  - **Sanitization Log Ingestion:** The IT department's sanitization tool will be configured to automatically export sanitization event logs. These logs, which include timestamps, media identifiers, and success/failure status, will be ingested into Surveilr via a scheduled script to confirm successful sanitization of media for reuse.
  - **Media State Validation:** For media being prepared for reuse, an automated script will use `OSquery` to confirm that the media is unpartitioned or formatted and that no files remain, cross-referencing this against the approved sanitization tool's logs within Surveilr.

### Human Attestation Methods

  - **Physical Destruction Certificate:** When a third-party vendor is used for media destruction (e.g., shredding hard drives), a `certificate of destruction` must be provided. The IT manager will review and sign this certificate. The signed PDF is then uploaded to Surveilr as an artifact, with metadata including the reviewer's name, date of review, and a reference to the list of destroyed assets.
  - **Internal Media Destruction Log:** For internal physical destruction (e.g., using a degausser or shredder), the responsible IT staff member must complete a **Media Destruction Form**. This form must include the media's serial number, destruction date, and method used. The form is signed by the staff member and an IT manager. The form is then scanned and uploaded to Surveilr.
  - **Visual Inspection Report:** When media is sanitized but not destroyed (e.g., for reuse within the organization), the responsible IT staff member must perform a visual inspection and document the sanitization process in a `Sanitization Report`. This report is then signed by the IT manager and uploaded to Surveilr with the metadata of the attesting parties.

-----

## Verification Criteria

Evidence collected will be validated against the following criteria within Surveilr:

  - **Machine Attestation:** Automated checks will verify that approved sanitization tools are present on endpoints and that the ingested logs from those tools show successful, tamper-proof sanitization events.
  - **Human Attestation:** The metadata of uploaded artifacts (e.g., signed certificates, scanned forms) will be verified to confirm that required sign-offs and dates are present.

-----

## Exceptions

Any exceptions to this policy, such as media that cannot be sanitized or destroyed by approved methods, must be documented and submitted to the CISO for approval. Approved exceptions will be logged in Surveilr with justification and a plan for alternative data protection.

-----

### *References*

  - [NIST SP 800-88 Guidelines for Media Sanitization](https://www.google.com/search?q=https://nvlpubs.nist.gov/nistpubs/specialpublications/nist.sp.800-88rev1.pdf)
  - [CMMC Model](https://www.google.com/search?q=https://www.dodcui.mil/Home/CMMC/)