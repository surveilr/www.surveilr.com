Error executing service/diabetes-research-hub/dataset-specific-package/dclp1-uva-study.sql: Command failed: lib/service/diabetes-research-hub/dataset-specific-package/dclp1-uva-study.sql.ts
[0m[1m[31merror[0m: Uncaught (in promise) Error: Failed to load SQLite3 Dynamic Library
  throw new Error("Failed to load SQLite3 Dynamic Library", { cause: e });
[0m[31m        ^[0m
    at [0m[36mhttps://deno.land/x/sqlite3@0.12.0/src/ffi.ts[0m:[0m[33m633[0m:[0m[33m9[0m
    at [0m[1m[3meventLoopTick[0m ([0m[36mext:core/01_core.js[0m:[0m[33m175[0m:[0m[33m7[0m)
Caused by: NotCapable: Requires net access to "github.com:443", run again with the --allow-net flag
    at [0m[1m[3mmainFetch[0m ([0m[36mext:deno_fetch/26_fetch.js[0m:[0m[33m152[0m:[0m[33m43[0m)
    at [0m[36mext:deno_fetch/26_fetch.js[0m:[0m[33m353[0m:[0m[33m9[0m
    at new [0m[1m[3mPromise[0m ([0m[36m<anonymous>[0m)
    at [0m[1m[3mfetch[0m ([0m[36mext:deno_fetch/26_fetch.js[0m:[0m[33m316[0m:[0m[33m18[0m)
    at [0m[1m[3mdownload[0m ([0m[36mhttps://jsr.io/@denosaurs/plug/1.0.6/download.ts[0m:[0m[33m280[0m:[0m[33m32[0m)
    at [0m[1m[3meventLoopTick[0m ([0m[36mext:core/01_core.js[0m:[0m[33m175[0m:[0m[33m7[0m)
    at async [0m[1m[3mdlopen[0m ([0m[36mhttps://jsr.io/@denosaurs/plug/1.0.6/mod.ts[0m:[0m[33m158[0m:[0m[33m25[0m)
    at async [0m[36mhttps://deno.land/x/sqlite3@0.12.0/src/ffi.ts[0m:[0m[33m616[0m:[0m[33m7[0m
