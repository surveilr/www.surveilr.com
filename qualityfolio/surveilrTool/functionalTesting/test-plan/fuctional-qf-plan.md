---
id: "PLN-0001"
name: "Surveilr CLI Functional Test Plan"
description: "This test plan defines objectives, scope, and testing activities for functional validation of the Surveilr CLI, including command execution, file ingestion, IMAP email processing, output validation, and error handling."
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
tags: ["CLI testing", "Functional testing", "File validation", "IMAP"]
version: "1.0"
status: "Draft"
---

## 1. Introduction

This test plan defines the overall strategy and approach for validating the **Surveilr Command-Line Interface (CLI)**.  
The focus is on **functional correctness, file ingestion, IMAP email processing, output consistency, and error handling** to ensure predictable CLI behavior across multiple environments.  

**Objectives include:**  
- Ensuring all CLI commands execute as expected.  
- Verifying accurate ingestion and transformation of supported file types.  
- Validating IMAP email retrieval, metadata extraction, and attachment classification.  
- Confirming correct handling of command parameters, flags, and options.  
- Validating proper exit codes, logs, and error messages.  
- Ensuring reliable feedback for negative or invalid scenarios.  

---

## 2. Scope of Work

The testing will cover:  

- **Functional Testing:**  
  - Validate all core CLI commands, parameters, and flags.  
  - Verify exit codes, logs, and output messages for success and failure.  

- **File Ingestion & Transformation Validation:**  
  - Test ingestion of supported file types:  
    - **Structured Data:** JSON, YAML/YML, XML, CSV  
    - **Text Files:** TXT, MD, RTF  
    - **Office Documents:** DOC/DOCX, XLS/XLSX, PPT/PPTX, PDF  
    - **Diagram/Design Files:** PlantUML, SVG, Visio  
    - **Code/Script Files:** Python, JavaScript, TypeScript, Java, C/C++, Shell, Configs  
    - **Miscellaneous:** Logs, archives (ZIP/TAR/GZ), images  
    - **Real-World Data:** Emails, project management exports, CRM exports, ERP exports, Healthcare EHR files  
  - Validate output consistency, row counts, metadata extraction, and logs.  

- **IMAP Email Processing:**  
  - Validate connection to IMAP servers with valid and invalid credentials.  
  - Fetch emails from Inbox, Sent, and custom folders.  
  - Extract email bodies, headers, and attachments, and classify them correctly:  
    - **Email Body:** Stored as `.txt` (Text Files)  
    - **Email Metadata:** Stored as CSV/JSON (Structured Data Files)  
    - **Attachments:** Classified according to type (PDF → Office Documents, CSV/Excel → Structured Data, Images → Misc/Image Files)  
  - Handle corrupted emails, unsupported attachments, and server/network errors gracefully.  
  - Store emails in a dedicated IMAP folder and manage folder size limits.  
  - Test bulk email fetch and concurrent IMAP connections for performance and reliability.  

- **Error Handling & Negative Scenarios:**  
  - Test invalid paths, unsupported formats, incorrect flags, and missing arguments.  
  - Verify graceful failure, proper error messages, and actionable feedback.  
  - Include IMAP-specific negative scenarios such as invalid credentials, corrupted emails, and unsupported attachment types.  

**Out of Scope:**  
- Performance/load testing  
- Security or penetration testing  
- UI/UX testing (CLI has no graphical interface)  

---

## 3. Test Objectives

- Validate functional correctness of all CLI commands and modules.  
- Confirm integrity of file ingestion, IMAP email retrieval, and data transformation processes.  
- Verify robust error handling and appropriate exit codes.  
- Ensure analytics/logging captures correct execution details.  
- Validate fallback mechanisms and failure recovery.  

---

## 4. Test Approach

### 4.1 Functional Testing
- Execute CLI commands using various parameters and flags.  
- Validate standard output, logs, and exit codes.  
- Confirm integration with dependent services (if any).  
- Verify exception handling and error messages for invalid inputs.  

### 4.2 File Ingestion & Transformation
- Feed supported and real-world file types to the CLI.  
- Validate correct parsing, processing, and output consistency.  
- Check handling of configuration files and structured data.  

### 4.3 IMAP Email Processing
- Connect to IMAP servers using valid and invalid credentials.  
- Fetch emails from various folders and validate proper storage in Surveilr.  
- Extract email body, headers, and attachments; verify classification and folder placement.  
- Handle corrupted emails, unsupported attachment types, and network/server failures gracefully.  
- Validate bulk email fetch and concurrent connections for performance.  

### 4.4 Error Handling & Negative Scenarios
- Execute commands with invalid paths, flags, missing arguments, and unsupported file types.  
- Confirm proper error reporting and graceful termination.  
- Include IMAP-specific negative scenarios to ensure robust handling of failures.
