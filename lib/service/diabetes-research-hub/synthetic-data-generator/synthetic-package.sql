Error executing service/diabetes-research-hub/synthetic-data-generator/synthetic-package.sql: Command failed: lib/service/diabetes-research-hub/synthetic-data-generator/synthetic-package.sql.ts
The required table "uniform_resource_cgm_file_metadata" does not exist. 
[0m[1m[31merror[0m: Uncaught (in promise) Error: no such table: file_meta_ingest_data
    throw new Error(Deno.UnsafePointerView.getCString(errmsg));
[0m[31m          ^[0m
    at [0m[1m[3munwrap[0m ([0m[36mhttps://deno.land/x/sqlite3@0.12.0/src/util.ts[0m:[0m[33m37[0m:[0m[33m11[0m)
    at new [0m[1m[3mStatement[0m ([0m[36mhttps://deno.land/x/sqlite3@0.12.0/src/statement.ts[0m:[0m[33m206[0m:[0m[33m5[0m)
    at [0m[1m[3mDatabase.prepare[0m ([0m[36mhttps://deno.land/x/sqlite3@0.12.0/src/database.ts[0m:[0m[33m280[0m:[0m[33m12[0m)
    at [0m[1m[3mgenerateMealFitnessJson[0m ([0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/service/diabetes-research-hub/study-specific-stateless/generate-cgm-combined-sql.ts[0m:[0m[33m902[0m:[0m[33m99[0m)
    at [0m[1m[3msyntheticSqlPages.savemealDDL[0m ([0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/service/diabetes-research-hub/synthetic-data-generator/synthetic-package.sql.ts[0m:[0m[33m17[0m:[0m[33m27[0m)
    at [0m[1m[3mObject.call[0m ([0m[36mhttps://raw.githubusercontent.com/netspective-labs/sql-aide/v0.14.8/lib/reflect/callable.ts[0m:[0m[33m163[0m:[0m[33m31[0m)
    at [0m[1m[3msyntheticSqlPages.methodText[0m ([0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/rssd.ts[0m:[0m[33m491[0m:[0m[33m15[0m)
    at [0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts[0m:[0m[33m646[0m:[0m[33m36[0m
    at [0m[1m[3mArray.map[0m ([0m[36m<anonymous>[0m)
    at [0m[1m[3mFunction.SQL[0m ([0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts[0m:[0m[33m645[0m:[0m[33m10[0m)
