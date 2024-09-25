INSERT INTO code_notebook_cell (
    code_notebook_cell_id, 
    notebook_kernel_id, 
    notebook_name, 
    cell_name, 
    interpretable_code, 
    interpretable_code_hash
) VALUES (
    ulid(),
    'DenoTaskShell',
    'IngestAutoNotebook',
    'all device users (osquery)', 
    'osqueryi "SELECT * from users" --json',
    'HASH:osqueryi "SELECT * from users" --json' -- TODO
) ON CONFLICT(notebook_name, cell_name, interpretable_code_hash) DO NOTHING;
