---
FII: "TC-IMAP-0001"
groupId: "GRP-0004"
title: "Valid IMAP Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify tasks are ingested correctly from a valid IMAP mailbox.

### Test Steps
1. Configure valid IMAP credentials.  
2. Connect to the IMAP mailbox.  
3. Fetch tasks.  
4. Ingest tasks into Surveilr.

### Expected Result
- All tasks are successfully ingested with correct details.
