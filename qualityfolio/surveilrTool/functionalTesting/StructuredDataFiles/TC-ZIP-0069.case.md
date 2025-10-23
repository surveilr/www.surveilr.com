---
FII: "TC-ZIP-0069"
groupId: "GRP-0002"
title: "Upload valid TAR.GZ file locally"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["TAR.GZ"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveiler can successfully upload and extract a valid TAR.GZ archive through the local upload interface.

### Test Steps
1. Navigate to the Surveiler Upload section.  
2. Select a valid TAR.GZ file from local storage.  
3. Click the Upload button.  
4. Observe the file extraction process and verify the extracted file list.

### Expected Result
- TAR.GZ file uploads successfully.  
- All contained files are extracted and listed.  
- No errors displayed.
