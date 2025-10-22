---
FII: "TC-IMAP-0008"
groupId: "GRP-0004"
title: "Handle Corrupted Email"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate Surveilr’s behavior when encountering a corrupted email during IMAP fetch.

### Test Steps
1. Introduce a malformed email in the IMAP server.  
2. Fetch emails via Surveilr.  

### Expected Result
- Surveilr logs an error for the corrupted email.  
- Corrupted email is skipped.  
- Other emails are processed normally.
