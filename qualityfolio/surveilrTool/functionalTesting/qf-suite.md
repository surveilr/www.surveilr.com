---
id: "SUT-0001"
projectId: "PRJ-0001"
name: "Surveilr CLI Functional Test Suite"
description: "A suite of test cases designed to validate the core functionalities of the Surveilr CLI, including command execution, file ingestion, IMAP email processing, output validation, and error handling."
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
tags: ["CLI testing", "Functional validation", "File handling", "IMAP"]
version: "1.0"
status: "Draft"
---

## Scope of Work

This test suite validates the **functional correctness of the Surveilr CLI**.  
It covers:  
- Execution of core CLI commands and subcommands.  
- Handling of parameters, flags, and options.  
- File ingestion and transformation for supported and real-world data files.  
- Retrieval and processing of emails via IMAP.  
- Output validation, logging, and exit codes.  
- Error handling and negative scenarios.  

The suite ensures predictable behavior across environments and aligns with business, technical, and compliance requirements.

---

## Test Objectives

- Validate command execution for all supported CLI commands.  
- Ensure accurate ingestion and parsing of supported file types (JSON, CSV, XML, YAML, Office files, logs, scripts, images, emails, and real-world exports).  
- Confirm logs, standard output, and exit codes reflect correct operation and failures.  
- Test negative scenarios such as invalid paths, unsupported formats, incorrect flags, missing arguments, and IMAP-related errors (invalid credentials, corrupted emails, unsupported attachments).  
- Verify feedback to the user is actionable and clear.  
- Assess CLI behavior across multiple environments and inputs.  
- Validate IMAP email processing including connection, retrieval, metadata extraction, attachment classification, folder management, and bulk/concurrent email handling.

---

## IMAP Email Processing Test Coverage

- **Connectivity & Authentication**  
  - Test IMAP server connections with valid and invalid credentials.  
  - Handle unreachable servers and authentication failures gracefully.  

- **Email Retrieval**  
  - Fetch emails from Inbox, Sent, and custom folders.  
  - Retrieve full email bodies, headers, and attachments.  
  - Support header-only retrieval for metadata extraction.  

- **Storage & Classification**  
  - Store email bodies as `.txt` files.  
  - Store headers and metadata as CSV/JSON.  
  - Classify attachments according to type: PDFs → Office Documents, CSV/Excel → Structured Data, Images → Misc/Image Files.  
  - Handle unsupported attachment types with proper logging.  

- **Folder Management**  
  - Store emails in a dedicated IMAP folder.  
  - Manage folder size limits and overflow.  

- **Error Handling**  
  - Skip and log corrupted emails without affecting other processing.  
  - Handle unsupported formats, network errors, and IMAP server failures.  

- **Performance & Reliability**  
  - Validate bulk email fetch performance.  
  - Test multiple concurrent IMAP connections for robustness.
