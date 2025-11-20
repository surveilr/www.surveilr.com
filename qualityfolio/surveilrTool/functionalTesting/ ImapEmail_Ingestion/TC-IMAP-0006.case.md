---
FII: "TC-IMAP-0006"
groupId: "GRP-0004"
title: "Ingestion of latest email"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Validate ingestion includes the latest email.

### Preconditions

- A fresh email is sent just before running ingestion.

### Test Steps

1. Confirm latest email is received.
2. Run ingestion:
surveilr ingest imap \
  -a "imap.gmail.com" \
  -u "<email>" \
  -p "<app-password>"
3. Check processed email list.

### Expected Result

- The latest email is included in the ingestion results.
