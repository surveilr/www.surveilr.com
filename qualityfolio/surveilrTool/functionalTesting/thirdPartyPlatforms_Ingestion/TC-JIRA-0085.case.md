---
FII: "TC-JIRA-0085"
groupId: "GRP-0006"
title: "File Too Large"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr behavior on oversized Jira export files.

### Test Steps
1. Provide a very large Jira export file exceeding configured limit.  
2. Run file ingest command.  
3. Observe session logs and `uniform_resource`.

### Expected Result
- File skipped or partially ingested per policy.  
- Session logs indicate file size limit exceeded.
