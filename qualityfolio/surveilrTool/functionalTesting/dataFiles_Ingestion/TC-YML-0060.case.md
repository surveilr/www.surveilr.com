---
FII: "TC-YML-0060"
groupId: "GRP-0002"
title: "Missing YAML File Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Ensure proper handling when the specified YAML file does not exist.

### Test Steps
1. Run ingestion on a non-existent YAML file: `surveilr ingest files --file missing.yaml`.  

### Expected Result
- CLI returns `File Not Found`; exit code `!= 0`; error logged.
