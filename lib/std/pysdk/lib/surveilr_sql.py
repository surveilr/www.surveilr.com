#!/usr/bin/env python
"""
surveilr_sql.py - Comprehensive surveilr SQL Library for Capturable Executables

PURPOSE:
This library provides type-safe SQLAlchemy Core table definitions and SQL generation 
utilities for surveilr's uniform_resource ecosystem. It enables Capturable Executables 
to emit proper SQL without database connections.

KEY FEATURES:
- Type-safe SQLAlchemy Core v2 definitions for uniform_resource and ur_* tables
- No database connections - pure SQL text generation 
- ULID-compatible ID generation (with UUID4 fallback)
- Safe SQL rendering with proper escaping
- Helper functions for common CE operations
- Atomic transaction support (BEGIN/COMMIT)

TABLE DEFINITIONS INCLUDED:
- device (referenced by ur tables)
- ur_ingest_session (ingest session management)
- uniform_resource (primary content storage)  
- uniform_resource_transform (processed/transformed content)

USAGE EXAMPLES:

1. Basic INSERT generation:
    stmt = ins_uniform_resource(
        device_id="01K3HP14NN7H947E2WZ92G0QZS",
        ingest_session_id="session-id", 
        uri="/path/to/file.pdf",
        content_digest="sha256-hash",
        nature="application/pdf"
    )
    print(render_sql(stmt))

2. Complete CE workflow:
    begin()
    session_id = emit_ingest_session_begin(device_id, agent_info)
    emit_uniform_resource_with_transforms(
        device_id=device_id,
        ingest_session_id=session_id,
        uri=file_path,
        content_bytes=file_content,
        transforms=[...] 
    )
    commit()

INTEGRATION:
This library is designed to be imported by any surveilr Capturable Executable.
All CEs should use this for consistent SQL generation and proper table relationships.

DEPENDENCIES:
- sqlalchemy>=2.0.0 (Core v2 with type safety)
- python-ulid>=2.2.0 (optional, falls back to uuid4)
"""
from __future__ import annotations

import json
import hashlib
from typing import Optional, Dict, Any
from datetime import datetime

try:
    from ulid import ULID
    def generate_ulid() -> str:
        """Generate a ULID string compatible with surveilr."""
        return str(ULID())
except ImportError:
    # Fallback to UUID4 if ULID library not available
    import uuid
    def generate_ulid() -> str:
        """Generate a UUID4 as fallback when ULID library not available."""
        return str(uuid.uuid4())

from sqlalchemy import (
    MetaData, Table, Column,
    Integer, String, Text, LargeBinary, insert, ForeignKey,
    CheckConstraint, UniqueConstraint, func, text
)
from sqlalchemy.dialects import sqlite

# ===== SQLAlchemy Core Metadata (uniform_resource and ur_* tables only) =====

metadata = MetaData()

# ----- Device Table (referenced by ur tables) -----

device = Table(
    "device",
    metadata,
    Column("device_id", String, primary_key=True, nullable=False),
    Column("name", Text, nullable=False),
    Column("state", Text, CheckConstraint("json_valid(state)"), nullable=False),
    Column("boundary", Text, nullable=False),
    Column("segmentation", Text, CheckConstraint("json_valid(segmentation) OR segmentation IS NULL")),
    Column("state_sysinfo", Text, CheckConstraint("json_valid(state_sysinfo) OR state_sysinfo IS NULL")),
    Column("elaboration", Text, CheckConstraint("json_valid(elaboration) OR elaboration IS NULL")),
    Column("created_at", Text, server_default="CURRENT_TIMESTAMP"),
    Column("created_by", Text, server_default="'UNKNOWN'"),
    Column("updated_at", Text),
    Column("updated_by", Text),
    Column("deleted_at", Text),
    Column("deleted_by", Text),
    Column("activity_log", Text),
    UniqueConstraint("name", "state", "boundary"),
)

