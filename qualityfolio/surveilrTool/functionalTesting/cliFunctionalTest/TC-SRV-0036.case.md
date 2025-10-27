---
FII: "TC-SRV-0036"
groupId: "GRP-0001"
title: "Validate Execution of Deno Script via Surveilr Run"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["run", "script", "execution"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that `surveilr run` successfully executes a Deno-based script for automation.

### Precondition

- Valid `.ts` script exists at `/scripts/sample-script.ts`.
- Surveilr CLI runtime has Deno execution permissions.

### Test Steps

1. Execute `surveilr run /scripts/sample-script.ts`.
2. Observe terminal output and log file.
3. Check execution status.

### Expected Result

- Script executes without errors.
- Output includes “Script execution completed.”
- Exit code = 0.
