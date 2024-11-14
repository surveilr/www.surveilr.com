## Overview
The `surveilr_udi_dal_fs` is a virtual table function that provides a structured interface to list and retrieve file system resources. It is implemented using the OpenDAL library to handle file operations and exposes a directory's metadata, including file paths, sizes, content, and timestamps, as tabular data.

---

## Purpose
- **Access Files and Directories**: Allows querying a directory's contents as rows in a virtual table.
- **File Metadata Retrieval**: Exposes file metadata such as size, last modified timestamp, content type, and content digest.
- **Recursive Listing**: Handles recursive traversal of directories to list all files and their details.

---

## Inputs
- **Path**: A single argument specifying the base directory or file path to query. This is a required argument.

---

## Outputs
The virtual table exposes the following columns:

| Column Name       | Data Type | Description                                         |
|--------------------|-----------|-----------------------------------------------------|
| `name`            | TEXT      | The name of the file or directory.                 |
| `path`            | TEXT      | The full path of the file or directory.            |
| `last_modified`   | TEXT      | The last modified timestamp of the file.           |
| `content`         | BLOB      | The binary content of the file (optional).         |
| `size`            | INTEGER   | The size of the file in bytes.                     |
| `content_type`    | TEXT      | The file extension (e.g., `txt`, `jpg`, `pdf`).    |
| `digest`          | TEXT      | The MD5 or SHA-256 hash of the file content.       |

---

## Usage

This virtual table function is typically queried like a regular table, allowing SQL operations such as `SELECT`, filtering, and joins.

Example query, see [here](https://github.com/surveilr/www.surveilr.com/blob/main/lib/assurance/opendal_integration_test.ts) for a realistic example:
```sql
SELECT name, path, size, last_modified, content_type, digest FROM surveilr_udi_dal_fs('/path/to/directory');
```