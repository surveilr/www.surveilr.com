---
FII: "TC-GIT-0060"
groupId: "GRP-0006"
title: "Insufficient Repo Permissions"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr fails gracefully when token lacks proper repository permissions.

### Test Steps
1. Configure a token without `repo` scope.  
2. Execute file ingest command on a private repo.  
3. Observe session logs for error messages.

### Expected Result
- Ingest fails with 403 permission error.  
- No partial resource entries created.  
- Session marked as failed.
