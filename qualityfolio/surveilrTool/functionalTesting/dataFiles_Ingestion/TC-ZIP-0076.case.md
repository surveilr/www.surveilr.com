---
FII: "TC-ZIP-0076"
groupId: "GRP-0002"
title: "Corrupted ZIP archive handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveiler detects and handles corrupted ZIP files gracefully.

### Test Steps
1. Prepare a partially corrupted ZIP file.  
2. Upload the corrupted ZIP via the Surveiler interface.  
3. Observe system messages and extraction behavior.

### Expected Result
- Surveiler detects the corruption and shows an error.  
- Partial extraction does not occur.  
- System remains stable.
