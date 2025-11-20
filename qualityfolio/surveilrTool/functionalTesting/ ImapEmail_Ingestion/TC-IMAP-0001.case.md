---
FII: "TC-IMAP-0001"
groupId: "GRP-0004"
title: "Successful ingestion with valid Gmail IMAP"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate successful ingestion from a valid Gmail IMAP mailbox.

### Preconditions
- Gmail IMAP enabled.
- 2-Step Verification enabled.
- App Password generated.
- Valid test emails exist in the Gmail inbox.

### Test Steps
1. Provide valid Gmail IMAP configuration.  
2. Run the ingestion command. 
 surveilr ingest imap
-a "imap.gmail.com"
-u "<email>"
-p "<app-password>"
-f "<folder>"
-b 10
--extract-attachments uniform-resource
--status all
--progress
1. Monitor ingestion logs.  

### Expected Result
- All eligible mails are ingested without errors.

