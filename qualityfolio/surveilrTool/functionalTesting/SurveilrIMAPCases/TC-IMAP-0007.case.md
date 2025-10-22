---
FII: "TC-IMAP-0007"
groupId: "GRP-0004"
title: "Store Email Body as Text File"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that email body content retrieved via IMAP is stored as a `.txt` file in Surveilr.

### Test Steps
1. Retrieve emails via IMAP.  
2. Extract the email body.  
3. Store the content as `.txt` in the IMAP folder.

### Expected Result
- Email body is stored as a `.txt` file.  
- Content matches the original email body.
