---
FII: "TC-SRV-0046"
groupId: "GRP-0001"
title: "Validate Surveilr Export Summary Report Command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["export", "report", "summary"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that Surveilr generates a summary report file when the export command is executed.

### Precondition

- Valid evidence data available in the Surveilr database.

### Test Steps

1. Execute `surveilr export --summary /reports/summary.json`.
2. Verify that the summary report is generated.
3. Validate structure and data consistency.

### Expected Result

- Summary report file created successfully.
- Output includes “Export completed successfully.”
- Exit code = 0.


