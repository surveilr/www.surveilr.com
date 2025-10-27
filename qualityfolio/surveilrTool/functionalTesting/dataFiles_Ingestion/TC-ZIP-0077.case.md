---
FII: "TC-ZIP-0077"
groupId: "GRP-0002"
title: "Corrupted TAR.GZ archive handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["TAR.GZ"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveiler detects and handles corrupted TAR.GZ archives gracefully.

### Test Steps
1. Prepare a partially corrupted TAR.GZ archive.  
2. Upload the corrupted archive via the Surveiler interface.  
3. Observe system messages and extraction behavior.

### Expected Result
- Surveiler detects corruption and shows a clear error message.  
- No files are extracted.  
- System remains stable.
