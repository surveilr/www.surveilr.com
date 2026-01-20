#!/usr/bin/env deno run --allow-run --allow-read --allow-env

const command = new Deno.Command("surveilr", {
  args: ["ingest", "files", "-r", "./tap-data"],
  stdout: "inherit",
  stderr: "inherit",
});

const { code } = await command.output();

if (code !== 0) {
  console.error(`Command exited with code ${code}`);
  Deno.exit(code);
}

console.log("Ingestion complete.");
