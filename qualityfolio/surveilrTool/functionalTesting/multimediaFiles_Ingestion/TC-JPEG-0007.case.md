---
FII: "TC-JPEG-007"
groupId: "GRP-0009"
title: "Upload extremely large JPEG (>50MB)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["JPEG"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate system performance and failure behavior under large JPEG file uploads.

### Test Steps
1. Select a JPEG image larger than 50MB.  
2. Upload it to the Surveiler system.  
3. Monitor upload progress, timeout, and error handling.

### Expected Result
- System may timeout or fail gracefully.  
- No unhandled crashes occur; performance metrics are logged.
