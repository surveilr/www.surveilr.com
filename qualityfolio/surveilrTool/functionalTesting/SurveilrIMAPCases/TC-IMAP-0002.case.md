---
FII: "TC-IMAP-0002"
groupId: "GRP-0004"
title: "Connect to IMAP Server with Invalid Credentials"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveilr handles connection attempts with invalid IMAP credentials correctly.

### Test Steps
1. Enter an invalid username/password for the IMAP server in Surveilr.  
2. Attempt to connect.  

### Expected Result
- Connection fails.  
- Proper error message is displayed.  
- Retry option is available.
