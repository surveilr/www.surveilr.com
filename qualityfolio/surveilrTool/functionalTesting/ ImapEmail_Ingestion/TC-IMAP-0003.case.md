---
FII: "TC-IMAP-0003"
groupId: "GRP-0004"
title: "Validate Task Metadata During IMAP Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that metadata (subject, timestamp, sender) is correctly mapped during IMAP ingestion.

### Test Steps
1. Connect to IMAP server with valid credentials.  
2. Fetch and ingest tasks.  
3. Verify ingested task metadata in Surveilr.

### Expected Result
- All metadata fields match the original IMAP source.  
- No missing or altered data.
