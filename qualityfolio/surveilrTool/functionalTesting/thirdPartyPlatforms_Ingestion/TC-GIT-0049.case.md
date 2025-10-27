---
FII: "TC-GIT-0049"
groupId: "GRP-0006"
title: "Full Ingest of Public GitHub Repo"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate that Surveilr ingests all files, branches, and commit metadata from a public GitHub repository using the file ingest command.

### Test Steps
1. Execute file ingest command on a public GitHub repo URL.  
2. Monitor ingestion process for completion.  
3. Query `uniform_resource` table for all files and metadata.

### Expected Result
- All files, branches, tags, and commits ingested successfully.  
- Session marked as success in Surveilr.  
- Provenance fields correctly populated.
