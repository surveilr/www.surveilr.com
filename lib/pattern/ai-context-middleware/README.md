# `surveilr` AI Context Middleware Pattern

* `package.sql.ts` script is the entry point used to generate SQL DDL and DML
  for typical database objects and Web UI content:

## Try it out on any device with this repo

```bash
$ git clone https://github.com/opsfolio/www.opsfolio.com.git
$ cd www.opsfolio.com/src/ai-context-engineering
$ surveilr ingest files
```

The **uniform_resource** and **uniform_resource_transform** tables will contain the ingested prompts along with markdown frontmatter.

### To run the SQLPage Web-UI with the resource-surveillance DB.

Copy the generated resource-surveillance DB in the above step in the directory **www.surveilr.com/lib/pattern/ai-context-middleware** for use with the ai-context-middleware pattern.

```bash
$ git clone https://github.com/surveilr/www.surveilr.com.git
# use SQLPage to preview content (be sure `deno` v1.40 or above is installed)
$ cd surveilr.com/pattern/ai-context-middleware/
$ surveilr shell ./package.sql.ts
$ SQLPAGE_SITE_PREFIX="" ../../std/surveilrctl.ts dev
# launch a browser and go to http://localhost:9000/fhir/index.sql
```
