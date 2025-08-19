#!/usr/bin/env python3
"""
Structured Markdown Element Extraction Capturable Executable
Processes documents and extracts specific markdown elements as separate SQL records

This CapEx processes PDF, DOCX, XLSX, and PPTX files using Python markitdown,
then parses the markdown to extract specific elements (headings, links, blockquotes, 
bullet points) and generates separate SQL INSERT statements for each element type.

Instead of storing full markdown, it extracts and stores only structured elements
as individual records in uniform_resource_transform table.

Usage: python3 all-in-current-dir.surveilr-SQL.py [directory]
If no directory is provided, uses current directory.
Requires: pip install markitdown markdown beautifulsoup4 langextract
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
import markdown
from markdown.extensions import codehilite, toc
from bs4 import BeautifulSoup

try:
    from langextract import LangExtract
    LANGEXTRACT_AVAILABLE = True
except ImportError:
    LANGEXTRACT_AVAILABLE = False

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

def extract_markdown_elements(markdown_content):
    """Extract specific markdown elements using Python markdown parser"""
    
    # Parse markdown to HTML for structured extraction
    md = markdown.Markdown(extensions=['toc', 'tables', 'fenced_code'])
    html_content = md.convert(markdown_content)
    soup = BeautifulSoup(html_content, 'html.parser')
    
    elements = {
        'headings': [],
        'links': [],
        'blockquotes': [],
        'bullet_points': [],
        'tables': [],
        'paragraphs': []
    }
    
    # Extract headings (h1, h2, h3, h4, h5, h6)
    for heading in soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'h6']):
        elements['headings'].append({
            'level': int(heading.name[1]),
            'text': heading.get_text().strip(),
            'tag': heading.name
        })
    
    # Extract links
    for link in soup.find_all('a', href=True):
        elements['links'].append({
            'text': link.get_text().strip(),
            'url': link.get('href'),
            'title': link.get('title', '')
        })
    
    # Extract blockquotes
    for quote in soup.find_all('blockquote'):
        elements['blockquotes'].append({
            'text': quote.get_text().strip()
        })
    
    # Extract bullet points from lists
    for ul in soup.find_all('ul'):
        for li in ul.find_all('li'):
            elements['bullet_points'].append({
                'text': li.get_text().strip(),
                'type': 'unordered'
            })
    
    for ol in soup.find_all('ol'):
        for i, li in enumerate(ol.find_all('li'), 1):
            elements['bullet_points'].append({
                'text': li.get_text().strip(),
                'type': 'ordered',
                'number': i
            })
    
    # Extract tables
    for table in soup.find_all('table'):
        table_data = []
        for row in table.find_all('tr'):
            row_data = [cell.get_text().strip() for cell in row.find_all(['td', 'th'])]
            if row_data:
                table_data.append(row_data)
        if table_data:
            elements['tables'].append({
                'rows': table_data,
                'row_count': len(table_data),
                'col_count': len(table_data[0]) if table_data else 0
            })
    
    # Extract paragraphs
    for p in soup.find_all('p'):
        text = p.get_text().strip()
        if text:
            elements['paragraphs'].append({
                'text': text
            })
    
    return elements

def extract_with_langextract(file_path, content_text):
    """Use Google LangExtract for advanced structured data extraction from complex documents"""
    
    if not LANGEXTRACT_AVAILABLE:
        return None
        
    try:
        # Initialize LangExtract with document content
        extractor = LangExtract()
        
        # Define extraction schemas for different document structures
        schemas = {
            'executive_summary': {
                'description': 'Extract executive summary or key findings',
                'properties': {
                    'summary': {'type': 'string', 'description': 'Main summary or key points'},
                    'key_findings': {'type': 'array', 'items': {'type': 'string'}}
                }
            },
            'document_structure': {
                'description': 'Extract document structural information', 
                'properties': {
                    'document_type': {'type': 'string', 'description': 'Type of document (report, presentation, etc.)'},
                    'sections': {'type': 'array', 'items': {'type': 'string'}},
                    'main_topics': {'type': 'array', 'items': {'type': 'string'}}
                }
            },
            'key_entities': {
                'description': 'Extract key entities and relationships',
                'properties': {
                    'organizations': {'type': 'array', 'items': {'type': 'string'}},
                    'people': {'type': 'array', 'items': {'type': 'string'}},
                    'locations': {'type': 'array', 'items': {'type': 'string'}},
                    'dates': {'type': 'array', 'items': {'type': 'string'}},
                    'financial_figures': {'type': 'array', 'items': {'type': 'string'}}
                }
            },
            'action_items': {
                'description': 'Extract action items, recommendations, or next steps',
                'properties': {
                    'recommendations': {'type': 'array', 'items': {'type': 'string'}},
                    'action_items': {'type': 'array', 'items': {'type': 'string'}},
                    'deadlines': {'type': 'array', 'items': {'type': 'string'}}
                }
            },
            'data_insights': {
                'description': 'Extract data, statistics, and quantitative insights',
                'properties': {
                    'statistics': {'type': 'array', 'items': {'type': 'string'}},
                    'metrics': {'type': 'array', 'items': {'type': 'string'}},
                    'trends': {'type': 'array', 'items': {'type': 'string'}}
                }
            }
        }
        
        extracted_data = {}
        
        # Extract data for each schema
        for schema_name, schema_def in schemas.items():
            try:
                result = extractor.extract(
                    text=content_text[:8000],  # Limit text length for API efficiency
                    schema=schema_def
                )
                if result and any(result.get(key) for key in schema_def['properties'].keys()):
                    extracted_data[schema_name] = result
            except Exception as e:
                # Continue with other schemas if one fails
                extracted_data[schema_name] = {'error': str(e)}
        
        return extracted_data
        
    except Exception as e:
        return {'error': f'LangExtract failed: {str(e)}'}

def process_complex_document_with_langextract(file_path):
    """Process complex documents using both markitdown and LangExtract"""
    start_time = time.time()
    
    # First, try standard markitdown conversion
    markitdown_result = process_file_with_markitdown(file_path)
    
    if not markitdown_result['success'] or not LANGEXTRACT_AVAILABLE:
        return markitdown_result
    
    # For complex documents (especially PDFs), also use LangExtract
    file_extension = Path(file_path).suffix.lower()
    
    # Use LangExtract for PDFs and complex Office documents
    if file_extension in ['.pdf', '.docx', '.pptx']:
        try:
            # Get plain text content for LangExtract (first 8000 chars)
            markdown_content = markitdown_result.get('markdown_content', '')
            if len(markdown_content) > 100:  # Only if we have meaningful content
                
                langextract_data = extract_with_langextract(file_path, markdown_content)
                
                if langextract_data:
                    # Add LangExtract results to the existing result
                    markitdown_result['langextract_structured_data'] = langextract_data
                    markitdown_result['enhanced_extraction'] = True
                    
        except Exception as e:
            # Don't fail the entire process if LangExtract fails
            markitdown_result['langextract_error'] = str(e)
    
    return markitdown_result

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
        extracted_elements = extract_markdown_elements(markdown_content)
        content_hash = calculate_hash(markdown_content)
        
        return {
            'success': True,
            'markdown_content': markdown_content,  # Keep for reference but don't store in DB
            'elements': extracted_elements,
            'conversion_time_ms': conversion_time,
            'content_hash': content_hash,
            'error': None
        }
        
    except subprocess.CalledProcessError as e:
        return {
            'success': False,
            'elements': {},
            'conversion_time_ms': (time.time() - start_time) * 1000,
            'content_hash': '',
            'error': f"markitdown failed: {e.stderr}"
        }
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'elements': {},
            'conversion_time_ms': (time.time() - start_time) * 1000,
            'content_hash': '',
            'error': "Conversion timed out after 2 minutes"
        }
    except FileNotFoundError:
        return {
            'success': False,
            'elements': {},
            'conversion_time_ms': 0,
            'content_hash': '',
            'error': "markitdown not found - install with: pip install markitdown"
        }

def escape_sql(s):
    """Escape SQL strings safely"""
    if s is None:
        return ''
    return s.replace("'", "''")

def generate_element_sql_inserts(file_path, result):
    """Generate SQL INSERT statements for each extracted markdown element"""
    
    if not result['success'] or not result['elements']:
        return ""
    
    # Get file metadata
    abs_path = os.path.abspath(file_path)
    file_stat = os.stat(abs_path)
    file_size = file_stat.st_size
    current_time = datetime.now().isoformat()
    
    # Generate base uniform_resource record first
    base_resource_id = generate_ulid()
    device_id = generate_ulid()
    ingest_session_id = generate_ulid()
    
    file_extension = Path(file_path).suffix.lower()
    nature = 'md'  # Processed as markdown
    
    sql_statements = []
    
    # Header with file info
    sql_statements.append(f"""-- Structured element extraction for: {abs_path}