# ----- Ingest Session Tables -----

ur_ingest_session = Table(
    "ur_ingest_session",
    metadata,
    Column("ur_ingest_session_id", String, primary_key=True, nullable=False),
    Column("device_id", String, ForeignKey("device.device_id"), nullable=False),
    Column("behavior_id", String),
    Column("behavior_json", Text, CheckConstraint("json_valid(behavior_json) OR behavior_json IS NULL")),
    Column("ingest_started_at", Text, nullable=False),
    Column("ingest_finished_at", Text),
    Column("session_agent", Text, CheckConstraint("json_valid(session_agent)"), nullable=False),
    Column("elaboration", Text, CheckConstraint("json_valid(elaboration) OR elaboration IS NULL")),
    Column("created_at", Text, server_default="CURRENT_TIMESTAMP"),
    Column("created_by", Text, server_default="'UNKNOWN'"),
    Column("updated_at", Text),
    Column("updated_by", Text),
    Column("deleted_at", Text),
    Column("deleted_by", Text),
    Column("activity_log", Text),
    UniqueConstraint("device_id", "created_at"),
)

ur_ingest_session_fs_path = Table(
    "ur_ingest_session_fs_path",
    metadata,
    Column("ur_ingest_session_fs_path_id", String, primary_key=True, nullable=False),
    Column("ingest_session_id", String, ForeignKey("ur_ingest_session.ur_ingest_session_id"), nullable=False),
    Column("root_path", Text, nullable=False),
    Column("elaboration", Text, CheckConstraint("json_valid(elaboration) OR elaboration IS NULL")),
    Column("created_at", Text, server_default="CURRENT_TIMESTAMP"),
    Column("created_by", Text, server_default="'UNKNOWN'"),
    Column("updated_at", Text),
    Column("updated_by", Text),
    Column("deleted_at", Text),
    Column("deleted_by", Text),
    Column("activity_log", Text),
    UniqueConstraint("ingest_session_id", "root_path", "created_at"),
)

# ----- Core Uniform Resource Tables -----

uniform_resource = Table(
    "uniform_resource",
    metadata,
    Column("uniform_resource_id", String, primary_key=True, nullable=False),
    Column("device_id", String, ForeignKey("device.device_id"), nullable=False),
    Column("ingest_session_id", String, ForeignKey("ur_ingest_session.ur_ingest_session_id"), nullable=False),
    Column("ingest_fs_path_id", String, ForeignKey("ur_ingest_session_fs_path.ur_ingest_session_fs_path_id")),
    Column("ingest_session_imap_acct_folder_message", String),
    Column("ingest_issue_acct_project_id", String),
    Column("uri", Text, nullable=False),
    Column("content_digest", Text, nullable=False),
    Column("content", LargeBinary),
    Column("nature", Text),
    Column("size_bytes", Integer),
    Column("last_modified_at", Text),
    Column("content_fm_body_attrs", Text, CheckConstraint("json_valid(content_fm_body_attrs) OR content_fm_body_attrs IS NULL")),
    Column("frontmatter", Text, CheckConstraint("json_valid(frontmatter) OR frontmatter IS NULL")),
    Column("elaboration", Text, CheckConstraint("json_valid(elaboration) OR elaboration IS NULL")),
    Column("created_at", Text, server_default="CURRENT_TIMESTAMP"),
    Column("created_by", Text, server_default="'UNKNOWN'"),
    Column("updated_at", Text),
    Column("updated_by", Text),
    Column("deleted_at", Text),
    Column("deleted_by", Text),
    Column("activity_log", Text),
    UniqueConstraint("device_id", "content_digest", "uri", "size_bytes"),
)

