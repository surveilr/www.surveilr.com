#!/usr/bin/env -S deno run --allow-read --allow-run --allow-env

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

console.log(JSON.stringify(
  {
    "opsfolio-evidence": [{
      fii: "xyz1",
      producer: "cmd1",
      evidence: await $`echo "output from cmd1"`.text(),
    }, {
      fii: "xyz2",
      producer: "cmd2",
      evidence: await $`echo "output from cmd2"`.text(),
    }],
  },
  null,
  "    ",
));
