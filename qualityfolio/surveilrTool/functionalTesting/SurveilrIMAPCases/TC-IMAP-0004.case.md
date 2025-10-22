---
FII: "TC-IMAP-0004"
groupId: "GRP-0004"
title: "Fetch Emails from IMAP Inbox Folder"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate Surveilr’s ability to fetch emails from the IMAP Inbox and store them in the designated IMAP folder.

### Test Steps
1. Connect to the IMAP server.  
2. Fetch all emails from the Inbox folder.  
3. Verify that each email is stored in the separate IMAP folder in Surveilr.

### Expected Result
- All emails are successfully retrieved.  
- Emails are stored in the designated folder with correct metadata.
