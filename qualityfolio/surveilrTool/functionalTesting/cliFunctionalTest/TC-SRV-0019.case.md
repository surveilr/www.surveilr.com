---
FII: "TC-SRV-0019"
groupId: "GRP-0001"
title: "Validate - occupied port scenario for web-ui startup"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["web-ui", "cli", "error-handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Validate CLI behavior when the webserver is started on a port that is already in use.

### Test Steps

1. Start the `surveilr web-ui` server on the default port.  
2. Without stopping the first instance, start another `surveilr web-ui` process.  
3. Observe the console output of the second attempt.

### Expected Result

- The CLI displays an error message such as “port already in use” and aborts the startup process gracefully.