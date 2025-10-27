---
FII: "TC-ZIP-0072"
groupId: "GRP-0002"
title: "Recursive ZIP extraction"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveiler can extract nested ZIP files recursively, listing all files within nested archives.

### Test Steps
1. Prepare a ZIP file containing nested ZIP files.  
2. Upload the ZIP file via the Surveiler interface.  
3. Trigger the extraction process.  
4. Verify that all files, including those in nested archives, are listed correctly.

### Expected Result
- All nested files are extracted and listed accurately.  
- No errors occur during recursive extraction.