uniform_resource_transform = Table(
    "uniform_resource_transform",
    metadata,
    Column("uniform_resource_transform_id", String, primary_key=True, nullable=False),
    Column("uniform_resource_id", String, ForeignKey("uniform_resource.uniform_resource_id"), nullable=False),
    Column("uri", Text, nullable=False),
    Column("content_digest", Text, nullable=False),
    Column("content", LargeBinary),
    Column("nature", Text),
    Column("size_bytes", Integer),
    Column("elaboration", Text, CheckConstraint("json_valid(elaboration) OR elaboration IS NULL")),
    Column("created_at", Text, server_default="CURRENT_TIMESTAMP"),
    Column("created_by", Text, server_default="'UNKNOWN'"),
    Column("updated_at", Text),
    Column("updated_by", Text),
    Column("deleted_at", Text),
    Column("deleted_by", Text),
    Column("activity_log", Text),
    UniqueConstraint("uniform_resource_id", "content_digest", "nature", "size_bytes"),
)

ur_ingest_session_fs_path_entry = Table(
    "ur_ingest_session_fs_path_entry",
    metadata,
    Column("ur_ingest_session_fs_path_entry_id", String, primary_key=True, nullable=False),
    Column("ingest_session_id", String, ForeignKey("ur_ingest_session.ur_ingest_session_id"), nullable=False),
    Column("ingest_fs_path_id", String, ForeignKey("ur_ingest_session_fs_path.ur_ingest_session_fs_path_id"), nullable=False),
    Column("uniform_resource_id", String, ForeignKey("uniform_resource.uniform_resource_id")),
    Column("file_path_abs", Text, nullable=False),
    Column("file_path_rel_parent", Text, nullable=False),
    Column("file_path_rel", Text, nullable=False),
    Column("file_basename", Text, nullable=False),
    Column("file_extn", Text),
    Column("captured_executable", Text, CheckConstraint("json_valid(captured_executable) OR captured_executable IS NULL")),
    Column("ur_status", Text),
    Column("ur_diagnostics", Text, CheckConstraint("json_valid(ur_diagnostics) OR ur_diagnostics IS NULL")),
    Column("ur_transformations", Text, CheckConstraint("json_valid(ur_transformations) OR ur_transformations IS NULL")),
    Column("elaboration", Text, CheckConstraint("json_valid(elaboration) OR elaboration IS NULL")),
    Column("created_at", Text, server_default="CURRENT_TIMESTAMP"),
    Column("created_by", Text, server_default="'UNKNOWN'"),
    Column("updated_at", Text),
    Column("updated_by", Text),
    Column("deleted_at", Text),
    Column("deleted_by", Text),
    Column("activity_log", Text),
)

ur_ingest_session_task = Table(
    "ur_ingest_session_task",
    metadata,
    Column("ur_ingest_session_task_id", String, primary_key=True, nullable=False),
    Column("ingest_session_id", String, ForeignKey("ur_ingest_session.ur_ingest_session_id"), nullable=False),
    Column("uniform_resource_id", String, ForeignKey("uniform_resource.uniform_resource_id")),
    Column("captured_executable", Text, CheckConstraint("json_valid(captured_executable)"), nullable=False),
    Column("ur_status", Text),
    Column("ur_diagnostics", Text, CheckConstraint("json_valid(ur_diagnostics) OR ur_diagnostics IS NULL")),
    Column("ur_transformations", Text, CheckConstraint("json_valid(ur_transformations) OR ur_transformations IS NULL")),
    Column("elaboration", Text, CheckConstraint("json_valid(elaboration) OR elaboration IS NULL")),
    Column("created_at", Text, server_default="CURRENT_TIMESTAMP"),
    Column("created_by", Text, server_default="'UNKNOWN'"),
    Column("updated_at", Text),
    Column("updated_by", Text),
    Column("deleted_at", Text),
    Column("deleted_by", Text),
    Column("activity_log", Text),
)

# ===== SQL Compilation and Emission Utilities =====

_SQLITE = sqlite.dialect()

