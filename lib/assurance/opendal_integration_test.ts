import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";
import { assert, assertEquals } from "jsr:@std/assert@1";

const E2E_TEST_DIR = path.fromFileUrl(
  import.meta.resolve(`./`),
);

async function countFilesInDirectory(
  directoryPath: string,
): Promise<number> {
  let fileCount = 0;

  for await (const dirEntry of Deno.readDir(directoryPath)) {
    if (dirEntry.isFile) {
      fileCount++;
    }
  }

  return fileCount;
}

const testFixturesDir = path.join(E2E_TEST_DIR, "test-fixtures");
const rssdPath = path.join(E2E_TEST_DIR, "opendal-rssd-e2e.sqlite.db");

Deno.test("surveilr_udi_dal_fs", async (t) => {
  if (await Deno.stat(rssdPath).catch(() => null)) {
    await Deno.remove(rssdPath).catch(() => false);
  }

  const sql = `
        INSERT INTO uniform_resource (
            uniform_resource_id,
            device_id,
            ingest_session_id,
            ingest_fs_path_id,
            uri,
            content_digest,
            content,
            size_bytes,
            last_modified_at,
            nature,
            created_by,
            created_at
        )
        SELECT
            ulid(),
            surveilr_device_id(),
            surveilr_ingest_session_id(),
            NULL, -- you can create an ingest_fs_path_id entry
            path AS uri,
            hex(md5(content)),
            content,
            size AS size_bytes,
            last_modified AS last_modified_at,
            content_type AS nature,
            'system',
            CURRENT_TIMESTAMP
        FROM surveilr_udi_dal_fs('${testFixturesDir}');
    `;

  await t.step("execute sql with function", async () => {
    const result = await $`echo ${sql} | surveilr shell -d ${rssdPath}`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr surveilr_udi_dal_fs function.",
    );
  });

  await t.step("verify uniform resource", async () => {
    const db = new DB(rssdPath);
    const result = db.query<[number]>(
      `SELECT COUNT(*) AS count FROM uniform_resource`,
    );
    assertEquals(result.length, 1);

    const uniformResources = result[0][0];
    const testFixtureEntries = await countFilesInDirectory(testFixturesDir);
    assertEquals(uniformResources, testFixtureEntries);

    db.close();
  });
});

Deno.test("surveilr_udi_dal_s3", async (t) => {
  // Check for required environment variables
  await t.step("check for the existence of S3 credentials", () => {
    assert(
      Deno.env.has("S3_BUCKET"),
      "❌ Error: S3_BUCKET environment variable not set."
    );
    assert(
      Deno.env.has("S3_ENDPOINT"),
      "❌ Error: S3_ENDPOINT environment variable not set."
    );
    assert(
      Deno.env.has("S3_REGION"),
      "❌ Error: S3_REGION environment variable not set."
    );
    assert(
      Deno.env.has("AWS_ACCESS_KEY_ID"),
      "❌ Error: AWS_ACCESS_KEY_ID environment variable not set."
    );
    assert(
      Deno.env.has("AWS_SECRET_ACCESS_KEY"),
      "❌ Error: AWS_SECRET_ACCESS_KEY environment variable not set."
    );
  });

  if (await Deno.stat(rssdPath).catch(() => null)) {
    await Deno.remove(rssdPath).catch(() => false);
  }

  const sql = `
        INSERT INTO uniform_resource (
            uniform_resource_id,
            device_id,
            ingest_session_id,
            ingest_fs_path_id,
            uri,
            content_digest,
            content,
            size_bytes,
            last_modified_at,
            nature,
            created_by,
            created_at
        )
        SELECT
            ulid(),
            surveilr_device_id(),
            surveilr_ingest_session_id(),
            NULL, -- you can create an ingest_fs_path_id entry
            path AS uri,
            digest AS content_digest,
            content,
            size AS size_bytes,
            last_modified AS last_modified_at,
            content_type AS nature,
            'system',
            CURRENT_TIMESTAMP
        FROM surveilr_udi_dal_s3();
    `;

  await t.step("execute sql with S3 function", async () => {
    const result = await $`echo ${sql} | surveilr shell -d ${rssdPath}`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr surveilr_udi_dal_s3 function."
    );
  });

  await t.step("verify S3 uniform resources", async () => {
    const db = new DB(rssdPath);
    const result = db.query<[number]>(
      `SELECT COUNT(*) AS count FROM uniform_resource`
    );
    assertEquals(result.length, 1);

    const uniformResources = result[0][0];
    assert(
      uniformResources > 0,
      `Expected to find S3 resources, but found ${uniformResources}`
    );
    
    // Optional: Check that some files have content
    const contentResult = db.query<[number]>(
      `SELECT COUNT(*) FROM uniform_resource WHERE content IS NOT NULL`
    );
    const resourcesWithContent = contentResult[0][0];
    assert(
      resourcesWithContent > 0,
      `Expected resources with content, but found ${resourcesWithContent}`
    );

    db.close();
  });
});

