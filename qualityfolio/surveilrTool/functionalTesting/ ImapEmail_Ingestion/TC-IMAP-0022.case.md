---
FII: "TC-IMAP-0022"
groupId: "GRP-0004"
title: "Gmail category mismatch"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "gmail", "categories"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate correct mapping of Gmail categories (Social, Promotions, Updates, etc).

### Preconditions
- Test emails are placed into Social or Promotions categories.

### Test Steps
1. Run ingestion pointing to category folders.
2. Compare mapping outcomes.

### Expected Result
- Correct category folder is processed.