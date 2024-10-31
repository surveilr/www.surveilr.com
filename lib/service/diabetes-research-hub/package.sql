Error executing service/diabetes-research-hub/package.sql: Command failed: lib/service/diabetes-research-hub/package.sql.ts
[0m[1m[31merror[0m: Uncaught (in promise) NotFound: No such file or directory (os error 2): readfile './d3-aide-component.js'
    return Deno.readTextFileSync("./d3-aide-component.js");
[0m[31m                ^[0m
    at [0m[1m[3mObject.readTextFileSync[0m ([0m[36mext:deno_fs/30_fs.js[0m:[0m[33m864[0m:[0m[33m10[0m)
    at [0m[1m[3mDRHSqlPages.js/chart-component.js[0m ([0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/service/diabetes-research-hub/package.sql.ts[0m:[0m[33m1032[0m:[0m[33m17[0m)
    at [0m[1m[3mObject.call[0m ([0m[36mhttps://raw.githubusercontent.com/netspective-labs/sql-aide/v0.14.8/lib/reflect/callable.ts[0m:[0m[33m163[0m:[0m[33m31[0m)
    at [0m[1m[3mDRHSqlPages.methodText[0m ([0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/rssd.ts[0m:[0m[33m491[0m:[0m[33m15[0m)
    at [0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts[0m:[0m[33m642[0m:[0m[33m39[0m
    at [0m[1m[3mArray.map[0m ([0m[36m<anonymous>[0m)
    at [0m[1m[3mFunction.SQL[0m ([0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts[0m:[0m[33m636[0m:[0m[33m10[0m)
    at async [0m[1m[3mdrhSQL[0m ([0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/service/diabetes-research-hub/package.sql.ts[0m:[0m[33m1800[0m:[0m[33m10[0m)
    at async [0m[36mfile:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/service/diabetes-research-hub/package.sql.ts[0m:[0m[33m1807[0m:[0m[33m16[0m
