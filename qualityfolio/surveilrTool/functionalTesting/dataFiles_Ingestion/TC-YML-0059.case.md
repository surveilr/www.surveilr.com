---
FII: "TC-YML-0059"
groupId: "GRP-0002"
title: "Invalid YAML Syntax Detection"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that syntax errors (e.g., missing `:` or unclosed brackets) in YAML files are detected.

### Test Steps
1. Prepare YAML file with syntax errors.  
2. Run `surveilr ingest files --file bad_syntax.yaml`.  

### Expected Result
- CLI returns error message; exit code `!= 0`; logs indicate `Syntax Error`.
