---
FII: "TC-IMAP-0004"
groupId: "GRP-0004"
title: "Attachment extraction enabled"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Validate attachment extraction during IMAP ingestion.

### Preconditions

- Test email containing multiple attachments exists.

### Test Steps

1. Provide Gmail IMAP credentials.
2. Run ingestion with attachment extraction:
 surveilr ingest imap \
  -a "imap.gmail.com" \
  -u "<email>" \
  -p "<app-password>" \
  --extract-attachments uniform-resource \
  --status all
3. Track logs for extraction steps.

### Expected Result

- All attachments from eligible emails are extracted correctly.