---
FII: "TC-GIT-0050"
groupId: "GRP-0006"
title: "Private Repo Ingest with Valid Token"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate that Surveilr ingests all files and metadata from a private GitHub repo using a valid PAT token.

### Test Steps
1. Configure valid PAT with appropriate scopes.  
2. Run file ingest command on private repo URL.  
3. Verify all files, commit metadata, and branches in `uniform_resource`.

### Expected Result
- Ingestion completes successfully.  
- All files and commit data recorded.  
- Sensitive info handled per configuration.
