---
FII: "TC-IMAP-0004"
groupId: "GRP-0004"
title: "Invalid IMAP Credentials"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Verify system behavior when IMAP credentials are invalid.

### Test Steps
1. Configure incorrect IMAP username or password.  
2. Attempt to connect.  
3. Observe the system response.

### Expected Result
- Connection fails.  
- Error message displayed and logged.  
- No tasks are ingested.
