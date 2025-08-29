#!/usr/bin/env python
"""
surveilr_docling.py - Docling Document Processing Integration for surveilr

PURPOSE:
This module provides Docling document processing integration for surveilr Capturable 
Executables. It discovers files, processes them with Docling AI, and emits SQL for 
surveilr to capture and execute.

WHAT IT DOES:
- Discovers processable files in a directory (non-recursive)
- Processes documents with Docling AI (PDF, DOCX, DOC)  
- Handles text files as pass-through (TXT, MD)
- Creates structured JSON and Markdown transforms
- Emits atomic SQL transactions to stdout
- Provides graceful fallbacks when Docling is unavailable

FILE PROCESSING:
- Docling targets: .pdf, .docx, .doc (AI processing)
- Pass-through: .txt, .md (simple text processing)
- Unsupported formats: graceful skip with fallback content

OUTPUT STRUCTURE:
For each processed file:
1. uniform_resource: Original file content and metadata
2. uniform_resource_transform: JSON structured data from Docling
3. uniform_resource_transform: Markdown converted content  

USAGE:
    # Process files in current directory
    run_default(Path("."))
    
    # Process specific directory  
    files = discover_files(Path("/path/to/docs"))
    process_files_to_sql(files)

ERROR HANDLING:
- Missing Docling library: Falls back to basic text extraction
- Unsupported formats: Creates fallback content with error details
- Processing failures: Captured with full error context
- Stderr suppression: Docling errors hidden from SQL output

INTEGRATION:
Uses surveilr_sql.py for all SQL generation. No direct database connections.
All SQL is emitted to stdout for surveilr to capture and execute atomically.

DEPENDENCIES:
- docling>=2.0.0 (optional, graceful fallback if missing)
- surveilr_sql.py (required, for SQL generation)
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import List, Dict, Any

from lib.surveilr_sql import (
    begin, commit, emit, emit_ingest_session_begin, emit_uniform_resource_with_transforms
)

# ---------------- File type handling ----------------

DOC_EXTS = (".pdf", ".docx", ".doc")          # Docling targets
PASS_THROUGH_EXTS = (".txt", ".md")           # Pass-through files

def detect_mime_type(path: Path) -> str:
    """Detect MIME type from file extension."""
    suffix = path.suffix.lower()
    mime_types = {
        ".pdf": "application/pdf",
        ".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document", 
        ".doc": "application/msword",
        ".txt": "text/plain",
        ".md": "text/markdown",
    }
    return mime_types.get(suffix, "application/octet-stream")

def discover_files(base_dir: Path) -> List[Path]:
    """
    Discover files to process in base directory.
    Non-recursive by design for predictable CE behavior.
    """
    if not base_dir.exists() or not base_dir.is_dir():
        return []
    
    target_files = []
    all_extensions = DOC_EXTS + PASS_THROUGH_EXTS
    
    for file_path in sorted(base_dir.iterdir()):
        if file_path.is_file() and file_path.suffix.lower() in all_extensions:
            target_files.append(file_path)
    
    return target_files

# ---------------- Docling integration ----------------

def run_docling_extraction(file_path: Path) -> Dict[str, Any]:
    """
    Run Docling on the file with graceful fallbacks.
    Returns structured document data.
    """
    try:
        from docling.document_converter import DocumentConverter
        import sys
        import os
        from contextlib import redirect_stderr
        from io import StringIO
        
        # Suppress Docling error messages to stderr
        with redirect_stderr(StringIO()):
            converter = DocumentConverter()
            result = converter.convert(file_path)
        
        # Extract structured data - use model_dump with mode='json' for serialization
        doc_data = result.document.model_dump(mode='json')
        return {
            "success": True,
            "doc_data": doc_data,
            "markdown": result.document.export_to_markdown(),
            "processor": "docling",
            "version": "real"
        }
        
    except ImportError:
        # Docling not available - use fallback
        return create_fallback_extraction(file_path, "docling_not_installed")
    except ValueError as e:
        # Docling format not supported - skip gracefully
        if "does not match any allowed format" in str(e):
            return create_fallback_extraction(file_path, f"format_not_supported: {file_path.suffix}")
        else:
            return create_fallback_extraction(file_path, f"docling_value_error: {e}")
    except Exception as e:
        # Docling failed - use fallback
        return create_fallback_extraction(file_path, f"docling_error: {e}")

def create_fallback_extraction(file_path: Path, reason: str) -> Dict[str, Any]:
    """Create fallback extraction when Docling is unavailable or fails."""
    # For text files, read content directly
    if file_path.suffix.lower() in ('.txt', '.md'):
        try:
            content = file_path.read_text(encoding='utf-8')
            markdown = f"# {file_path.name}\n\n{content}"
        except Exception:
            content = f"Could not read {file_path.name}"
            markdown = f"# {file_path.name}\n\n{content}"
    else:
        content = f"Binary file: {file_path.name}"
        markdown = f"# {file_path.name}\n\n*Binary document - {reason}*"
    
    return {
        "success": False,
        "reason": reason,
        "doc_data": {
            "source": str(file_path),
            "texts": [{"text": content, "label": "fallback"}],
            "tables": [],
            "pictures": [],
            "extraction_info": {"processor": "fallback", "reason": reason}
        },
        "markdown": markdown,
        "processor": "fallback",
        "version": "1.0"
    }

# ---------------- Main processing workflow ----------------

def process_files_to_sql(files: List[Path], device_id: str = "01K3HP14NN7H947E2WZ92G0QZS") -> None:
    """
    Process files using Docling and emit SQL for surveilr.
    Uses the comprehensive surveilr_sql library for all operations.
    """
    if not files:
        return
    
    begin()
    
    # Create ingest session
    session_agent = {
        "name": "docling-processor",
        "version": "2.0.0",
        "type": "document_extraction",
        "library": "docling"
    }
    
    session_id = emit_ingest_session_begin(device_id, session_agent)
    
    # Process each file
    for file_path in files:
        emit(f"-- Processing: {file_path.name}")
        
        # Extract with Docling
        extraction_result = run_docling_extraction(file_path)
        
        # Read file content
        try:
            file_content = file_path.read_bytes()
        except Exception:
            file_content = None
        
        # Prepare transforms
        transforms = []
        
        # Add JSON transform (always available)
        json_content = json.dumps(extraction_result["doc_data"], indent=2, ensure_ascii=False)
        transforms.append({
            "uri": f"{file_path.absolute()}.docling.json", 
            "content": json_content,
            "nature": "application/json",
            "elaboration": {
                "transform_type": "docling_structured_data",
                "processor": extraction_result["processor"],
                "success": extraction_result["success"]
            }
        })
        
        # Add markdown transform if available
        if extraction_result.get("markdown"):
            transforms.append({
                "uri": f"{file_path.absolute()}.docling.md",
                "content": extraction_result["markdown"], 
                "nature": "text/markdown",
                "elaboration": {
                    "transform_type": "docling_markdown",
                    "processor": extraction_result["processor"],
                    "success": extraction_result["success"]
                }
            })
        
        # Emit resource and transforms
        emit_uniform_resource_with_transforms(
            device_id=device_id,
            ingest_session_id=session_id,
            uri=str(file_path.absolute()),
            content_bytes=file_content,
            nature=detect_mime_type(file_path),
            elaboration={
                "docling_processed": True,
                "source_file": file_path.name,
                "extraction_success": extraction_result["success"],
                "processor": extraction_result["processor"]
            },
            transforms=transforms
        )
    
    commit()

def run_default(base: Path = Path(".")) -> None:
    """
    Default entry point for CEs.
    Discovers files in base directory and processes them.
    """
    files = discover_files(base)
    if files:
        emit(f"-- Found {len(files)} files to process")
        process_files_to_sql(files)
    else:
        emit("-- No files found to process")