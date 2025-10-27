---
FII: "TC-SRV-0039"
groupId: "GRP-0001"
title: "Validate Output Log Generation in Surveilr Run"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["run", "output", "log"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that Surveilr generates detailed output logs after successful script execution.

### Precondition

- Valid executable script available at `/scripts/log-script.ts`.
- Logging path is configured in `surveilr.config.json`.

### Test Steps

1. Execute `surveilr run /scripts/log-script.ts`.
2. Verify that the log file is generated under `/logs/surveilr-run.log`.
3. Check for presence of start and end timestamps.

### Expected Result

- Log file contains execution details, start time, and completion message.
- Exit code = 0.

