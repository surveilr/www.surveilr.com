---
FII: "TC-IMAP-0010"
groupId: "GRP-0004"
title: "Handle Unsupported Attachment Type"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveilr handles unsupported attachment types during IMAP fetch.

### Test Steps
1. Include an email with unsupported attachment type (e.g., `.exe`).  
2. Fetch emails via IMAP.  
3. Observe how the attachment is processed.  

### Expected Result
- Email body is processed successfully.  
- Unsupported attachment is flagged in logs.  
- System does not crash.