-- File size: {file_size} bytes ({file_size/1024/1024:.2f} MB)
-- Conversion success: {result['success']}
-- Conversion time: {result['conversion_time_ms']:.2f}ms
-- Extracted elements: {sum(len(elements) for elements in result['elements'].values())}

-- Base resource record (markdown nature)
INSERT INTO uniform_resource (
    uniform_resource_id,
    device_id, 
    ingest_session_id,
    uri,
    content_digest,
    nature,
    size_bytes,
    frontmatter,
    created_at
) VALUES (
    '{base_resource_id}',
    '{device_id}',
    '{ingest_session_id}',
    '{escape_sql(abs_path)}',
    '{result["content_hash"]}',
    '{nature}',
    {file_size},
    '{escape_sql(json.dumps({"extracted_by": "python_markitdown_element_extractor", "processed_at": current_time, "elements_extracted": True}))}',
    '{current_time}'
);
""")
    
    # Generate separate INSERT statements for each element type
    elements = result['elements']
    
    # Headings
    if elements['headings']:
        transform_id = generate_ulid()
        headings_json = json.dumps(elements['headings'])
        sql_statements.append(f"""
-- Extracted headings (md-select:all_headers equivalent)
INSERT INTO uniform_resource_transform (
    uniform_resource_transform_id,
    uniform_resource_id,
    uri,
    content,
    created_at
) VALUES (
    '{transform_id}',
    '{base_resource_id}',
    '{escape_sql(abs_path)}/md-select:all_headers',
    '{escape_sql(headings_json)}',
    '{current_time}'
);""")
    
    # Links
    if elements['links']:
        transform_id = generate_ulid()
        links_json = json.dumps(elements['links'])
        sql_statements.append(f"""
