---
FII: "TC-ZIP-0070"
groupId: "GRP-0002"
title: "Archive containing large number of files"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveiler can extract archives containing a very large number of files (1000+).

### Test Steps
1. Prepare a ZIP archive containing 1000+ files.  
2. Upload the archive via the Surveiler interface.  
3. Trigger extraction and verify all files are listed correctly.

### Expected Result
- All files are extracted and listed accurately.  
- System does not crash or hang.  
- Performance remains within acceptable limits.
