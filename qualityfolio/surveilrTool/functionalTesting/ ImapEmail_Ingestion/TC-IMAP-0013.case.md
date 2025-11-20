---
FII: "TC-IMAP-0013"
groupId: "GRP-0004"
title: "Incorrect mail date"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "date"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate date correctness between IMAP source and displayed output.

### Preconditions
- A test email is sent with a known/verified timestamp.

### Test Steps
1. Send email to mailbox.
2. Run ingestion.
3. Compare stored/parsed date with actual IMAP date.

### Expected Result
- Correct IMAP message date is displayed and stored.

