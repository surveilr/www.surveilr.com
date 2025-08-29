#!/usr/bin/env python
"""
e2e-test.surveilr-SQL.py - Docling Capturable Executable for surveilr

PURPOSE:
This is a minimal Capturable Executable (CE) that surveilr can discover and execute
to process documents with Docling AI. It delegates all logic to surveilr_docling.py
and emits SQL to stdout for surveilr to capture.

EXECUTION MODEL:
- No command-line arguments or environment variables
- Processes files in ./support/test-fixtures/ directory  
- Emits SQL statements to stdout (surveilr captures these)
- All business logic delegated to library modules

WHAT HAPPENS:
1. Discovers processable documents in test-fixtures directory
2. Processes each file with Docling AI (or fallback)
3. Generates uniform_resource and uniform_resource_transform records
4. Outputs complete BEGIN...COMMIT transaction to stdout
5. surveilr captures stdout and executes the SQL

USAGE:
    # Direct execution (for testing)
    e2e-test.surveilr-SQL.py > output.sql
    
    # surveilr execution (production)  
    # surveilr automatically discovers and runs this CE

FILE DISCOVERY:
Currently hardcoded to process ./support/test-fixtures/ directory.
This can be modified by changing the Path parameter in main().

ARCHITECTURE BENEFITS:
- Ultra-thin CE: All logic in reusable libraries
- No database connections: Pure SQL emission  
- Atomic transactions: Single BEGIN/COMMIT batch
- Reusable: Other CEs can import and use same libraries

INTEGRATION:
Part of surveilr's Capturable Executable ecosystem. When surveilr runs
in a directory containing this file, it will automatically execute it
and capture the SQL output for database ingestion.
"""
from __future__ import annotations

from pathlib import Path
import surveilr_docling as docling

def main() -> None:
    # Process current directory; drop files here before running.
    docling.run_default(base=Path("./lib/assurance/test-fixtures"))

if __name__ == "__main__":
    main()