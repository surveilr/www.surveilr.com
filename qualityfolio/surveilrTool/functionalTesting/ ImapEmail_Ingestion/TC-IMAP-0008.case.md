---
FII: "TC-IMAP-0008"
groupId: "GRP-0004"
title: "IMAP Server Unreachable"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description
- Verify system behavior when IMAP server is unreachable or down.

### Test Steps
1. Configure valid credentials.  
2. Disconnect IMAP server or simulate network failure.  
3. Attempt connection.  
4. Observe result.

### Expected Result
- Connection attempt fails.  
- Timeout or “Server Unreachable” message logged.  
- No tasks ingested.