-- Extracted links (md-select:all_links equivalent)
INSERT INTO uniform_resource_transform (
    uniform_resource_transform_id,
    uniform_resource_id,
    uri,
    content,
    created_at
) VALUES (
    '{transform_id}',
    '{base_resource_id}',
    '{escape_sql(abs_path)}/md-select:all_links',
    '{escape_sql(links_json)}',
    '{current_time}'
);""")
    
    # Blockquotes
    if elements['blockquotes']:
        transform_id = generate_ulid()
        quotes_json = json.dumps(elements['blockquotes'])
        sql_statements.append(f"""
-- Extracted blockquotes
INSERT INTO uniform_resource_transform (
    uniform_resource_transform_id,
    uniform_resource_id,
    uri,
    content,
    created_at
) VALUES (
    '{transform_id}',
    '{base_resource_id}',
    '{escape_sql(abs_path)}/md-select:blockquotes',
    '{escape_sql(quotes_json)}',
    '{current_time}'
);""")
    
    # Bullet points  
    if elements['bullet_points']:
        transform_id = generate_ulid()
        bullets_json = json.dumps(elements['bullet_points'])
        sql_statements.append(f"""
-- Extracted bullet points/lists
INSERT INTO uniform_resource_transform (
    uniform_resource_transform_id,
    uniform_resource_id,
    uri,
    content,
    created_at
) VALUES (
    '{transform_id}',
    '{base_resource_id}',
    '{escape_sql(abs_path)}/md-select:bullet_points',
    '{escape_sql(bullets_json)}',
    '{current_time}'
);""")
    
    # Tables
    if elements['tables']:
        transform_id = generate_ulid()
        tables_json = json.dumps(elements['tables'])
        sql_statements.append(f"""
