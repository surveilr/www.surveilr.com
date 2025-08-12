#!/usr/bin/env python3
"""
Batch processing Capturable Executable
Processes all supported documents in current directory and emits SQL

This CapEx processes all PDF, DOCX, XLSX, and PPTX files in the current
directory using Python markitdown and emits SQL INSERT statements that can be
executed against a surveilr database to populate uniform_resource and related tables.

Usage: python3 all-in-current-dir.surveilr-SQL.py [directory]
If no directory is provided, uses current directory.
Requires: pip install markitdown
"""

import sys
import json
import subprocess
import os
import time
import hashlib
import re
from pathlib import Path
from datetime import datetime
import argparse

def generate_ulid():
    """Generate a simple ULID-like ID for database records"""
    import random
    import string
    # Use timestamp (last 8 digits) + random chars for uniqueness
    timestamp = str(int(time.time() * 1000))[-8:]
    random_part = ''.join(random.choices(string.ascii_uppercase + string.digits, k=18))
    return f"{timestamp}{random_part}"

def calculate_hash(content):
    """Calculate SHA1 hash of content"""
    return hashlib.sha1(content.encode()).hexdigest()

def get_mime_type(file_extension):
    """Return MIME type for file extension"""
    mime_types = {
        '.pdf': 'application/pdf',
        '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        '.doc': 'application/msword',
        '.pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        '.ppt': 'application/vnd.ms-powerpoint',
        '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        '.xls': 'application/vnd.ms-excel'
    }
    return mime_types.get(file_extension.lower(), 'application/octet-stream')

def analyze_markdown_structure(markdown_content):
    """Analyze markdown content for structural elements"""
    lines = markdown_content.split('\n')
    
    structure = {
        'heading_count': len([line for line in lines if line.startswith('#')]),
        'list_count': len([line for line in lines if line.strip().startswith(('-', '*', '+')) or re.match(r'^\d+\.', line.strip())]),
        'table_count': len([line for line in lines if '|' in line and line.count('|') >= 2]),
        'code_block_count': len([line for line in lines if line.strip().startswith('```')]),
        'link_count': len([line for line in lines if '[' in line and '](' in line]),
        'line_count': len(lines),
        'paragraph_count': len([line for line in lines if line.strip() and not line.startswith(('#', '-', '*', '+', '|', '```'))])
    }
    
    return structure

def process_file_with_markitdown(file_path):
    """Process file using markitdown and return structured results"""
    start_time = time.time()
    
    try:
        result = subprocess.run(
            ['markitdown', file_path],
            capture_output=True,
            text=True,
            check=True,
            timeout=120  # 2 minute timeout for larger files
        )
        
        end_time = time.time()
        conversion_time = (end_time - start_time) * 1000
        
        markdown_content = result.stdout
        structure_analysis = analyze_markdown_structure(markdown_content)
        content_hash = calculate_hash(markdown_content)
        
        return {
            'success': True,
            'content': markdown_content,
            'conversion_time_ms': conversion_time,
            'content_hash': content_hash,
            'structure': structure_analysis,
            'error': None
        }
        
    except subprocess.CalledProcessError as e:
        return {
            'success': False,
            'content': f"<!-- Conversion failed: {e.stderr} -->",
            'conversion_time_ms': (time.time() - start_time) * 1000,
            'content_hash': '',
            'structure': {},
            'error': f"markitdown failed: {e.stderr}"
        }
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'content': "<!-- Conversion timed out after 2 minutes -->",
            'conversion_time_ms': (time.time() - start_time) * 1000,
            'content_hash': '',
            'structure': {},
            'error': "Conversion timed out after 2 minutes"
        }
    except FileNotFoundError:
        return {
            'success': False,
            'content': "<!-- markitdown not installed -->",
            'conversion_time_ms': 0,
            'content_hash': '',
            'structure': {},
            'error': "markitdown not found - install with: pip install markitdown"
        }

def escape_sql(s):
    """Escape SQL strings safely"""
    if s is None:
        return ''
    return s.replace("'", "''")

