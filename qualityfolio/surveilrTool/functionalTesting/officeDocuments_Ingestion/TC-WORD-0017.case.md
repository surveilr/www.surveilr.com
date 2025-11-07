---
FII: "TC-WORD-0017"
groupId: "GRP-0005"
title: "Ingest Multiple Valid Word Files"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Word"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveilr correctly ingests multiple valid Word files in a single command execution.

### Preconditions
- Ensure multiple Word files (.docx) exist in the same folder.  
- Surveilr CLI is installed and configured.

### Test Steps
1. Run the ingestion command.  
2. Observe the ingestion progress in the console or logs.  
3. Verify completion status for each file.  

### Expected Result
- All files are successfully processed.  
- Surveilr displays “✅ Ingest completed successfully” for each file.  
- No ingestion errors or skipped files are reported.  
