# Resource Surveillance (`surveilr`) Standard Library

This module houses reusable
[Resource Surveillance](https://www.opsfolio.com/surveilr) (`surveilr`)
_Standard Library_ (`std`) components "such as "Console", general navigation,
and other "universal helpers" (content and pages that work across
`surveilr`-based applications)

You can load these into any `surveilr` RSSD:

```bash
$ surveilr shell https://surveilr.com/lib/std/package.sql
$ surveilr web-ui --port 9000
# open the page at http://localhost:9000/
```

Ease development using `watch` mode:

```bash
$ ./surveilrctl.ts dev
```

The above would start a `surveilr` web server instance and automatically reload
all `*.sql*` files so you can just save from your IDE and refresh the web page
to see changes.
