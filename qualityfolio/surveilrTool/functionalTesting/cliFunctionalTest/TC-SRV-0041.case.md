---
FII: "TC-SRV-0041"
groupId: "GRP-0001"
title: "Validate Surveilr Admin Merge Functionality"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["admin", "merge", "rssd"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path" 
---

### Description

- Ensure that `surveilr admin merge` correctly merges multiple RSSD files into a single consolidated database.

### Precondition

- Two valid RSSD files available: `/data/rssd/file1.db` and `/data/rssd/file2.db`.

### Test Steps

1. Execute `surveilr admin merge /data/rssd/*.db`.
2. Verify that merged DB is generated at `/data/rssd/merged.db`.

### Expected Result

- Merged file created successfully.
- Output confirms number of merged records.
- Exit code = 0.


