---
FII: "TC-IMAP-0014"
groupId: "GRP-0004"
title: "Concurrent IMAP Connections"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveilr can handle multiple IMAP accounts connected concurrently.

### Test Steps
1. Connect multiple IMAP accounts at the same time.  
2. Fetch emails from all accounts.  
3. Monitor storage and classification.

### Expected Result
- Emails from all accounts are stored in respective folders.  
- Attachments and metadata are processed correctly.  
- System handles multiple connections without errors.
