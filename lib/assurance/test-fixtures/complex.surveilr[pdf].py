#!/usr/bin/env python3
"""
Complex PDF Capturable Executable using Python markitdown
Processes PDF files and outputs structured markdown with metadata

This CapEx uses Python markitdown directly to convert PDF files to markdown,
providing performance metrics and content analysis.

Usage: python3 complex.surveilr[pdf].py <pdf_file>
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

def calculate_hash(content):
    """Calculate SHA1 hash of content"""
    return hashlib.sha1(content.encode()).hexdigest()

def analyze_markdown_structure(markdown_content):
    """Analyze markdown content for structural elements"""
    lines = markdown_content.split('\n')
    
    # Count different markdown elements
    heading_count = len([line for line in lines if line.startswith('#')])
    list_count = len([line for line in lines if line.strip().startswith(('-', '*', '+')) or re.match(r'^\d+\.', line.strip())])
    table_count = len([line for line in lines if '|' in line and line.count('|') >= 2])
    code_block_count = len([line for line in lines if line.strip().startswith('```')])
    link_count = len([line for line in lines if '[' in line and '](' in line])
    
    # Analyze heading structure
    h1_count = len([line for line in lines if line.startswith('# ')])
    h2_count = len([line for line in lines if line.startswith('## ')])
    h3_count = len([line for line in lines if line.startswith('### ')])
    
    return {
        'heading_count': heading_count,
        'h1_count': h1_count,
        'h2_count': h2_count,
        'h3_count': h3_count,
        'list_count': list_count,
        'table_count': table_count,
        'code_block_count': code_block_count,
        'link_count': link_count,
        'line_count': len(lines),
        'paragraph_count': len([line for line in lines if line.strip() and not line.startswith(('#', '-', '*', '+', '|', '```'))])
    }

def process_pdf_with_markitdown(file_path):
    """Process PDF using Python markitdown and return results with timing"""
    start_time = time.time()
    
    try:
        # Run markitdown command
        result = subprocess.run(
            ['markitdown', file_path],
            capture_output=True,
            text=True,
            check=True,
            timeout=60  # 60 second timeout
        )
        
        end_time = time.time()
        conversion_time = (end_time - start_time) * 1000  # Convert to milliseconds
        
        markdown_content = result.stdout
        
        # Analyze the markdown structure
        structure_analysis = analyze_markdown_structure(markdown_content)
        
        # Calculate content hash
        content_hash = calculate_hash(markdown_content)
        
        return {
            'success': True,
            'content': markdown_content,
            'conversion_time_ms': conversion_time,
            'content_length': len(markdown_content),
            'content_hash': content_hash,
            'structure': structure_analysis,
            'error': None,
            'markitdown_version': 'python-markitdown',
            'processed_at': datetime.now().isoformat()
        }
        
    except subprocess.CalledProcessError as e:
        end_time = time.time()
        return {
            'success': False,
            'content': f'<!-- Conversion failed: {e.stderr} -->',
            'conversion_time_ms': (end_time - start_time) * 1000,
            'content_length': 0,
            'content_hash': '',
            'structure': {},
            'error': f'markitdown failed: {e.stderr}',
            'markitdown_version': 'python-markitdown',
            'processed_at': datetime.now().isoformat()
        }
    except subprocess.TimeoutExpired:
        end_time = time.time()
        return {
            'success': False,
            'content': '<!-- Conversion timed out after 60 seconds -->',
            'conversion_time_ms': (end_time - start_time) * 1000,
            'content_length': 0,
            'content_hash': '',
            'structure': {},
            'error': 'Conversion timed out after 60 seconds',
            'markitdown_version': 'python-markitdown',
            'processed_at': datetime.now().isoformat()
        }
    except FileNotFoundError:
        return {
            'success': False,
            'content': '<!-- markitdown not found. Install: pip install markitdown -->',
            'conversion_time_ms': 0,
            'content_length': 0,
            'content_hash': '',
            'structure': {},
            'error': 'markitdown not installed - run: pip install markitdown',
            'markitdown_version': 'python-markitdown',
            'processed_at': datetime.now().isoformat()
        }

def main():
    if len(sys.argv) < 2:
        print("Usage: complex.surveilr[pdf].py <pdf_file>", file=sys.stderr)
        print("", file=sys.stderr)
        print("This Capturable Executable converts PDF files to markdown using Python markitdown", file=sys.stderr)
        print("Requires: pip install markitdown", file=sys.stderr)
        sys.exit(1)
    
    pdf_path = sys.argv[1]
    
    if not os.path.exists(pdf_path):
        print(f"File not found: {pdf_path}", file=sys.stderr)
        sys.exit(1)
    
    if not pdf_path.lower().endswith('.pdf'):
        print(f"Warning: File {pdf_path} does not have .pdf extension", file=sys.stderr)
    
    # Get file metadata
    file_stat = os.stat(pdf_path)
    file_size = file_stat.st_size
    
    result = process_pdf_with_markitdown(pdf_path)
    
    # Output comprehensive metadata as comments
    print(f"<!-- PDF Markitdown Conversion Report -->")
    print(f"<!-- File: {pdf_path} -->")
    print(f"<!-- File Size: {file_size} bytes ({file_size/1024/1024:.2f} MB) -->")
    print(f"<!-- Success: {result['success']} -->")
    print(f"<!-- Conversion Time: {result['conversion_time_ms']:.2f}ms -->")
    print(f"<!-- Content Length: {result['content_length']} chars -->")
    print(f"<!-- Content Hash: {result['content_hash']} -->")
    print(f"<!-- Markitdown Version: {result['markitdown_version']} -->")
    print(f"<!-- Processed At: {result['processed_at']} -->")
    
    if result['success'] and result['structure']:
        structure = result['structure']
        print(f"<!-- Structure Analysis: -->")
        print(f"<!--   Headings: {structure['heading_count']} (H1:{structure['h1_count']}, H2:{structure['h2_count']}, H3:{structure['h3_count']}) -->")
        print(f"<!--   Lists: {structure['list_count']} -->")
        print(f"<!--   Tables: {structure['table_count']} -->")
        print(f"<!--   Code Blocks: {structure['code_block_count']} -->")
        print(f"<!--   Links: {structure['link_count']} -->")
        print(f"<!--   Paragraphs: {structure['paragraph_count']} -->")
        print(f"<!--   Total Lines: {structure['line_count']} -->")
    
    if result['error']:
        print(f"<!-- Error: {result['error']} -->")
    
    print()
    print("---")
    print("# PDF to Markdown Conversion")
    print(f"**Source:** `{os.path.basename(pdf_path)}`")
    print(f"**Converted by:** Python markitdown")
    print(f"**Conversion time:** {result['conversion_time_ms']:.2f}ms")
    print("---")
    print()
    
    # Output the markdown content
    print(result['content'])

if __name__ == "__main__":
    main()