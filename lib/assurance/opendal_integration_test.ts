import * as path from "https://deno.land/std@0.224.0/path/mod.ts";

const E2E_TEST_DIR =  path.fromFileUrl(
    import.meta.resolve(`./`),
  );

console.log({  E2E_TEST_DIR })