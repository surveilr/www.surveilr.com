# surveilr_udi_dal_dropbox
## Description
Registers a virtual table module `surveilr_udi_dal_dropbox` that interacts with files from Dropbox.
This virtual table allows structured querying of file metadata, such as name, path, size, content, and other details,for files within a specified directory.

## Arguments
- `access_token`: The Dropbox access token
- `path_filter`: The path to filter results

The virtual table exposes the following columns:
- `name`: `TEXT` - The name of the file.
- `path`: `TEXT` - The full path of the file.
- `last_modified`: `TEXT` - The last modified timestamp of the file in ISO 8601 format.
- `content`: `BLOB` - The binary content of the file (optional).
- `size`: `INTEGER` - The size of the file in bytes.
- `content_type`: `TEXT` - The file extension.
- `digest`: `TEXT` - The MD5 hash of the file content (optional).
  
## Returns
`A table`

## Example
```bash
export DROPBOX_ACCESS_TOKEN="<token>"
```

```
surveilr shell --cmd "select * from surveilr_udi_dal_dropbox();"
```