def render_sql(stmt) -> str:
    """
    Compile a SQLAlchemy statement to literal SQL for SQLite.
    literal_binds=True ensures proper quoting/escaping of values.
    """
    return str(stmt.compile(dialect=_SQLITE, compile_kwargs={"literal_binds": True}))

def emit(sql_text_str: str) -> None:
    """Print a single SQL statement with a trailing semicolon."""
    print(sql_text_str.rstrip().rstrip(";") + ";")

def begin() -> None:
    """Start a transaction block."""
    print("BEGIN;")

def commit() -> None:
    """Commit a transaction block."""
    print("COMMIT;")

def rollback() -> None:
    """Rollback a transaction block."""
    print("ROLLBACK;")

# ===== Helper Functions for Common Operations =====

def compute_content_digest(content: bytes) -> str:
    """Compute SHA256 hash of content."""
    return hashlib.sha256(content).hexdigest()

def safe_json_dumps(obj: Any) -> str:
    """Safely serialize object to JSON string."""
    return json.dumps(obj, ensure_ascii=False, default=str)

# ===== INSERT Statement Builders =====

def ins_ur_ingest_session(
    *,
    ur_ingest_session_id: Optional[str] = None,
    device_id: str,
    behavior_id: Optional[str] = None,
    behavior_json: Optional[Dict[str, Any]] = None,
    ingest_started_at: str = "CURRENT_TIMESTAMP",
    ingest_finished_at: Optional[str] = None,
    session_agent: Dict[str, Any],
    elaboration: Optional[Dict[str, Any]] = None,
    created_by: str = "'UNKNOWN'"
) -> insert:
    """Generate INSERT statement for ur_ingest_session table."""
    return insert(ur_ingest_session).values(
        ur_ingest_session_id=ur_ingest_session_id or generate_ulid(),
        device_id=device_id,
        behavior_id=behavior_id,
        behavior_json=safe_json_dumps(behavior_json) if behavior_json else None,
        ingest_started_at=ingest_started_at,
        ingest_finished_at=ingest_finished_at,
        session_agent=safe_json_dumps(session_agent),
        elaboration=safe_json_dumps(elaboration) if elaboration else None,
        created_by=created_by,
    )

def ins_uniform_resource(
    *,
    uniform_resource_id: Optional[str] = None,
    device_id: str,
    ingest_session_id: str,
    uri: str,
    content_digest: str,
    content_bytes: Optional[bytes] = None,
    nature: Optional[str] = None,
    size_bytes: Optional[int] = None,
    last_modified_at: Optional[str] = None,
    content_fm_body_attrs: Optional[Dict[str, Any]] = None,
    frontmatter: Optional[Dict[str, Any]] = None,
    elaboration: Optional[Dict[str, Any]] = None,
    created_by: str = "'UNKNOWN'"
) -> insert:
    """Generate INSERT statement for uniform_resource table."""
    return insert(uniform_resource).values(
        uniform_resource_id=uniform_resource_id or generate_ulid(),
        device_id=device_id,
        ingest_session_id=ingest_session_id,
        uri=uri,
        content_digest=content_digest,
        content=content_bytes,
        nature=nature,
        size_bytes=size_bytes,
        last_modified_at=last_modified_at,
        content_fm_body_attrs=safe_json_dumps(content_fm_body_attrs) if content_fm_body_attrs else None,
        frontmatter=safe_json_dumps(frontmatter) if frontmatter else None,
        elaboration=safe_json_dumps(elaboration) if elaboration else None,
        created_by=created_by,
    )

