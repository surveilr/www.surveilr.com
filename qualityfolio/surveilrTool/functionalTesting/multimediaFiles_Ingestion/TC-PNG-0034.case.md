---
FII: "TC-PNG-007"
groupId: "GRP-0009"
title: "Upload extremely large PNG (>50MB)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["PNG"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Stress test system performance during upload of very large PNG files.

### Test Steps
1. Select a PNG image exceeding 50MB.  
2. Upload it through Surveiler.  
3. Monitor upload progress, timeouts, and performance logs.

### Expected Result
- System may timeout or fail gracefully.  
- No unhandled errors or crashes occur.
