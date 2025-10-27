---
FII: "TC-GLAB-0070"
groupId: "GRP-0006"
title: "Ingest Tasks from GitLab Successfully"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["GitLab"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify that Surveiler successfully ingests tasks from a valid GitLab repository.

### Test Steps
1. Connect Surveiler to a valid GitLab repository using OAuth/token.
2. Trigger task ingestion manually or via scheduled sync.
3. Wait for ingestion process to complete.
4. Check Surveiler dashboard for imported tasks.
5. Verify task metadata (title, description, assignee, labels, due date).

### Expected Result
- All tasks from GitLab are ingested correctly.
- Metadata matches GitLab.
- No errors or skipped tasks.
