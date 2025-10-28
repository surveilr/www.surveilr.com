---
FII: "TC-YML-0063"
groupId: "GRP-0002"
title: "Unsupported File Extension Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Ensure Surveilr only accepts `.yaml` or `.yml` files.

### Test Steps
1. Attempt ingestion of `file.txt` or `file.json` as YAML.  
2. Run `surveilr ingest files --file file.txt`.  

### Expected Result
- CLI rejects unsupported file; exit code `!= 0`; proper error logged.
