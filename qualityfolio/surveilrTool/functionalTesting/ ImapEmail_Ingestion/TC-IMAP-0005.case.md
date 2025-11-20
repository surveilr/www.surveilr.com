---
FII: "TC-IMAP-0005"
groupId: "GRP-0004"
title: "Batch limit respected"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Validate ingestion respects the batch limit.

### Preconditions

- Inbox contains more than 10 emails.

### Test Steps

1. Configure IMAP ingestion.
2. Run with -b 10:
surveilr ingest imap \
  -a "imap.gmail.com" \
  -u "<email>" \
  -p "<app-password>" \
  -b 10
3. Verify ingestion count.

### Expected Result

- Exactly 10 emails are ingested.