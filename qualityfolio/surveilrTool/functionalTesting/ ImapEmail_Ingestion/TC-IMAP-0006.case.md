---
FII: "TC-IMAP-0006"
groupId: "GRP-0004"
title: "Partially Corrupted Task Emails"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Verify ingestion when some tasks are corrupted or malformed.

### Test Steps
1. Connect to IMAP server with valid credentials.  
2. Ensure mailbox has both valid and corrupted task emails.  
3. Initiate ingestion.  
4. Observe ingestion results.

### Expected Result
- Valid tasks ingested.  
- Corrupted tasks skipped.  
- Proper error logs generated.
