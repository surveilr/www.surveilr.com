---
FII: "TC-FILEW-0006"
groupId: "GRP-0010"
title: "Multiple directories watching"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Multi-Directory"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate that Surveilr correctly ingests files when watch mode is enabled on multiple directories in a multi-folder project.

### Preconditions
- Multi-folder workspace configured.
- Surveilr watch mode initialized with two or more directories.

### Test Steps
1. Start Surveilr file-watch mode on multiple folders.
2. Add test files into each of the watched directories.
3. Monitor watch logs for events and ingestion activity.

### Expected Result
- Files placed in all watched directories are detected.
- All eligible files are ingested successfully without errors.
