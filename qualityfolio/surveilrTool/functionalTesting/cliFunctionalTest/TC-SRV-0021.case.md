---
FII: "TC-SRV-0021"
groupId: "GRP-0001"
title: "Validate - successful UDI PostgreSQL proxy connection"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["udi", "cli", "connection", "pgp"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Verify that the `surveilr udi pgp` command starts the UDI PostgreSQL Proxy successfully, establishing a connection to the Universal Data Infrastructure.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command: surveilr udi pgp
3. Observe the CLI output logs.
4. Verify that a message such as “PostgreSQL Proxy started”, “Listening on port…”, or “Connection to UDI established” appears.

### Expected Result
- The CLI outputs a confirmation message indicating the UDI PostgreSQL proxy has started successfully and is connected to the Universal Data Infrastructure (e.g., "PostgreSQL Proxy started on 127.0.0.1:5432" or "Connection to UDI established").