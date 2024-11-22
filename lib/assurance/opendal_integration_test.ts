// TODO: uncomment when 1.5.0 is released
// import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
// import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
// import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";
// import { assertEquals } from "jsr:@std/assert@1";

// const E2E_TEST_DIR = path.fromFileUrl(
//   import.meta.resolve(`./`),
// );

// async function countFilesInDirectory(
//   directoryPath: string,
// ): Promise<number> {
//   let fileCount = 0;

//   for await (const dirEntry of Deno.readDir(directoryPath)) {
//     if (dirEntry.isFile) {
//       fileCount++;
//     }
//   }

//   return fileCount;
// }

// Deno.test("surveilr_udi_dal_fs", async (t) => {
//   const testFixturesDir = path.join(E2E_TEST_DIR, "test-fixtures");

//   const rssdPath = path.join(E2E_TEST_DIR, "opendal-rssd-e2e.sqlite.db");
//   if (await Deno.stat(rssdPath).catch(() => null)) {
//     await Deno.remove(rssdPath).catch(() => false);
//   }

//   const sql = `
//         INSERT INTO uniform_resource (
//             uniform_resource_id,
//             device_id,
//             ingest_session_id,
//             ingest_fs_path_id,
//             uri,
//             content_digest,
//             content,
//             size_bytes,
//             last_modified_at,
//             nature,
//             created_by,
//             created_at
//         )
//         SELECT
//             ulid(),   
//             surveilr_device_id(),           
//             surveilr_ingest_session_id(),   
//             NULL, -- you can create an ingest_fs_path_id entry              
//             path AS uri,                   
//             hex(md5(content)),              
//             content,                       
//             size AS size_bytes,             
//             last_modified AS last_modified_at, 
//             content_type AS nature,        
//             'system',                       
//             CURRENT_TIMESTAMP               
//         FROM surveilr_udi_dal_fs('${testFixturesDir}');
//     `;

//   await t.step("execute sql with function", async () => {
//     const result = await $`echo ${sql} | surveilr shell -d ${rssdPath}`
//       .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr surveilr_udi_dal_fs function.",
//     );
//   });

//   await t.step("verify uniform resource", async () => {
//     const db = new DB(rssdPath);
//     const result = db.query<[number]>(
//       `SELECT COUNT(*) AS count FROM uniform_resource`,
//     );
//     assertEquals(result.length, 1);

//     const uniformResources = result[0][0];
//     const testFixtureEntries = await countFilesInDirectory(testFixturesDir);
//     assertEquals(uniformResources, testFixtureEntries);

//     db.close();
//   });
// });