-- Extracted tables (md-select:all_tables equivalent)
INSERT INTO uniform_resource_transform (
    uniform_resource_transform_id,
    uniform_resource_id,
    uri,
    content,
    created_at
) VALUES (
    '{transform_id}',
    '{base_resource_id}',
    '{escape_sql(abs_path)}/md-select:all_tables',
    '{escape_sql(tables_json)}',
    '{current_time}'
);""")
    
    # Paragraphs
    if elements['paragraphs']:
        transform_id = generate_ulid()
        paragraphs_json = json.dumps(elements['paragraphs'])
        sql_statements.append(f"""
-- Extracted paragraphs (md-select:all_paragraphs equivalent)
INSERT INTO uniform_resource_transform (
    uniform_resource_transform_id,
    uniform_resource_id,
    uri,
    content,
    created_at
) VALUES (
    '{transform_id}',
    '{base_resource_id}',
    '{escape_sql(abs_path)}/md-select:all_paragraphs',
    '{escape_sql(paragraphs_json)}',
    '{current_time}'
);""")
    
    # Add LangExtract structured data if available
    if result.get('langextract_structured_data'):
        langextract_data = result['langextract_structured_data']
        
        for schema_name, schema_data in langextract_data.items():
            if schema_data and not schema_data.get('error'):
                transform_id = generate_ulid()
                schema_json = json.dumps(schema_data)
                sql_statements.append(f"""
