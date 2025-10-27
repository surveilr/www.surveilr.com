---
FII: "TC-AWS-006"
groupId: "GRP-0006"
title: "Verify Line-Based Log Integration (CloudWatch Logs)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify CloudWatch logs are correctly ingested line-by-line into Surveilr schema.

### Test Steps
1. Configure Surveilr to fetch CloudWatch logs.  
2. Start ingestion and monitor progress.  
3. Compare log lines with AWS source logs.  
4. Review timestamps and message parsing.

### Expected Result
- Each log line stored correctly with accurate timestamps.  
- No parsing or encoding errors.  
- Surveilr ingestion summary matches AWS log count.
