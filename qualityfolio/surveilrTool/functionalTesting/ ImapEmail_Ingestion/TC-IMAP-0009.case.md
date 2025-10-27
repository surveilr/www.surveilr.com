---
FII: "TC-IMAP-0009"
groupId: "GRP-0004"
title: "Mailbox Permission Denied"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description
- Verify ingestion when access to IMAP mailbox is denied due to permissions.

### Test Steps
1. Configure valid IMAP credentials with insufficient permissions.  
2. Attempt to connect and ingest tasks.  
3. Observe behavior.

### Expected Result
- Connection denied.  
- Permission error logged.  
- No ingestion occurs.
