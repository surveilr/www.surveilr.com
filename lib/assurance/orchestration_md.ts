import { join } from "https://deno.land/std@0.224.0/path/mod.ts";
import { assert, assertEquals, assertExists } from "jsr:@std/assert@1";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";

const TEST_DIR = join(Deno.cwd(), "lib/assurance");
const TEST_DATA_DIR = join(TEST_DIR, "datasets-transformed-archive/study-2");
const RSSD_PATH = join(TEST_DIR, "test.sqlite.db");

Deno.test("transform markdown test", async (t) => {
  if (await Deno.stat(TEST_DIR).catch(() => null)) {
    await Deno.remove(TEST_DIR, { recursive: true }).catch(() => {});
  }
  
  await Deno.mkdir(TEST_DATA_DIR, { recursive: true });
  
  const files = [
    {
      name: "sample1.md",
      content: "# Heading 1\n\nThis is some content.\n\n## Heading 2\n\nMore content here."
    },
    {
      name: "sample2.md",
      content: "# Another Document\n\n- List item 1\n- List item 2\n\n```javascript\nconsole.log('hello');\n```"
    }
  ];
  
  for (const file of files) {
    await Deno.writeTextFile(join(TEST_DATA_DIR, file.name), file.content);
  }
  
  console.log("Created test markdown files");
  
  await t.step("ingest markdown files", async () => {
    const result = await $`surveilr ingest files -d ${RSSD_PATH} -r ${TEST_DATA_DIR}`.text();
    console.log("Ingest result:", result);
    
    assertExists(
      await Deno.stat(RSSD_PATH).catch(() => null),
      "Database should be created after ingestion"
    );
  });
  
  const db = new DB(RSSD_PATH);
  
  await t.step("verify ingestion", () => {
    const result = db.queryEntries("SELECT * FROM uniform_resource WHERE nature='md'");
    assertEquals(result.length, files.length, "Should have ingested all markdown files");
    console.log(`Found ${result.length} markdown resources in database`);
  });
  
  await t.step("transform all markdown files", async () => {
    const result = await $`surveilr orchestrate -d ${RSSD_PATH} transform-markdown`.text();
    console.log("Transform result:", result);
  });
  
  await t.step("verify transformation", () => {
    const jsonResources = db.queryEntries("SELECT * FROM uniform_resource WHERE nature='json'");
    assert(jsonResources.length > 0, "Should have created JSON resources");
    console.log(`Found ${jsonResources.length} transformed JSON resources`);
    
    const elaborations = db.queryEntries(
      "SELECT * FROM uniform_resource_transform WHERE from_nature='md' AND to_nature='json'"
    );
    assert(elaborations.length > 0, "Should have created transformation elaborations");
    console.log(`Found ${elaborations.length} transformation elaborations`);
  });
  

  await db.execute("DELETE FROM uniform_resource WHERE nature='json'");
  await db.execute("DELETE FROM uniform_resource_transform");
  
  await t.step("transform with heading selector", async () => {
    const result = await $`surveilr orchestrate -d ${RSSD_PATH} transform-markdown --md-select "headings:#"`.text();
    console.log("Transform with selector result:", result);
    
    const headingResources = db.queryEntries(
      "SELECT * FROM uniform_resource WHERE nature='json' AND uri LIKE 'md-select:headings%'"
    );
    assert(headingResources.length > 0, "Should have found headings");
    console.log(`Found ${headingResources.length} resources with headings`);
  });
  
  db.close();
  
  await Deno.remove(TEST_DIR, { recursive: true }).catch(() => {});
  
  console.log("Test completed successfully");
});