---
FII: "TC-SRV-0037"
groupId: "GRP-0001"
title: "Validate Error Handling for Invalid Path in Surveilr Run"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["run", "error-handling", "invalid-path"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Verify that `surveilr run` throws an appropriate error when provided with an invalid or non-existent file path.

### Precondition

- No file exists at `/invalid/path/script.ts`.

### Test Steps

1. Execute `surveilr run /invalid/path/script.ts`.
2. Observe CLI output and exit status.

### Expected Result

- CLI displays `Error: File not found`.
- Exit code = 6.
- No output file is created.
