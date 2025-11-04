---
FII: "TC-SRV-0040"
groupId: "GRP-0001"
title: "Validate Surveilr Admin Cleanup Command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["admin", "cleanup"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path" 
---

- Validate that `surveilr admin cleanup` removes obsolete cache and temporary files successfully.

### Precondition

- Obsolete RSSD and cache files exist in `/var/surveilr/tmp`.

### Test Steps

1. Execute `surveilr admin cleanup`.
2. Check whether temporary files are removed.
3. Verify cleanup summary in console output.

### Expected Result

- Temporary files deleted successfully.
- Output includes “Cleanup completed successfully.”
- Exit code = 0.


