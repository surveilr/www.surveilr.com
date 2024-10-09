---
title: Ingest Files
description: Documentation for the resource surveillance CLI tool.
---

File ingestion in `surveilr` imports and processes files from a file system into
a structured database for monitoring and analysis. This process is called
walking the filesystem. In essence, it involves scanning directories and files,
then transferring their metadata and content into an RSSD.

## Preparing for Ingestion

Before initiating the ingestion process, it's crucial to understand what files
and directories will be processed. `surveilr` provides a powerful feature called
`--dry-run` to simulate this process without making any changes. This step is
essential for ensuring that only the desired files and directories are ingested
into the target RSSD as shown below:

**Example**

1. Preview files in the current working directory (CWD)

   ```bash
   $ surveilr ingest files --dry-run
   ```

2. Preview files in specific directories

   ```bash
   $ surveilr ingest files --dry-run -r <PATHNAME> -r <PATHNAME>
   ```

:::tip[Did you know?] 
You can [configure unique identifiers](/docs/core/concepts/resource-surveillance#configuring-unique-identifiers-for-rssd-databases)
for `RSSD`s 
:::

## Performing File Ingestions

With `surveilr`, you can easily ingest files from the current working directory
or any specified directories. This section covers the commands to perform these
ingestions, including how to display statistics about the ingested data.

For a file tree represented below:

```txt
/my-files
├── project-a
│   ├── data.csv
│   └── config.yml
|   └── schema.json
├── project-b
│   ├── draft.docx
│   └── references.puml
```

**Examples**

```bash
# Ingest files from the CWD
$ cd my-files
$ surveilr ingest files

# Ingest files from specific directories by specifying a regex combination
$ surveilr ingest files -r my-files/project*

# Ingest files from the CWD and display statistics
$ surveilr ingest files --stats
```
