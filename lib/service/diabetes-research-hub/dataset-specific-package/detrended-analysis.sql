Error executing service/diabetes-research-hub/dataset-specific-package/detrended-analysis.sql: Command failed: lib/service/diabetes-research-hub/dataset-specific-package/detrended-analysis.sql.ts
[0m[1m[31merror[0m: Uncaught (in promise) Error: Failed to load SQLite3 Dynamic Library
  throw new Error("Failed to load SQLite3 Dynamic Library", { cause: e });
[0m[31m        ^[0m
    at [0m[36mhttps://deno.land/x/sqlite3@0.12.0/src/ffi.ts[0m:[0m[33m633[0m:[0m[33m9[0m
Caused by: Error: `--unstable-ffi` is required
    at [0m[1m[3mdlopen[0m ([0m[36mhttps://jsr.io/@denosaurs/plug/1.0.6/mod.ts[0m:[0m[33m155[0m:[0m[33m11[0m)
    at [0m[36mhttps://deno.land/x/sqlite3@0.12.0/src/ffi.ts[0m:[0m[33m616[0m:[0m[33m13[0m