Deno.test("surveilr_udi_dal_gdrive", async (t) => {
  // Check for required environment variables
  await t.step("check for the existence of Google Drive credentials", () => {
    assert(
      Deno.env.has("GDRIVE_ACCESS_TOKEN"),
      "❌ Error: GDRIVE_ACCESS_TOKEN environment variable not set."
    );
  });

  if (await Deno.stat(rssdPath).catch(() => null)) {
    await Deno.remove(rssdPath).catch(() => false);
  }

  const sql = `
        INSERT INTO uniform_resource (
            uniform_resource_id,
            device_id,
            ingest_session_id,
            ingest_fs_path_id,
            uri,
            content_digest,
            content,
            size_bytes,
            last_modified_at,
            nature,
            created_by,
            created_at
        )
        SELECT
            ulid(),
            surveilr_device_id(),
            surveilr_ingest_session_id(),
            NULL, -- you can create an ingest_fs_path_id entry
            path AS uri,
            digest AS content_digest,
            content,
            size AS size_bytes,
            last_modified AS last_modified_at,
            content_type AS nature,
            'system',
            CURRENT_TIMESTAMP
        FROM surveilr_udi_dal_gdrive();
    `;

  await t.step("execute sql with Google Drive function", async () => {
    const result = await $`echo ${sql} | surveilr shell -d ${rssdPath}`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr surveilr_udi_dal_gdrive function."
    );
  });

  await t.step("verify Google Drive uniform resources", async () => {
    const db = new DB(rssdPath);
    const result = db.query<[number]>(
      `SELECT COUNT(*) AS count FROM uniform_resource`
    );
    assertEquals(result.length, 1);

    const uniformResources = result[0][0];
    assert(
      uniformResources > 0,
      `Expected to find Google Drive resources, but found ${uniformResources}`
    );
    
    // Optional: Verify content types are present
    const contentTypeResult = db.query<[number]>(
      `SELECT COUNT(DISTINCT nature) FROM uniform_resource`
    );
    const distinctContentTypes = contentTypeResult[0][0];
    assert(
      distinctContentTypes > 0,
      `Expected resources with content types, but found ${distinctContentTypes} distinct types`
    );

    db.close();
  });
});

Deno.test("surveilr_udi_dal_dropbox", async (t) => {
  // Check for required environment variables
  await t.step("check for the existence of Dropbox credentials", () => {
    assert(
      Deno.env.has("DROPBOX_ACCESS_TOKEN"),
      "❌ Error: DROPBOX_ACCESS_TOKEN environment variable not set."
    );
  });

  if (await Deno.stat(rssdPath).catch(() => null)) {
    await Deno.remove(rssdPath).catch(() => false);
  }

  const sql = `
        INSERT INTO uniform_resource (
            uniform_resource_id,
            device_id,
            ingest_session_id,
            ingest_fs_path_id,
            uri,
            content_digest,
            content,
            size_bytes,
            last_modified_at,
            nature,
            created_by,
            created_at
        )
        SELECT
            ulid(),
            surveilr_device_id(),
            surveilr_ingest_session_id(),
            NULL, -- you can create an ingest_fs_path_id entry
            path AS uri,
            digest AS content_digest,
            content,
            size AS size_bytes,
            last_modified AS last_modified_at,
            content_type AS nature,
            'system',
            CURRENT_TIMESTAMP
        FROM surveilr_udi_dal_dropbox();
    `;

  await t.step("execute sql with Dropbox function", async () => {
    const result = await $`echo ${sql} | surveilr shell -d ${rssdPath}`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr surveilr_udi_dal_dropbox function."
    );
  });

  await t.step("verify Dropbox uniform resources", async () => {
    const db = new DB(rssdPath);
    const result = db.query<[number]>(
      `SELECT COUNT(*) AS count FROM uniform_resource`
    );
    assertEquals(result.length, 1);

    const uniformResources = result[0][0];
    assert(
      uniformResources > 0,
      `Expected to find Dropbox resources, but found ${uniformResources}`
    );
    
    // Check file sizes
    const sizeResult = db.query<[number]>(
      `SELECT SUM(size_bytes) FROM uniform_resource`
    );
    const totalSize = sizeResult[0][0];
    assert(
      totalSize > 0,
      `Expected non-zero total file size, but found ${totalSize} bytes`
    );

    // Check that paths are properly formed
    const pathResult = db.query<[number]>(
      `SELECT COUNT(*) FROM uniform_resource WHERE uri LIKE '/%'`
    );
    const validPaths = pathResult[0][0];
    assertEquals(
      validPaths,
      uniformResources,
      `Expected all paths to begin with '/', but found ${validPaths} out of ${uniformResources}`
    );

    db.close();
  });
});

