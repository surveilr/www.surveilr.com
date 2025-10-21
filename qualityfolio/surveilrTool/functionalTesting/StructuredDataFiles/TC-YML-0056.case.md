---
FII: "TC-YML-0056"
groupId: "GRP-0002"
title: "Handle YAML Anchors & Aliases"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify YAML anchors (`&`) and aliases (`*`) are resolved correctly by Surveilr CLI.

### Test Steps
1. Create YAML file using anchors and aliases.  
2. Run `surveilr ingest files --file anchors.yaml`.  

### Expected Result
- Anchors and aliases resolved correctly; values match expected; exit code `0`.
