---
FII: "TC-FILEW-0002"
groupId: "GRP-0010"
title: "Upload a valid file across multiple supported types"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Multi-File-Type"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate successful ingestion of a variety of supported file formats including PDF, CSV, MD, JSON, XLSX, MP3, and MP4 when added to the watch directory.

### Preconditions
- Watch mode is active.
- System supports ingestion for the selected file types.

### Test Steps
1. Start watch mode using surveilr ingest files --watch.
2. Add each file type into the watched directory:
sample.pdf
sample.csv
sample.md
sample.json
sample.xlsx
sample.mp3
sample.mp4
3. Observe watch logs for each file.
4. Verify ingestion output or logs per file type.

### Expected Result
- Each added file is detected.
- Supported file types are ingested successfully.
- Log entries confirm ingestion status without corruption or errors.