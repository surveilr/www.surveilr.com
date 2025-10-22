---
FII: "TC-IMAP-0005"
groupId: "GRP-0004"
title: "Fetch Emails with Attachments"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveilr can retrieve emails containing attachments and store both email and attachments correctly.

### Test Steps
1. Fetch emails with attachments via IMAP.  
2. Verify that attachments are extracted and stored.  
3. Check metadata of emails and attachments.

### Expected Result
- Attachments are stored in the appropriate folders.  
- Email metadata is recorded correctly.  
- Email body is preserved.
