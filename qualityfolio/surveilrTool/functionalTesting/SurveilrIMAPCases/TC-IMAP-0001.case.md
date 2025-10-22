---
FII: "TC-IMAP-0001"
groupId: "GRP-0004"
title: "Connect to IMAP Server with Valid Credentials"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveilr can connect to the IMAP server using valid credentials.

### Test Steps
1. Configure IMAP server address, port, and valid credentials in Surveilr.  
2. Initiate connection.  
3. Observe connection status.

### Expected Result
- Connection is successful.  
- Status message shows "Connected".
