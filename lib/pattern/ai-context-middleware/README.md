# Quick Start: Automated Workflow & .env Setup

## 1. .env File Example

Create a `.env` file in this directory with the following content:

```
# Database path for surveilr 
SURVEILR_DB_PATH=resource-surveillance.sqlite.db

# GitHub repo to fetch from (format: owner/repo)
SURVEILR_REPO=opsfolio/www.opsfolio.com

# Branch to fetch from
SURVEILR_BRANCH=main

# Subdirectory in the repo to fetch (optional, can be empty)
SURVEILR_SUBDIR=src/ai-context-engineering

# Local directory to save ingested files
SURVEILR_INGEST_DIR=ingest

# GitHub personal access token (required for API access)
GITHUB_TOKEN=your_github_token_here
```

## 2. Run the Complete Workflow

With `.env` configured, run the following command to fetch, ingest, and process everything automatically:

```fish
deno run --allow-net --allow-run --allow-write --allow-read eg.surveilr.com-prepare.ts
```

This will:

- Fetch files from GitHub (skipping existing files)
- Ingest them into the surveilr database
- Create/refresh the required SQL view
- Compose and insert system prompts
- Use all configuration from your `.env` file (no manual input required)

### To run the SQLPage Web-UI with the resource-surveillance DB.

Copy the generated resource-surveillance DB in the above step in the directory **www.surveilr.com/lib/pattern/ai-context-middleware** for use with the ai-context-middleware pattern.

```bash
$ git clone https://github.com/surveilr/www.surveilr.com.git
# use SQLPage to preview content (be sure `deno` v1.40 or above is installed)
$ cd surveilr.com/pattern/ai-context-middleware/
$ surveilr shell ./package.sql.ts
$ SQLPAGE_SITE_PREFIX="" ../../std/surveilrctl.ts dev
# launch a browser and go to http://localhost:9000/fhir/index.sql
```

## Environment Setup

Before running, set your GitHub token: GITHUB_TOKEN

```fish
set -x GITHUB_TOKEN <your_token>
```

## What the Script Does

1. Fetches the latest commit SHA for the specified branch.
2. Downloads all files (optionally filtered by subdir) from the repo.
3. Saves them to the local ingest directory.
4. Runs `surveilr ingest files -r <ingestDir>` to ingest the files.

## Troubleshooting

- Ensure your `GITHUB_TOKEN` is valid and has repo read permissions.
- Make sure `surveilr` CLI is installed and available in your PATH.
- If you encounter permission errors, check your Deno permissions and environment variables.

---

For questions or issues, contact the script maintainer.