def ins_uniform_resource_transform(
    *,
    uniform_resource_transform_id: Optional[str] = None,
    uniform_resource_id: str,
    uri: str,
    content_digest: str,
    content_bytes: Optional[bytes] = None,
    nature: Optional[str] = None,
    size_bytes: Optional[int] = None,
    elaboration: Optional[Dict[str, Any]] = None,
    created_by: str = "'UNKNOWN'"
) -> insert:
    """Generate INSERT statement for uniform_resource_transform table."""
    return insert(uniform_resource_transform).values(
        uniform_resource_transform_id=uniform_resource_transform_id or generate_ulid(),
        uniform_resource_id=uniform_resource_id,
        uri=uri,
        content_digest=content_digest,
        content=content_bytes,
        nature=nature,
        size_bytes=size_bytes,
        elaboration=safe_json_dumps(elaboration) if elaboration else None,
        created_by=created_by,
    )

# ===== Content Update Utilities =====

def update_uniform_resource_content(uniform_resource_id: str, content_text: str) -> str:
    """Generate UPDATE statement for uniform_resource content field."""
    escaped_content = content_text.replace("'", "''")
    return f'UPDATE "uniform_resource" SET "content" = \'{escaped_content}\' WHERE "uniform_resource_id" = \'{uniform_resource_id}\''

def update_uniform_resource_transform_content(uniform_resource_transform_id: str, content_text: str) -> str:
    """Generate UPDATE statement for uniform_resource_transform content field."""
    escaped_content = content_text.replace("'", "''")
    return f'UPDATE "uniform_resource_transform" SET "content" = \'{escaped_content}\' WHERE "uniform_resource_transform_id" = \'{uniform_resource_transform_id}\''

# ===== High-Level Workflow Functions =====

def emit_ingest_session_begin(device_id: str, session_agent: Dict[str, Any]) -> str:
    """Create and emit an ingest session, return session_id."""
    session_id = generate_ulid()
    stmt = ins_ur_ingest_session(
        ur_ingest_session_id=session_id,
        device_id=device_id,
        session_agent=session_agent
    )
    emit(render_sql(stmt))
    return session_id

def emit_uniform_resource_with_transforms(
    *,
    device_id: str,
    ingest_session_id: str,
    uri: str,
    content_bytes: Optional[bytes] = None,
    nature: Optional[str] = None,
    elaboration: Optional[Dict[str, Any]] = None,
    transforms: Optional[list] = None
) -> str:
    """
    Emit a uniform_resource and its transforms in one batch.
    Returns the uniform_resource_id.
    
    transforms: List of dicts with keys: uri, content, nature, elaboration
    """
    # Calculate content digest
    if content_bytes:
        content_digest = compute_content_digest(content_bytes)
        size_bytes = len(content_bytes)
    else:
        content_digest = "no-content"
        size_bytes = 0
    
    # Generate resource ID
    resource_id = generate_ulid()
    
    # Emit uniform_resource (without content to avoid literal issues)
    resource_stmt = ins_uniform_resource(
        uniform_resource_id=resource_id,
        device_id=device_id,
        ingest_session_id=ingest_session_id,
        uri=uri,
        content_digest=content_digest,
        content_bytes=None,  # Set separately
        nature=nature,
        size_bytes=size_bytes,
        elaboration=elaboration
    )
    emit(render_sql(resource_stmt))
    
    # Update content if provided
    if content_bytes:
        emit(f"-- Binary content for {uri} ({len(content_bytes)} bytes) available")
    
    # Emit transforms
    if transforms:
        for transform in transforms:
            transform_content = transform.get("content", "")
            transform_digest = compute_content_digest(transform_content.encode('utf-8'))
            transform_id = generate_ulid()
            
            transform_stmt = ins_uniform_resource_transform(
                uniform_resource_transform_id=transform_id,
                uniform_resource_id=resource_id,
                uri=transform.get("uri", f"{resource_id}.transform"),
                content_digest=transform_digest,
                content_bytes=None,  # Set separately
                nature=transform.get("nature"),
                size_bytes=len(transform_content.encode('utf-8')),
                elaboration=transform.get("elaboration")
            )
            emit(render_sql(transform_stmt))
            
            # Update transform content
            if transform_content:
                emit(update_uniform_resource_transform_content(transform_id, transform_content))
    
    return resource_id