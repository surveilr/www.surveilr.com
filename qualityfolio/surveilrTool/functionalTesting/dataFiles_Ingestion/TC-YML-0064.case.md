---
FII: "TC-YML-0064"
groupId: "GRP-0002"
title: "Deeply Nested Map Parsing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate parsing of deeply nested YAML maps (5+ levels).

### Test Steps
1. Prepare YAML file with 5+ levels of nested maps.  
2. Run `surveilr ingest files --file nested.yaml`.  

### Expected Result
- Nested structures parsed correctly; values accessible; exit code `0`.