-- LangExtract structured data: {schema_name}
INSERT INTO uniform_resource_transform (
    uniform_resource_transform_id,
    uniform_resource_id,
    uri,
    content,
    created_at
) VALUES (
    '{transform_id}',
    '{base_resource_id}',
    '{escape_sql(abs_path)}/langextract:{schema_name}',
    '{escape_sql(schema_json)}',
    '{current_time}'
);""")
    
    return "\n".join(sql_statements) + "\n"

def main():
    parser = argparse.ArgumentParser(
        description='Extract structured markdown elements and emit SQL',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  python3 all-in-current-dir.surveilr-SQL.py
  python3 all-in-current-dir.surveilr-SQL.py /path/to/documents
  python3 all-in-current-dir.surveilr-SQL.py . > element-extraction.sql
  
This script extracts specific markdown elements (headings, links, blockquotes, 
bullet points, tables, paragraphs) and generates separate SQL INSERT statements
for each element type in the uniform_resource_transform table.
        '''
    )
    parser.add_argument('directory', nargs='?', default='.', 
                       help='Directory to process (default: current directory)')
    parser.add_argument('--extensions', default='pdf,docx,doc,pptx,ppt,xlsx,xls',
                       help='Comma-separated file extensions to process')
    parser.add_argument('--timeout', type=int, default=120,
                       help='Timeout per file in seconds (default: 120)')
    parser.add_argument('--use-langextract', action='store_true',
                       help='Use Google LangExtract for enhanced structured data extraction from complex documents')
    
    args = parser.parse_args()
    
    # Parse extensions
    supported_extensions = {f'.{ext.strip().lower()}' for ext in args.extensions.split(',')}
    target_dir = os.path.abspath(args.directory)
    
    if not os.path.isdir(target_dir):
        print(f"Error: Directory not found: {target_dir}", file=sys.stderr)
        sys.exit(1)
    
    # Generate SQL header
    print(f"-- Python markitdown structured element extraction")
    print(f"-- Directory: {target_dir}")
    print(f"-- Extensions: {', '.join(sorted(supported_extensions))}")
    print(f"-- Generated at: {datetime.now().isoformat()}")
    print(f"-- Timeout per file: {args.timeout} seconds")
    print(f"-- Required packages: markitdown, markdown, beautifulsoup4")
    if args.use_langextract:
        if LANGEXTRACT_AVAILABLE:
            print(f"-- LangExtract: ENABLED for enhanced extraction")
        else:
            print(f"-- LangExtract: NOT AVAILABLE - install with: pip install langextract")
    print(f"--")
    print(f"-- This script extracts specific markdown elements and creates")
    print(f"-- separate records in uniform_resource_transform table for:")
    print(f"--   - Headings (all_headers)")
    print(f"--   - Links (all_links)")  
    print(f"--   - Blockquotes (blockquotes)")
    print(f"--   - Bullet points (bullet_points)")
    print(f"--   - Tables (all_tables)")
    print(f"--   - Paragraphs (all_paragraphs)")
    if args.use_langextract and LANGEXTRACT_AVAILABLE:
        print(f"--   + LangExtract structured data:")
        print(f"--     - Executive summaries")
        print(f"--     - Document structure analysis")
        print(f"--     - Key entities (people, orgs, locations)")
        print(f"--     - Action items & recommendations") 
        print(f"--     - Data insights & statistics")
    print()
    
    print("-- Begin transaction")
    print("BEGIN TRANSACTION;")
    print()
    
    processed_count = 0
    success_count = 0
    error_count = 0
    total_elements_extracted = 0
    
    # Process all matching files
    for file_path in Path(target_dir).rglob('*'):
        if file_path.is_file() and file_path.suffix.lower() in supported_extensions:
            print(f"-- Processing: {file_path.name} ({file_path.stat().st_size} bytes)")
            
            try:
                # Choose processing method based on options
                if args.use_langextract:
                    result = process_complex_document_with_langextract(str(file_path))
                else:
                    result = process_file_with_markitdown(str(file_path))
                
                if result['success']:
                    sql = generate_element_sql_inserts(str(file_path), result)
                    if sql:
                        print(sql)
                        elements_count = sum(len(elements) for elements in result['elements'].values())
                        langextract_count = 0
                        if result.get('langextract_structured_data'):
                            langextract_count = len([s for s in result['langextract_structured_data'].values() if not s.get('error')])
                        
                        total_elements_extracted += elements_count
                        
                        if langextract_count > 0:
                            print(f"-- Extracted {elements_count} markdown elements + {langextract_count} LangExtract schemas from {file_path.name}")
                        else:
                            print(f"-- Extracted {elements_count} elements from {file_path.name}")
                        success_count += 1
                    else:
                        print(f"-- No elements extracted from {file_path.name}")
                else:
                    print(f"-- ERROR: {result['error']}")
                    error_count += 1
                
                processed_count += 1
                    
            except Exception as e:
                print(f"-- ERROR processing {file_path}: {e}")
                error_count += 1
    
    # Generate SQL footer
    print("-- Commit transaction")
    print("COMMIT;")
    print()
    print(f"-- Structured element extraction completed")
    print(f"-- Files processed: {processed_count}")
    print(f"-- Successful conversions: {success_count}")
    print(f"-- Failed conversions: {error_count}")
    print(f"-- Total elements extracted: {total_elements_extracted}")
    print(f"-- Success rate: {(success_count/max(processed_count,1)*100):.1f}%")
    
    if processed_count == 0:
        print(f"-- No files found with extensions: {', '.join(sorted(supported_extensions))}")
        print(f"-- In directory: {target_dir}")
        if args.use_langextract:
            print(f"-- Install required packages: pip install markitdown markdown beautifulsoup4 langextract")
        else:
            print(f"-- Install required packages: pip install markitdown markdown beautifulsoup4")
        print(f"-- For enhanced extraction, use: --use-langextract flag")

if __name__ == "__main__":
    main()