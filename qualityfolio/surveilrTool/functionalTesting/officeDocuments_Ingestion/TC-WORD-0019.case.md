---
FII: "TC-WORD-0019"
groupId: "GRP-0005"
title: "Ingest Word File Without Read Permission"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Word"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify how Surveilr handles ingestion when the Word file has **restricted read permissions**, preventing access.

### Preconditions
- Word file exists but with read permission removed for the executing user.  
- Surveilr CLI installed and authenticated.  

### Test Steps
1. Set file permissions to read-protected:  
   chmod 000 /path/restricted.docx
2. Run ingestion command:
surveilr ingest files /path/restricted.docx
3. Observe CLI response and error logs.

### Expected Result
- Surveilr displays error: “Permission denied.”
- Ingestion should not proceed or attempt file parsing.
- Logs record the permission error clearly.