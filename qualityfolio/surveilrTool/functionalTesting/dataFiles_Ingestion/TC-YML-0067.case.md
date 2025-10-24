---
FII: "TC-YML-0067"
groupId: "GRP-0002"
title: "Mixed Data Types Parsing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate parsing of mixed data types (string, int, bool, null) in YAML files.

### Test Steps
1. Prepare YAML file containing strings, integers, booleans, and null values.  
2. Run `surveilr ingest files --file mixed_types.yaml`.  

### Expected Result
- All values parsed correctly; data types preserved; exit code `0`.
