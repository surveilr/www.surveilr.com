---
FII: "TC-YML-0066"
groupId: "GRP-0002"
title: "Load Valid YAML File"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that a well-formed YAML file with nested maps and sequences is correctly parsed by Surveilr CLI.

### Test Steps
1. Prepare a valid YAML file with nested maps and sequences.  
2. Run `surveilr ingest files --file valid.yaml`.  

### Expected Result
- File is parsed successfully; exit code `0`; log shows `OK`.