Deno.test("surveilr_udi_dal_postgresql", async (t) => {
  // Check for required environment variables
  const pgConnectionString = Deno.env.get("POSTGRES_CONNECTION_STRING");
  const pgTableName = Deno.env.get("POSTGRES_TABLE_NAME");
  
  await t.step("check for the existence of PostgreSQL configuration", () => {
    assert(
      pgConnectionString !== undefined,
      "❌ Error: POSTGRES_CONNECTION_STRING environment variable not set."
    );
    assert(
      pgTableName !== undefined,
      "❌ Error: POSTGRES_TABLE_NAME environment variable not set."
    );
  });

  if (await Deno.stat(rssdPath).catch(() => null)) {
    await Deno.remove(rssdPath).catch(() => false);
  }

  const sql = `
        INSERT INTO uniform_resource (
            uniform_resource_id,
            device_id,
            ingest_session_id,
            ingest_fs_path_id,
            uri,
            content_digest,
            content,
            size_bytes,
            last_modified_at,
            nature,
            created_by,
            created_at
        )
        SELECT
            ulid(),
            surveilr_device_id(),
            surveilr_ingest_session_id(),
            NULL, -- you can create an ingest_fs_path_id entry
            path AS uri,
            digest AS content_digest,
            content,
            size AS size_bytes,
            last_modified AS last_modified_at,
            content_type AS nature,
            'system',
            CURRENT_TIMESTAMP
        FROM surveilr_udi_dal_postgres('${pgConnectionString}', '${pgTableName}');
    `;

  await t.step("execute sql with PostgreSQL function", async () => {
    const result = await $`echo ${sql} | surveilr shell -d ${rssdPath}`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr surveilr_udi_dal_postgres function."
    );
  });

  await t.step("verify PostgreSQL uniform resources", async () => {
    const db = new DB(rssdPath);
    const result = db.query<[number]>(
      `SELECT COUNT(*) AS count FROM uniform_resource`
    );
    assertEquals(result.length, 1);

    const uniformResources = result[0][0];
    assert(
      uniformResources > 0,
      `Expected to find PostgreSQL resources, but found ${uniformResources}`
    );
    
    // Check that all resources have path/URI
    const pathResult = db.query<[number]>(
      `SELECT COUNT(*) FROM uniform_resource WHERE uri IS NOT NULL`
    );
    assertEquals(
      pathResult[0][0],
      uniformResources,
      "All resources should have a URI"
    );
    
    // Check that all resources have size
    const sizeResult = db.query<[number]>(
      `SELECT COUNT(*) FROM uniform_resource WHERE size_bytes > 0`
    );
    assert(
      sizeResult[0][0] > 0,
      `Expected resources with size > 0, found ${sizeResult[0][0]}`
    );

    db.close();
  });
});
// Deno.test("surveilr_udi_dal_dropbox", async (t) => {
//   await t.step("check for the existence of DROPBOX_ACCESS_TOKEN", () => {
//     assert(
//       Deno.env.has("DROPBOX_ACCESS_TOKEN"),
//       "❌ Error: Failed to verify existence of Dropbox access token.",
//     );
//   });

//   if (await Deno.stat(rssdPath).catch(() => null)) {
//     await Deno.remove(rssdPath).catch(() => false);
//   }

//   const sql = `
//           INSERT INTO uniform_resource (
//               uniform_resource_id,
//               device_id,
//               ingest_session_id,
//               ingest_fs_path_id,
//               uri,
//               content_digest,
//               content,
//               size_bytes,
//               last_modified_at,
//               nature,
//               created_by,
//               created_at
//           )
//           SELECT
//               ulid(),
//               surveilr_device_id(),
//               surveilr_ingest_session_id(),
//               NULL, -- you can create an ingest_fs_path_id entry
//               path AS uri,
//               hex(md5(content)),
//               content,
//               size AS size_bytes,
//               last_modified AS last_modified_at,
//               content_type AS nature,
//               'system',
//               CURRENT_TIMESTAMP
//           FROM surveilr_udi_dal_dropbox();
//       `;

//   await t.step("execute sql with function", async () => {
//     const result = await $`echo ${sql} | surveilr shell -d ${rssdPath}`
//       .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr surveilr_udi_dal_dropbox function.",
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
