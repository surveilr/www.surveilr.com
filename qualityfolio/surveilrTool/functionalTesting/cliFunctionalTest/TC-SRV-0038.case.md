---
FII: "TC-SRV-0038"
groupId: "GRP-0001"
title: "Validate Exit Code on Script Execution Failure"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["run", "exit-code", "error"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Ensure that Surveilr returns a non-zero exit code when a script execution fails due to a runtime error.

### Precondition

- `.ts` script exists with an intentional syntax error at `/scripts/error-script.ts`.

### Test Steps

1. Execute `surveilr run /scripts/error-script.ts`.
2. Observe error output and exit code.

### Expected Result

- CLI displays `Script execution failed`.
- Exit code = 9.
- No successful completion message displayed.

