---
FII: "TC-IMAP-0002"
groupId: "GRP-0004"
title: "Ingest specific folder"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

Validate ingestion from a specific Gmail IMAP folder.

### Preconditions

- Gmail IMAP enabled.
- App Password generated.
- Target IMAP folder exists.
- Test emails exist inside the selected folder.

### Test Steps

1. Provide valid Gmail IMAP configuration.
2. Run the ingestion command with folder flag:
  surveilr ingest imap \
  -a "imap.gmail.com" \
  -u "<email>" \
  -p "<app-password>" \
  -f "<target-folder>" \
  --status all \
  --progress
3. Monitor ingestion logs.

### Expected Result

- Only emails from the specified folder are ingested.

