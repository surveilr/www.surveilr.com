---
FII: "TC-TXT-0019"
groupId: "GRP-0003"
title: "Check - Unsupported File Renamed as .txt"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Plain Text"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "negative path"
---
### Description
- Validate that unsupported files renamed with `.txt` are rejected.

### Test Steps
1. Rename `.pdf` or `.docx` to `.txt`.  
2. Attempt upload via Surveilr.  
3. Observe system response.

### Expected Result
- File is rejected with a clear error.  
- Application does not crash.
