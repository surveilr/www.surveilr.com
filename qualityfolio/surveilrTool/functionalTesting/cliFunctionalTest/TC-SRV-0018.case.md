---
FII: "TC-SRV-0018"
groupId: "GRP-0001"
title: "Validate - successful SQLPage webserver startup"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["web-ui", "cli", "server-startup"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Ensure the webserver starts successfully when executing the `surveilr web-ui` command.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr web-ui`.  
3. Observe the console logs for server startup messages.  
4. Verify that the port and URL information are displayed.

### Expected Result

- The CLI starts the SQLPage webserver successfully and outputs a message showing the server address and port (e.g., `Server running at http://localhost:9000`).