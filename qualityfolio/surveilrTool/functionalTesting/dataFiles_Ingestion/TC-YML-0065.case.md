---
FII: "TC-YML-0065"
groupId: "GRP-0002"
title: "YAML Sequence / List Parsing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that YAML sequences (lists/arrays) are correctly parsed.

### Test Steps
1. Prepare YAML file with arrays and sequences.  
2. Run `surveilr ingest files --file sequence.yaml`.  

### Expected Result
- Arrays parsed correctly; values accessible individually; exit code `0`.
