---
FII: "TC-YML-0057"
groupId: "GRP-0002"
title: "Multi-line String Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that multi-line strings (`|` or `>`) are correctly interpreted by Surveilr CLI.

### Test Steps
1. Prepare YAML file with multi-line strings.  
2. Run `surveilr ingest files --file multiline.yaml`.  

### Expected Result
- Multi-line strings are preserved; parsed values match input; exit code `0`.
