---
FII: "TC-YML-0062"
groupId: "GRP-0002"
title: "Large YAML File Performance"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate handling of very large YAML files.

### Test Steps
1. Create a YAML file with thousands of entries.  
2. Run `surveilr ingest files --file large.yaml`.  

### Expected Result
- File ingested successfully; performance acceptable; exit code `0`; logs show completion.
