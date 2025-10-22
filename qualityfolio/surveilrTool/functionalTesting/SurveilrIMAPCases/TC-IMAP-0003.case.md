---
FII: "TC-IMAP-0003"
groupId: "GRP-0004"
title: "Handle Unreachable IMAP Server"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveilr handles scenarios where the IMAP server is unreachable.

### Test Steps
1. Configure a non-existent IMAP server address.  
2. Attempt to connect.  

### Expected Result
- Connection fails with a network error.  
- Error is logged in Surveilr.  
- No crash occurs; system continues functioning.
