---
title: Capturable Executables
description: Creating `RSSD`s by executing shell tasks without persisting.
---

When `ingest` command runs, its main job is to find files and store them in
`uniform_resource` table as records. If the content of a file is already stored
in the file system this works well. However sometimes we need to generate the
content of a file (or group of files) and store the output of the generated
files. That's where the idea of _Capturable Executables_ (`CEs`) comes in.

CEs allow you to pass in arguments or behaviors to the `ingest` command that
allows certain patterns of files to be executed in a safe shell, and their
STDOUT and STDERR captured and stored in `uniform_resource`. These scripts are
referred to as _capturable executables_ or `CE`s and are influenced through
_Processing Instructions_ (`PI`s) in file names.

For example, if we want an ingestion as it encounters a `abc.surveilr.sh` file
to be executed, we can pass in `surveilr capturable-exec "surverilr[json]"` and
it will execute the script, treat the output as JSON, and store it in
`uniform_resource`. `surverilr[json]` becomes what is known as a `CE` Resource
Surveillance _Processing Instruction_ (`PI`) and the pattern is arbitrary so
long as the _nature_ is a named Rust reg ex capture group liked
`surveilr\[(?P<nature>[^]]*)\]` (focus on `nature`, you can test this regular
expressions at https://regex101.com/r/sVroiN/1).

This _Capturable Executables_ functionality is available:

- Calls an executable without any parameters and assumes the output is whatever
  is in `[xyz]` PI as the `uniform_resource` _nature_.
- If the filename is something like `myfile.surveilr-SQL.sh` it means that the
  output of the command will be treated as batch SQL and executed on the target
  SQLite database in the same transaction as the primary database. If we pass in
  everything through STDIN (see below), `INSERT INTO` should be easy.
- Need to capture status code from the executable and STDERR from subprocess and
  pass it back so it can be stored in
  `walk_session_path_fs_entry`.`captured_executable` JSON column along with
  `args` and `stdin`.
- Pass in the device, behavior, and other context information through CLI
  parameters or STDIN to the shell script. The input (STDIN) should look like
  this and contain a reasonably complete context so that executables know how to
  generate their output:

  ```json
  {
    "surveilr-ingest": {
      "args": {
        "state_db_fs_path": "./e2e-test-state.sqlite.db"
      },
      "behavior": {
        "capturable_executables": [
          "surveilr\\[(?P<nature>[^\\]]*)\\]"
        ],
        "compute_digests": [".*"],
        "ignore_regexs": [
          "/(\\.git|node_modules)/"
        ],
        "ingest_content": [
          "\\.(md|mdx|html|json|jsonc|toml|yaml)$",
          "surveilr\\[(?P<nature>[^\\]]*)\\]"
        ],
        "root_paths": ["./support/test-fixtures"]
      },
      "device": { "device_id": "01HFHZGEZC763PWRBV2WKXBJH0" },
      "env": {
        "current_dir": "/home/snshah/workspaces/github.com/opsfolio/resource-surveillance"
      },
      "session": {
        "entry": {
          "path": "/home/snshah/workspaces/github.com/opsfolio/resource-surveillance/support/test-fixtures/echo-stdin.surveilr[json].sh"
        },
        "walk-path-id": "01HFHZGEZEDTW29BWWSEDE46WH",
        "walk-session-id": "01HFHZGEZD31S0V1EYBW4TT530"
      }
    }
  }
  ```

### Testing Capturable Executables

It is advised to try to keep CEs individually testable as independent scripts.
You can validate capturable executables by using `surveilr capturable-exec`
subcommands.

```bash
$ surveilr capturable-exec ls --help                    # see all the options (arguments are same as `ingest`)
$ surveilr capturable-exec ls                           # scan for CEs and show a table of what's found
$ surveilr capturable-exec ls --markdown > capturable-exec.md  # find CEs, try to execute them, store their output in a Markdown
```

Running `surveilr capturable-exec ls` on the
[test-fixtures](https://github.com/opsfolio/docs.opsfolio.com/tree/main/public/test-fixtures)
should show something similar to this:

```bash
| Executable                                               | Nature                        | Issue             |
| -------------------------------------------------------- | ----------------------------- | ----------------- |
| ./xml-to-json.surveilr[json].ts                          | json                          |                   |
| ./capturable-executable.surveilr[json].ts                | json                          |                   |
| ./capturable-executable-no-permissions.surveilr[json].sh | Executable Permission Not Set | chmod +x required |
| ./capturable-executable.surveilr[json].sh                | json                          |                   |
| ./echo-stdin.surveilr[json].sh                           | json                          |                   |
| ./idempotent.surveilr-SQL.sh                             | batched SQL                   |                   |
| ./capturable-executable-bad-exit-status.surveilr[txt].sh | txt                           |                   |
```

Running `surveilr capturable-exec ls --markdown` generates a Markdown document
that you can use to learn more about what `STDIN`, `STDOUT`, and `STDERR`
streams will be created during `ingest`.

### Capturable Executables Examples

See these examples in
[`test-fixtures`](https://github.com/opsfolio/resource-surveillance-commons/tree/main/assurance/test-fixtures):

- `capturable-executable.surveilr[json].ts` shows how to use simple JSON output
  from a Deno script and store it in `uniform_resource`
- `capturable-executable.surveilr[json].sh` shows how to use simple JSON output
  from a Bash script and store it in `uniform_resource`
- `echo-stdin.surveilr[json].sh` shows how to accept STDIN and emit JSON as
  STDOUT -- this allows more complex processing by getting additional context
  from surveilr and doing something special in a script.
- `idempotent.surveilr-SQL.sh` shows how a script can generate SQL and
  `surveilr` will execute the SQL as a batch in the same transaction (WARNING:
  SQL is unsanitized and this might be a security hole so be careful turning it
  on).

How to control the behavior of _Capturable Executables_ filenames:

- `surveilr ingest --captured-fs-exec-sql` Regexp(s) control which files are
  considered capturable executables whose output will be captured and executed
  as "SQL batch"
- `surveilr ingest --capture-fs-exec` Regexp(s) control which files are
  considered capturable executables

Full diagnostics of STDIN, STDOUT, STDERR, etc. are present in the
`ur_session_path_fs_entry` row for all scripts as they're encountered. If you
need more features, submit tickets.

## Testing Shell Tasks

### Simple Commands

```bash
$ surveilr capturable-exec test task --help
$ surveilr capturable-exec test task -t 'osqueryi "select * from users" --json'
$ surveilr capturable-exec test task -t 'osqueryi "select * from users"'
$ surveilr capturable-exec test task -t '{ "osquery result as plain text": "osqueryi \"SELECT * from users\" --json" }'
$ surveilr capturable-exec test task -t '{ "osquery result as plain text": "osqueryi \"SELECT * from users\"", "nature": "text/plain" }'
```

### Piping Tasks

```bash
$ echo 'osqueryi "select * from users" --json' | surveilr capturable-exec test task --stdin
$ echo '{ "query result as plain text": "osqueryi \"SELECT * from users\"", "nature": "text/plain" }' | surveilr capturable-exec test task --stdin
```

### Multiple Commands

Multiple commands can be passed as a capturable executable, just as is being
passed to `ingest tasks`. For example, a file named `synthetic-tasks-via-stdin`
which contains the below:

```txt
# [TEXT] run osquery and store results in `uniform_resource` as JSON;
# the `--json` is the instruction for osquery, `surveilr` assumes JSON.
osqueryi "SELECT * from users" --json

# [JSONL] the following is the same as above except it has a name
{ "custom name for task output in uniform_resource": "osqueryi \"SELECT * from users\" --json", "nature": "json" }

# [JSONL] the following is the same as above except we store the result as plain text
{ "osquery result as plain text": "osqueryi \"SELECT * from users\"", "nature": "text/plain" }

# [TEXT] this command should run the same as the first but should not be stored more than once
osqueryi "SELECT * from users" --json
```

To execute this file as a capturable executable:

```bash
$ cat synthetic-tasks-via-stdin | surveilr capturable-exec test task --stdin
```
