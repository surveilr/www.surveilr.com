---
FII: "TC-GIT-0058"
groupId: "GRP-0006"
title: "Invalid Token"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr fails gracefully when an invalid token is used for private repo ingest.

### Test Steps
1. Configure invalid or expired token.  
2. Execute file ingest command on private repo.  
3. Monitor session logs for error.

### Expected Result
- Ingest fails with authentication error.  
- No partial records created.  
- Session status marked failed.
