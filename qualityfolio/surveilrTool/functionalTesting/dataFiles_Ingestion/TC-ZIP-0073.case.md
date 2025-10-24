---
FII: "TC-ZIP-0073"
groupId: "GRP-0002"
title: "Recursive TAR.GZ extraction"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["TAR.GZ"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveiler can extract nested TAR.GZ archives recursively, listing all files within nested archives.

### Test Steps
1. Prepare a TAR.GZ archive containing nested TAR.GZ files.  
2. Upload the archive via the Surveiler interface.  
3. Trigger the extraction process.  
4. Verify that all files, including those in nested archives, are listed correctly.

### Expected Result
- All nested files are extracted and listed accurately.  
- No errors occur during recursive extraction.
