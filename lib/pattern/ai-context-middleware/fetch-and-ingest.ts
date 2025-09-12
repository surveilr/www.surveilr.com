
// Usage:
// deno run --allow-net --allow-run --allow-write --allow-read fetch-and-ingest.ts <owner/repo> [branch] [subdir] [ingestDir]
import { $ } from "https://deno.land/x/dax@0.39.1/mod.ts";

const [repo, branch = "main", subdir = "", ingestDir = "ingest"] = Deno.args;
if (!repo) {
  console.error("Usage: deno run --allow-net --allow-run --allow-write --allow-read fetch-and-ingest.ts <owner/repo> [branch] [subdir] [ingestDir]");
  Deno.exit(1);
}

const OPSFOLIO_PAT = Deno.env.get("OPSFOLIO_PAT");
if (!OPSFOLIO_PAT) {
  console.error("OPSFOLIO_PAT not set in environment");
  Deno.exit(1);
}

async function fetchFromGitHub(url: string, acceptRaw = false) {
  const headers: Record<string, string> = { Authorization: `token ${OPSFOLIO_PAT}` };
  if (acceptRaw) headers["Accept"] = "application/vnd.github.v3.raw";
  const res = await fetch(url, { headers });
  if (!res.ok) {
    throw new Error(`Failed to fetch from GitHub API: ${res.status} ${res.statusText}`);
  }
  return acceptRaw ? new Uint8Array(await res.arrayBuffer()) : await res.json();
}

async function main() {
  // Step 1: Get latest commit SHA for the branch
  const branchApi = `https://api.github.com/repos/${repo}/branches/${branch}`;
  const branchData = await fetchFromGitHub(branchApi);
  const sha = branchData?.commit?.sha;
  if (!sha) {
    console.error("Could not determine latest commit SHA for branch", branch);
    Deno.exit(1);
  }
  // Step 2: Get the tree for that commit
  const treeApi = `https://api.github.com/repos/${repo}/git/trees/${sha}?recursive=1`;
  const treeData = await fetchFromGitHub(treeApi);
  if (!treeData.tree) {
    console.error("No tree found in API response.");
    Deno.exit(1);
  }
  // Step 3: Filter files by subdir (if provided)
  type TreeItem = { path: string; type: string; url: string };
  const files = (treeData.tree as TreeItem[]).filter((item) =>
    item.type === "blob" && (subdir ? item.path.startsWith(subdir) : true)
  );
  if (files.length === 0) {
    console.error("No files found in the specified subdir.");
    Deno.exit(1);
  }
  await Deno.mkdir(ingestDir, { recursive: true });
  for (const file of files) {
    const relPath = subdir ? file.path.substring(subdir.length).replace(/^\//, "") : file.path;
    const destPath = `${ingestDir}/${relPath}`;
    await Deno.mkdir(destPath.substring(0, destPath.lastIndexOf("/")), { recursive: true });
    // Skip if file already exists
    try {
      await Deno.stat(destPath);
      console.log(`Skipping existing file: ${destPath}`);
      continue;
    } catch (_) {
      // File does not exist, proceed to fetch
    }
    console.log(`Fetching: ${file.path}`);
    try {
      const blobUrl = file.url;
      const data = await fetchFromGitHub(blobUrl, true);
      await Deno.writeFile(destPath, data);
      console.log(`Saved to ${destPath}`);
    } catch (e) {
      console.error(`Error fetching ${file.path}:`, e);
    }
  }
  // Step 4: Run surveilr ingest
  try {
    await $`surveilr ingest files -r ${ingestDir}`;
    console.log(`Ingested all files in ${ingestDir}`);
  } catch (e) {
    console.error("Error running surveilr ingest:", e);
  }
}

if (import.meta.main) {
  main();
}
// removed stray parenthesis
