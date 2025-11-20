---
FII: "TC-FILEW-0008"
groupId: "GRP-0010"
title: "Invalid watch-include syntax provided"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Configuration"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---
### Description
- Validate system response when watch-include pattern is incorrectly formatted.

### Preconditions
- Run Surveilr in file-watch mode.

### Test Steps
1. Start file-watch with the parameter:
--watch-include ".pdf;.docx"

markdown
Copy code
2. Observe output.

### Expected Result
- Error message: “Invalid include pattern”.
- Watch process does not start.
