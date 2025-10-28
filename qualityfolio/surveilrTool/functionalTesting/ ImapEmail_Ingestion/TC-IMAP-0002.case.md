---
FII: "TC-IMAP-0002"
groupId: "GRP-0004"
title: "Ingest Multiple Tasks in a Single Fetch"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify ingestion handles multiple tasks in a single IMAP fetch operation.

### Test Steps
1. Ensure IMAP mailbox contains 10 or more tasks.  
2. Connect to IMAP server with valid credentials.  
3. Initiate ingestion.  
4. Observe task count in Surveilr.

### Expected Result
- All tasks ingested successfully.  
- No duplicate tasks.  
- Task count matches source mailbox.
