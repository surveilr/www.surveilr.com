## Overview
The `surveilr_ingest_session_id` function generates or retrieves a unique session identifier (`ur_ingest_session_id`) for an ingestion session.

---

## Purpose
- **Retrieve Existing Sessions**: Reuse existing session IDs when a session is already associated with the specified device and session metadata.
- **Create New Sessions**: Generate a new session ID when no matching session exists.

---

## Inputs
This function does not take any arguments.

---

## Outputs
Returns a `STRING` representing the `ur_ingest_session_id`. This ID is either:
1. The ID of an existing session, or
2. A newly generated ID if no existing session is found.