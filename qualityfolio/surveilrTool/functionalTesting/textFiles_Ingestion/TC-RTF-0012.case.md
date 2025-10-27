---
FII: "TC-RTF-0012"
groupId: "GRP-0003"
title: "Check - RTF Unsupported Elements Detection"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["RTF"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate detection and logging of unsupported or uncommon RTF elements.

### Test Steps
1. Prepare an RTF file containing unsupported or uncommon elements.  
2. Upload the file via Surveilr.  
3. Open and render the file.  
4. Observe detection and logging of unsupported elements.

### Expected Result
- Unsupported elements are detected, logged, and users are notified gracefully.