def generate_sql_insert(file_path, result):
    """Generate SQL INSERT statements for uniform_resource table"""
    
    # Generate unique IDs
    uniform_resource_id = generate_ulid()
    device_id = generate_ulid() 
    ingest_session_id = generate_ulid()
    
    # Get file metadata
    abs_path = os.path.abspath(file_path)
    file_stat = os.stat(abs_path)
    file_size = file_stat.st_size
    modified_time = int(file_stat.st_mtime)
    current_time = datetime.now().isoformat()
    
    # Determine file properties
    file_extension = Path(file_path).suffix.lower()
    nature = file_extension.lstrip('.')
    mime_type = get_mime_type(file_extension)
    
    # Create comprehensive frontmatter metadata
    frontmatter = {
        'converted_by': 'python_markitdown_batch_capex',
        'source_file': abs_path,
        'file_size_bytes': file_size,
        'conversion_time_ms': result['conversion_time_ms'],
        'conversion_success': result['success'],
        'content_hash': result['content_hash'],
        'processed_at': current_time,
        'markitdown_version': 'python-markitdown'
    }
    
    if result['success'] and result['structure']:
        frontmatter['structure_analysis'] = result['structure']
    
    if result['error']:
        frontmatter['conversion_error'] = result['error']
    
    # Create content_fm_body_attrs (file metadata)
    content_attrs = {
        'file_size_bytes': file_size,
        'last_modified_at': modified_time,
        'mime_type': mime_type,
        'conversion_method': 'python_markitdown_batch',
        'file_hash': calculate_hash(result['content']) if result['content'] else '',
        'processing_timestamp': current_time
    }
    
    # Generate the SQL INSERT statement
    sql = f"""-- Batch markitdown conversion for: {abs_path}
-- File size: {file_size} bytes ({file_size/1024/1024:.2f} MB)
-- Conversion success: {result['success']}
-- Conversion time: {result['conversion_time_ms']:.2f}ms

INSERT INTO uniform_resource (
    uniform_resource_id,
    device_id,
    ingest_session_id,
    uri,
    content_digest,
    content,
    frontmatter,
    size_bytes,
    last_modified_at,
    content_fm_body_attrs,
    nature,
    created_at
) VALUES (
    '{uniform_resource_id}',
    '{device_id}',
    '{ingest_session_id}',
    '{escape_sql(abs_path)}',
    '{result["content_hash"]}',
    '{escape_sql(result["content"])}',
    '{escape_sql(json.dumps(frontmatter))}',
    {file_size},
    datetime({modified_time}, 'unixepoch'),
    '{escape_sql(json.dumps(content_attrs))}',
    '{nature}',
    '{current_time}'
);

"""
    
    return sql

def main():
    parser = argparse.ArgumentParser(
        description='Batch process documents with markitdown and emit SQL',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  python3 all-in-current-dir.surveilr-SQL.py
  python3 all-in-current-dir.surveilr-SQL.py /path/to/documents
  python3 all-in-current-dir.surveilr-SQL.py . > batch-conversion.sql
        '''
    )
    parser.add_argument('directory', nargs='?', default='.', 
                       help='Directory to process (default: current directory)')
    parser.add_argument('--extensions', default='pdf,docx,doc,pptx,ppt,xlsx,xls',
                       help='Comma-separated file extensions to process')
    parser.add_argument('--timeout', type=int, default=120,
                       help='Timeout per file in seconds (default: 120)')
    
    args = parser.parse_args()
    
    # Parse extensions
    supported_extensions = {f'.{ext.strip().lower()}' for ext in args.extensions.split(',')}
    target_dir = os.path.abspath(args.directory)
    
    if not os.path.isdir(target_dir):
        print(f"Error: Directory not found: {target_dir}", file=sys.stderr)
        sys.exit(1)
    
    # Generate SQL header
    print(f"-- Python markitdown batch processing")
    print(f"-- Directory: {target_dir}")
    print(f"-- Extensions: {', '.join(sorted(supported_extensions))}")
    print(f"-- Generated at: {datetime.now().isoformat()}")
    print(f"-- Timeout per file: {args.timeout} seconds")
    print()
    
    print("-- Begin transaction")
    print("BEGIN TRANSACTION;")
    print()
    
    processed_count = 0
    success_count = 0
    error_count = 0
    
    # Process all matching files
    for file_path in Path(target_dir).rglob('*'):
        if file_path.is_file() and file_path.suffix.lower() in supported_extensions:
            print(f"-- Processing: {file_path.name} ({file_path.stat().st_size} bytes)")
            
            try:
                result = process_file_with_markitdown(str(file_path))
                sql = generate_sql_insert(str(file_path), result)
                
                print(sql)
                processed_count += 1
                
                if result['success']:
                    success_count += 1
                else:
                    error_count += 1
                    
            except Exception as e:
                print(f"-- ERROR processing {file_path}: {e}")
                error_count += 1
    
    # Generate SQL footer
    print("-- Commit transaction")
    print("COMMIT;")
    print()
    print(f"-- Batch processing completed")
    print(f"-- Files processed: {processed_count}")
    print(f"-- Successful conversions: {success_count}")
    print(f"-- Failed conversions: {error_count}")
    print(f"-- Success rate: {(success_count/max(processed_count,1)*100):.1f}%")
    
    if processed_count == 0:
        print(f"-- No files found with extensions: {', '.join(sorted(supported_extensions))}")
        print(f"-- In directory: {target_dir}")

if __name__ == "__main__":
    main()