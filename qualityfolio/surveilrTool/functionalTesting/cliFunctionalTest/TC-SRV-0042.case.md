---
FII: "TC-SRV-0042"
groupId: "GRP-0001"
title: "Validate Surveilr Admin Repair Command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["admin", "repair", "database"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path" 
---

### Description

- Validate that `surveilr admin repair` successfully repairs corrupted database files.

### Precondition

- Corrupted RSSD file available at `/data/rssd/corrupt.db`.

### Test Steps

1. Execute `surveilr admin repair /data/rssd/corrupt.db`.
2. Observe console output for repair summary.

### Expected Result

- Database repaired successfully.
- Output displays “Repair completed.”
- Exit code = 0.

