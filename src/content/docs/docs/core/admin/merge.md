---
title: Merging `RSSD`s
description: Merging multiple RSSDs into one.
---

`surveilr` provides the ability to merge multiple RSSDs into one with or without SQLite.


## Without `sqlite3`
The `surveilr admin merge` prepares the SQL to merge multiple databases into one and executes it automatically creating
`resource-surveillance-aggregated.sqlite.db` (you can override the name using
`-d`).
```bash
$ surveilr admin merge --help                  # explain the `admin merge` subcommand
$ surveilr admin merge                         # execute merge SQL for all files in the current path
$ surveilr admin merge --candidates "**/*.db"  # execute merge SQL for specific globs in the current path
```

## With `sqlite3`
Generating SQL to merge multiple _Resource Surveillance State SQLite Databases_ into one, inspecting it, and then executing _using_ `sqlite3`:
```bash
$ surveilr admin merge --sql-only
$ surveilr admin merge --candidates "**/*.db" --sql-only
$ surveilr admin merge --candidates "**/*.db" -i "x*.db" --sql-only # -i ignores certain candidates
$ surveilr admin merge --sql-only > merge.sql
```

### `admin merge --sql-only`

Merging multiple database can sometimes fail due to unforseen data issues, you can use `sqlite3` to merge multiple databases using
`surveilr`-generated SQL after inspecting it. Here's how:

```bash
$ surveilr admin init -d target.sqlite.db -r \
  && surveilr admin merge -d target.sqlite.db --sql-only \
   | sqlite3 target.sqlite.db
```

The CLI multi-command pipe above does three things:

1. `surveilr admin init` initializes an empty `target.sqlite.db` (`-r` removes it if it exists)
2. `surveilr admin merge --sql-only` generates the merge SQL for all databases except `target.sqlite.db`; to inspect the SQL you can save it to a file `surveilr admin merge -d target.sqlite.db --sql-only > merge.sql`.
3. `sqlite3` pipe at the end just executes the generated SQL using SQLite 3 shell and produces merged `target.sqlite.db`

Once `target.sqlite.db` is created after step 3, none of the original device-specific `RSSD`s are required and `target.sqlite.db` is independent of `surveilr` as well.