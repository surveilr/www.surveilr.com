# surveilr AI Workforce™ Prompts Transformation

A practical doctrine for taking modular AI prompt files (Markdown) from a writer‑friendly directory layout, ingesting them into a **surveilr** SQLite evidence warehouse, and then composing larger **system prompts**—purely with SQL—for AnythingLLM or any RAG pipeline.

* **Audience:** Engineers who are fluent in SQL
* **Goal:** Keep prompts modular for authors, store them uniformly in SQLite, then **mix, match, and emit** bigger system prompts via SQL with full traceability.

**NOTE:** **IMPORTANT**: This document describes how to perform AI Workforce™ for Opsfolio.com specifically but is the first use case for a more [generalized AI Context Middleware pattern](https://github.com/surveilr/www.surveilr.com/issues/556). Be sure to work specifically towards turning Opsfolio.com into an AI-native Sales, Service, Support portal for Opsfolio CaaS similar to [inkeep AI Service](https://inkeep.com/). But also keep in mind it needs to be generalized for a surveilr pattern as well.

(Avinash): We are making progress in evaluating a complete SQLPage pattern and will edit this section with the examples created. Will be looking into how to incorporate InKeep AI service.

## Why this workflow?

* **Local‑first, SQL‑centric**: surveilr ingests files, normalizes them, and stores content + metadata in tables you can query with SQL.
* **Evidence & audit**: Everything is append‑only and traceable; composed outputs are persisted as **transforms** linked to source files.
* **Batteries included**: Use only SQL to assemble deterministic, ordered system prompts, then export to a RAG‑friendly folder structure (e.g., AnythingLLM collections).

## Naming conventions

* `ai_ctxe_` should be the prefix of any custom tables, views, etc. we create (like `ai_ctxe_prompt` view) - "CtxE" means "context engineering" (_ctxe_ to be replaced with workflow)
* Be sure to use _kebab-case_ for filenames and frontmatter keys (e.g. `xy-z` not `xy_z`).

## Source Layout (for prompt authors)

By convention, your repo has a root for all AI Workforce™ artifacts:

```
ai-context-engineering/
```

Inside it, authors organize prompts as Markdown, **modularly**:

* `*.prompt.md` → full prompt modules
* `*.prompt-snippet.md` → smaller, reusable blocks

❗ Be sure to read Netspective AI Interactions Engineering Manifesto for why Markdown sources are so important.

Example:

```
ai-context-engineering/
  role/
  task/
  regime/
```

**Naming conventions:**

- Directory name should match public website audience-routing
- Filename:
  - `<audience>--<visibility>--<tenancy>--<function>--<kind>--<slug>.prompt.md`
  - `<audience>--<visibility>--<tenancy>--<function>--<kind>--<slug>.prompt-snippet.md`
  - Example: `public--cross-tenant--support--role-ctos.prompt.md`

**Recommended frontmatter** in each file:

**NOTE:** **IMPORTANT**: Study [inkeep AI Self Service platform](https://inkeep.com/) and perform teardowns to help understand how they describe and define the different kinds of sales, service, support, customer success, etc. content to present all the same functionality on Opsfolio.com. By understanding what `inkeep` does, we can create frontmatter to organize the same content. Update this section with `inkeep` learnings and discuss with Shahid before finalizing frontmatter.

Rich frontmatter gives `surveilr` a reliable way to categorize (public sales/marketing, support/success, internal cross-tenant, tenant-specific, etc.), to govern access, and to assemble modular prompts with confidence. This keeps your AI Workforce™ upstream, reproducible, and ready for AnythingLLM/DSPy/Ax downstream.

Specifically, we want our frontmatter in Markdown so that `surveilr` can:

* **Ingest many source types** (docs, KBs, blogs, changelogs, tickets).
* **Normalize & label** by audience, purpose, product, version, and visibility.
* **Attach provenance** (where it came from, who owns it, when it changed).
* **Control access** (public vs internal; tenant-specific).
* **Chunk + enrich** content for search/RAG (semantic tags, synonyms, summaries).

### Opinionated taxonomy (controlled values)

Use **controlled vocabularies** so automation stays predictable:

- **audience:** `external`, `internal`
- **visibility:** `public`, `internal`, `restricted`
- **confidentiality:** * `public`, `internal`, `restricted`, `secret`
- **tenancy:** `cross-tenant`, `tenant-specific`
- **function:** `sales`, `marketing`, `support`, `success`, `docs`, `devrel`, `product`, `security`, `legal`
- **artifact-nature:** `kb-article`, `playbook`, `runbook`, `howto`, `faq`, `release-notes`, `case-study`, `prompt-module`, `policy`, `system-instruction`, `dataset-note`
- **lifecycle:** `draft`, `review`, `approved`, `deprecated`
- **channel:** `docs-site`, `help-center`, `community`, `ticketing`, `sales-enablement`, `website`, `internal-wiki`
- **jurisdiction (optional):** `global`, `us`, `eu`, `uk`, `apac`, etc.

Be sure to use _kebab-case_ for keys (e.g. `xy-z` not `xy_z`).

This is the minimal, strongly-typed set you can lint:

```yaml
---
id: opsfolio-<slug>-<yyyy-mm-dd>               # stable id for diffs and references
title: ""                                      # human title
summary: ""                                    # 1–2 sentence abstract
artifact-nature: prompt-module                   # controlled vocab
function: support                              # controlled vocab
audience: internal                             # external|internal
visibility: private                            # public|private
tenancy: cross-tenant                          # cross-tenant|tenant-specific
tenant-id: null                                # required if tenant-specific
confidentiality: internal                      # public|internal|restricted|secret
lifecycle: approved                            # draft|review|approved|deprecated

product:
  name: opsfolio
  version: ">=2.4 <3.0"                        # semver/range if relevant
  features: [ "alerts", "assets" ]

channels: [ help-center, docs-site ]           # controlled list
topics: [ "onboarding", "integrations" ]       # free-form but linted against glossary
tags: [ "howto", "sla", "api" ]                # free-form
keywords: [ "Opsfolio", "SLAs", "webhook" ]    # SEO-ish / retrieval hints

provenance:
  source-uri: "https://..."                    # where original came from (if migrated)
  # created-by: "user:razak"                   # only include if not in Git-managed repo
  # created-at: "2025-08-05T12:11:00Z"         # only include if not in Git-managed repo
  # updated-by: "user:avinash"                 # only include if not in Git-managed repo
  # updated-at: "2025-08-09T07:40:00Z"         # only include if not in Git-managed repo
  reviewers: [ "user:cs-lead", "user:security" ]

governance:
  pii: false
  legal-hold: false
  export-ok: true
  usage-policy: "may-train-internal"           # or: "no-train", "may-train-public"

access-control:
  owner-team: "support"
  allowed-roles: [ "support-engineer", "admin" ]
  allowed-tenants: []                          # fill if tenant-specific
  embargo-until: null

rag:
  chunking:
    strategy: "by_h2"
    max-tokens: 800
  embed-hint: "prioritize procedures and step lists"
  synonyms: [ "SLA", "service level agreement" ]
  dedupe-key: "opsfolio:kb:onboarding"         # useful for UR transforms
  canonical: true

relations:
  supersedes: [ "opsfolio-old-onboarding" ]
  depends-on: [ "opsfolio-api-auth" ]
  related: [ "opsfolio-csat-playbook" ]

i18n:
  lang: "en"
  source-lang: "en"
  translations: []

# Required for prompt modules
prompt:
  role: "system"                               # system|developer|user|tool
  intent: "triage inbound support issues"
  io-contract:
    input-schema-ref: "#/schemas/ticket.json"
    output-schema-ref: "#/schemas/triage.json"
  safety:
    refuse-on: [ "credentials", "keys" ]
    redaction: true
---
```

> Why so much? Because these fields become the **glue**: they drive ingestion routing, chunking, ACL, RAG selection, and evaluation—exactly the kind of enrichment an Inkeep-like system would rely on.

---

#### Examples (for reference and education, don't copy/paste blindly)

##### 1) External public marketing artifact

```yaml
---
id: opsfolio-marketing-value-prop-2025-08-01
title: "Why Opsfolio for Compliance-Driven Ops"
summary: "One-pager positioning Opsfolio for regulated industries."
artifact-nature: case-study
function: marketing
audience: external
visibility: public
tenancy: cross-tenant
confidentiality: public
lifecycle: approved
product: { name: opsfolio, version: "*" }
channels: [ website ]
topics: [ "positioning", "compliance" ]
tags: [ "marketing", "regulated" ]
provenance: { source-uri: null, created-by: "user:pm", created-at: "2025-08-01T00:00:00Z" }
governance: { pii: false, export_ok: true, usage-policy: "may-train-public" }
access_control: { owner_team: "marketing", allowed-roles: [ "any" ], allowed_tenants: [] }
rag: { chunking: { strategy: "by_h2", max_tokens: 600 }, canonical: true }
---
```

##### 2) Internal private cross-tenant sales artifact

```yaml
---
id: opsfolio-sales-objection-handling-2025-08-03
title: "Objection handling for SOC2 budget pushback"
artifact-nature: playbook
function: sales
audience: internal
visibility: private
tenancy: cross-tenant
confidentiality: restricted
lifecycle: approved
channels: [ sales-enablement ]
governance: { pii: false, export-ok: false, usage_policy: "no-train" }
access_control: { owner_team: "sales", allowed_roles: [ "sales", "admin" ], allowed_tenants: [] }
rag: { chunking: { strategy: "by_h3", max_tokens: 700 }, embed_hint: "prioritize objection→response pairs" }
---
```

##### 3) Private tenant‑specific support runbook

```yaml
---
id: opsfolio-tenant-acme-runbook-alerts-2025-08-04
title: "ACME: On-call runbook for Alerts v2"
artifact-nature: runbook
function: support
audience: internal
visibility: private
tenancy: tenant-specific
tenant-id: "tenant:acme"
confidentiality: secret
lifecycle: approved
channels: [ ticketing, help-center ]
governance: { pii: true, export_ok: false, legal_hold: true, usage_policy: "no-train" }
access_control:
  owner_team: "support"
  allowed_roles: [ "support-engineer", "admin" ]
  allowed_tenants: [ "tenant:acme" ]
rag:
  chunking: { strategy: "by_steps", max_tokens: 500 }
  dedupe_key: "tenant:acme:runbook:alerts-v2"
relations: { depends_on: [ "opsfolio-alerts-feature-ref" ] }
---
```

##### 4) Prompt module (system instruction) for triage

```yaml
---
id: opsfolio-prompt-triage-system-2025-08-05
title: "System: Support ticket triage"
artifact-nature: prompt-module
function: support
audience: internal
visibility: private
tenancy: cross-tenant
confidentiality: internal
lifecycle: approved
prompt:
  role: "system"
  intent: "Classify inbound tickets and extract SLA/feature signals."
  io_contract:
    input_schema_ref: "#/schemas/ticket.json"
    output_schema_ref: "#/schemas/triage.json"
  safety: { refuse_on: [ "credentials", "secrets" ], redaction: true }
rag:
  chunking: { strategy: "none" }   # keep as a single atomic prompt
  synonyms: [ "triage", "classification" ]
---
```

### Why this works in surveilr

* All frontmatter is **portable JSON** once ingested; it maps cleanly to your content tables/“uniform resources,” giving you:

  * **Routing & ACL** from `audience/visibility/tenancy/confidentiality/access_control`.
  * **RAG hygiene** from `rag.chunking`, `synonyms`, `dedupe_key`, `canonical`.
  * **Governance** & **provenance** for audits and safe reuse.
* During **chunking**, copy forward the frontmatter so each chunk carries the same labels (no orphaned context).
* During **exports** (e.g., `.build/anythingllm/`), keep files grouped by `function/artifact-nature`, and filter by `audience + visibility + tenancy` for the target index.

### Lint rules (run in CI)

1. All controlled fields must use allowed values.
2. If `tenancy = tenant-specific`, `tenant-id` must be present.
3. If `visibility = public`, `confidentiality` must be `public` and `pii = false`.
4. `prompt.*` required when `artifact-nature = prompt-module`.
5. `lifecycle != deprecated` for anything exported to production RAG.
6. No secrets in body; if detected, block merge.

### Ingestion & organization flow

1. **Author** Markdown with the frontmatter above.
2. **Pre-ingest linter** validates taxonomy & ACL.
3. **surveilr ingest** parses frontmatter → stores as structured metadata; computes digest.
4. **Transform** (optional): enforce chunking, generate summaries/keywords, push `uniform_resource_transform` records.
5. **Export** to RAG/orchestration filtered by labels (e.g., `audience=external` for public help; `function=support AND visibility=private` for internal agents).
6. **Evaluate**: log which labels lead to best retrieval; tune `rag.embed_hint` and `synonyms`.

## Ingest: one command

From the repo root:

```bash
cd ai-context-engineering
surveilr ingest files
```

This creates/updates a local SQLite database (by convention):

```
resource-surveillance.sqlite.db
```

### What surveilr stores

* **`ur_ingest_session`**: one row per ingest run; tracks device/session metadata.
* **`ur_ingest_session_fs_path`**: identifies the walked root path (e.g., your `ai-context-engineering/` folder).
* **`ur_ingest_session_fs_path_entry`**: one row per discovered file (path, basename, extn, rel paths).
* **`uniform_resource`**: the **content** record (URI, content bytes/text, size, digest, frontmatter JSON).
* **`uniform_resource_transform`**: any **derived artifact** you create (e.g., merged system prompts), linked back to a source `uniform_resource`.

All tables are **append‑only** and thus naturally support revision history and auditing.

## Query: find prompt modules/snippets in the DB

> Works directly against `resource-surveillance.sqlite.db`. Use `sqlite3` or your favorite client.

```sql
-- List all prompt modules/snippets with useful attributes
SELECT
  fs.file_path_rel_parent AS module_dir,
  fs.file_basename,
  ur.uri,
  ur.size_bytes,
  json_extract(ur.frontmatter, '$.merge_group') AS merge_group,
  json_extract(ur.frontmatter, '$.order') AS ord
FROM ur_ingest_session_fs_path_entry AS fs
JOIN uniform_resource AS ur
  ON ur.uniform_resource_id = fs.uniform_resource_id
WHERE fs.file_basename LIKE '%.prompt.md'
   OR fs.file_basename LIKE '%.prompt-snippet.md'
ORDER BY module_dir, ord, fs.file_basename;
```

We should wrap all the above into a SQL view called `ai_ctxe_prompt` to make this easier:

Refer to: src/scripts/ai-ctxe-prompt.sql

This view, named ai_ctxe_prompt, simplifies access to AI prompt components stored within the uniform_resource table.

It extracts key metadata from the JSON frontmatter column, such as the merge_group and ord (order) for prompt assembly, and presents the cleaned-up text content of the prompt as body_text. The view specifically filters for files identified as .prompt.md or .prompt-snippet.md, making it easy to query and use these components for building larger, more complex prompts.

```sql
CREATE VIEW ai_ctxe_prompt AS
SELECT
  ur.uniform_resource_id,
  json_extract(ur.frontmatter, '$.merge-group') AS merge_group,
  COALESCE(json_extract(ur.frontmatter, '$.order'), 999999) AS ord,
  TRIM(
    CASE
      WHEN instr(ur.content, '---') = 1
        THEN substr(
          ur.content,
          instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
        )
      ELSE ur.content
    END
  ) AS body_text
FROM
  uniform_resource ur
JOIN
  ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id
WHERE
  (fs.file_basename LIKE '%.prompt.md' OR fs.file_basename LIKE '%.prompt-snippet.md');

```

```sql
SELECT * FROM ai_ctxe_prompt; 
```

## Compose a larger **system prompt** entirely with SQL

This pattern merges all files belonging to a **merge group** in **`order`**.
It constructs a single concatenated Markdown system prompt.

```sql
-- Choose a merge group
WITH ordered AS (
  SELECT
    ur.uniform_resource_id,
    COALESCE(json_extract(ur.frontmatter, '$.order'), 999999) AS ord,
    TRIM(CAST(ur.content AS TEXT)) AS body_text
  FROM uniform_resource ur
  JOIN ur_ingest_session_fs_path_entry fs
    ON fs.uniform_resource_id = ur.uniform_resource_id
  WHERE (fs.file_basename LIKE '%.prompt.md' OR fs.file_basename LIKE '%.prompt-snippet.md')
    AND json_extract(ur.frontmatter, '$.merge_group') = 'core-system'
),
glue AS (
  SELECT printf(
    "<!-- source:%s | ord:%d -->\n%s\n",
    o.uniform_resource_id, o.ord, o.body_text
  ) AS chunk
  FROM ordered o
  ORDER BY o.ord
)
SELECT GROUP_CONCAT(chunk, '\n') AS composed_system_prompt
FROM glue;
```

> Note: Some SQLite builds don’t guarantee `GROUP_CONCAT` ordering unless you order in a subquery. The CTE above handles it.

## Persist the composed prompt as a **transform**

Store the merged output in `uniform_resource_transform` or your own custom table schemas for traceability and easy export.

💡 While `surveilr` has default information schema to store transformations, it's often best to create your own SQL views or tables to match your specific requirements.

**Approach:** fetch the composed text into your client (as `:composed_text`), pick any representative source `uniform_resource_id` from the group, then insert a transform row.

```sql
-- Representative source row (first by order)
WITH src AS (
  SELECT ur.uniform_resource_id
  FROM uniform_resource ur
  JOIN ur_ingest_session_fs_path_entry fs
    ON fs.uniform_resource_id = ur.uniform_resource_id
  WHERE json_extract(ur.frontmatter, '$.merge_group') = 'core-system'
  ORDER BY COALESCE(json_extract(ur.frontmatter, '$.order'), 999999)
  LIMIT 1
)
INSERT INTO uniform_resource_transform (
  uniform_resource_id, uri, content_digest, content, nature, size_bytes, created_by
)
VALUES (
  (SELECT uniform_resource_id FROM src),
  'ai-context-engineering/.build/anythingllm/core/core-system.system-prompt.md', -- logical output path
  :digest,                 -- provide a digest (e.g., SHA1/256) from your app/client
  :composed_text,          -- the concatenated Markdown
  'system_prompt',         -- arbitrary nature/type you use for filtering
  length(:composed_text),
  'surveilr-sql'
);
```

**About `:digest`**: SQLite doesn’t have a stock SHA function. Compute it in your app (Python, Node, etc.) and pass as a parameter. If you have a hashing UDF, use it instead.

## Export transforms to files (for AnythingLLM or any RAG)

AnythingLLM can ingest a directory of Markdown files as a “collection”. We’ll export any `uniform_resource_transform` rows whose `uri` points into a **`.build/anythingllm/...`** path.

**List candidates to export:**

```sql
SELECT
  uri AS build_path,
  CAST(content AS TEXT) AS body
FROM uniform_resource_transform
WHERE nature IN ('system_prompt', 'rag_doc')
  AND uri LIKE 'ai-context-engineering/.build/anythingllm/%';
```

### How the Composition, Adding to Transformations table and export to prompt files works

Refer to: src/scripts/deno/compose-and-persist-prompt.ts

The script's main function, `composeAndPersistPrompt`, performs the following key steps:

1. **Database Connection:** It establishes a connection to the specified SQLite database file using the `deno-sqlite` library.
2. **Prompt Composition:** It executes a SQL query to retrieve and concatenate text components from the **`ai_ctxe_prompt`** table. It filters these components by a given `merge_group` and orders them to ensure the final prompt is assembled correctly.
3. **Source Identification:** A second query finds the `uniform_resource_id` of the first component in the group. This ID acts as a representative source for the newly created prompt.
4. **Content Hashing:** The composed prompt text is hashed using the SHA-256 algorithm to create a unique  **`content_digest`** . This digest can be used later to verify the integrity or uniqueness of the prompt.
5. **Data Insertion:** The script generates a unique UUID for the new record and constructs a file path. It then inserts all the collected data—the unique ID, source ID, output path, content digest, the composed text itself, and other metadata—into the **`uniform_resource_transform`** table.
6. **Error Handling and Cleanup:** The script includes a `try...catch...finally` block to handle potential database errors and ensures the database connection is always closed, regardless of whether the operation was successful.

### Key Database Tables

* **`ai_ctxe_prompt`** : This table stores the individual text fragments that make up a system prompt. It includes columns for the text body (`body_text`), a `merge_group` to logically group related fragments, and an `ord` column to define the order of concatenation.
* **`uniform_resource_transform`** : This table stores the final, composed system prompts. It acts as a cache or registry for prompts that have been built from the components.

### How the Export To Prompt Files Works

Refer to: src/scripts/deno/export-transform.ts

The `exportMergedPromptsToFiles` function is the core of the script and performs the following tasks:

1. **Connect to the Database** : It establishes a read-only connection to the SQLite database file specified by `DB_PATH`.
2. **Retrieve Common Prompt** : It queries the **`ai_ctxe_prompt`** table to get the text for the `common` merge group. This common text serves as a base prompt to be prepended to all other prompts and documents.
3. **Fetch Prompts and Documents** : It executes a query that joins the **`uniform_resource_transform`** and **`uniform_resource_file`** tables. This retrieves the content of all records with a `nature` of either `system_prompt` or `rag_doc` and their corresponding relative file paths.
4. **Merge and Export** : The script iterates through each record found in the previous step. For each one, it:

* Combines the common promptwith the specific prompt or document content.
* Constructs a full output file path within a `.build` directory.
* Creates the necessary directories if they don't already exist.
* Writes the final, merged content to the specified file.

5. **Error Handling and Cleanup** : The script includes a `try...catch...finally` block to manage potential errors and ensures the database connection is closed properly after all operations are complete.

### Executing the scripts

Refer to the README.md file in the src/scripts folder.

The folder tree will match the ai-context-engineering replicates the folder structure of the source directory.

Now point AnythingLLM (or your RAG indexer) at `ai-context-engineering/.build/anythingllm/` and ingest.

## AnythingLLM Integration

The recommended approach for deploying composed prompts to AnythingLLM is through the Developer API. This creates a seamless, automated pipeline from modular prompt authoring to live workspace updates.

### How it works

- Compose prompts using the SQL workflow described above
- Export to build directory (.build/anythingllm/)
- Deploy directly to AnythingLLM workspaces via API

The integration uses AnythingLLM's /api/workspace/{workspace_slug}/update endpoint to push your composed system prompts directly into the target workspace. This API-first approach is the best practice as it enables automation, version control, and eliminates manual file management.

### CLI Tool Usage

The CLI tool accepts a workspace slug and the path to your composed prompt:

```bash
deno run --allow-read --allow-net ./src/scripts/deno/load-system-prompt.ts \
           --slug=<workspace-slug> \
           --file=src/ai-context-engineering/.build/anythingllm/industry/external--public--cross-tenant--marketing--industry--healthcare.prompt.md \
           --workspaces-url=<AnythingLLM-url>
```

## Building multiple system prompts (pattern)

Repeat the same **compose → transform → export** steps per `merge_group`. For example:

* `core-system`
* `retrieval`
* `safety`
* `tooling-plugins`
* `app-onboarding`

Tip: you can also compose **by tag** or any frontmatter attribute, not just `merge_group`.

## Operational tips

* Always set a numeric `order` in frontmatter to avoid nondeterministic merges.
* Keep reusable blocks in `*.prompt-snippet.md`; keep big, top‑level modules in `*.prompt.md`.
* Use `nature` in `uniform_resource_transform` (e.g., `system_prompt`, `rag_doc`) to organize exports.
* Store the exact SQL you used for composition in a log table (e.g., `ur_ingest_session_udi_pgp_sql`) if you want fully self‑describing pipelines.

## Quickstart Checklist

1. Arrange authoring files under `ai-context-engineering/**` with frontmatter.
2. Run `surveilr ingest` → creates/updates `resource-surveillance.sqlite.db`.
3. Use the **compose SQL** to concatenate a merge group into a single system prompt.
4. **Insert** the composed text into `uniform_resource_transform` with a build path URI.
5. Run the **export script** → writes Markdown files for AnythingLLM ingestion.

## Appendix: Convenience SQL

**Preview a group’s ordered pieces:**

```sql
WITH candidates AS (
  SELECT
    ur.uniform_resource_id,
    CAST(ur.content AS TEXT) AS body_text,
    COALESCE(json_extract(ur.frontmatter, '$.order'), 999999) AS ord
  FROM uniform_resource AS ur
  JOIN ur_ingest_session_fs_path_entry AS fs
    ON fs.uniform_resource_id = ur.uniform_resource_id
  WHERE (fs.file_basename LIKE '%.prompt%.md')
    AND json_extract(ur.frontmatter, '$.merge_group') = 'core-system'
)
SELECT * FROM candidates ORDER BY ord;
```

**Show ingest stats (optional)**:

```sql
SELECT *
FROM ur_ingest_session_files_stats
ORDER BY ingest_session_finished_at DESC;
```

### TL;DR

* **Keep** prompts modular in `ai-context-engineering/**`.
* **Ingest** with `surveilr ingest` → everything lands in SQLite.
* **Compose** bigger system prompts using **SQL** only.
* **Persist** as transforms and **export** to `.build/anythingllm/**`.
* **Ingest** in AnythingLLM (or any RAG) from that build directory.

---

# When the surveilr‑only (SQL + Markdown) approach falls short — and when to switch to DSPy or Ax

**NOTE:**  This was AI-generated by Shahid on Aug 8, 2025 and needs to be edited to match Opsfolio.com AI Workforce™ structure and for accuracy of code. It should not be considered canonical or complete until Razak and Avinash have tested it thoroughly and gotten approval from Shahid.
(Avinash): We need to exhaust the options in Surveilr, and we are testing the outcomes with AnythingLLM in order to evaluate the above.

`surveilr` + SQLite is perfect when your “orchestration” is basically **content assembly**:

* deterministic merges of modular `*.prompt.md` / `*.prompt-snippet.md`
* a few parameters (filled by SQL)
* emitting ready‑to‑ingest Markdown files for AnythingLLM/RAG

But there’s a ceiling. You’ll feel it when you need **logic, learning, or types** that SQL and static prompts just don’t cover.

## Clear signs you’ve hit the ceiling

1. **Dynamic control‑flow**. If the prompt flow depends on runtime branches (“if the model detects PII, fork to sanitization; else continue”), retries, fallbacks, or multi‑tool routing, SQL string concatenation isn’t enough.
2. **Programmatic state & loops**. Multi‑step agents, search‑reflect‑refine loops, tool invocations with feedback, or evaluation‑driven iteration (e.g., keep refining until quality ≥ threshold) require code, not just SQL.
3. **Typed I/O and schema‑validated outputs**. When you need the model to return **strongly‑typed structures** (JSON schemas, Pydantic/TypeScript types), validate them, and branch on the result, you’ll want a typesafe runtime.
4. **Learning/optimization of prompts**. If you want automatic few‑shot synthesis, prompt tuning per task, or **compile‑time learning** (optimize demos, selectors, or retrieval routing), you’re outside static composition.
5. **Multi‑model, tool‑rich orchestration**. Calling external tools/APIs (search, vector DBs, SQL DBs), mixing models, streaming tokens, cost/latency budgets, or circuit‑breaker policies—all much easier in code.
6. **Eval, A/B tests, and telemetry**. Running offline evals, unit tests for prompt contracts, A/B/C model comparisons, tracing, and regression gates benefit from a programmatic framework with metrics and hooks.

## What to use instead (or alongside) surveilr

### Julep

TODO: See [Julep](https://github.com/julep-ai/julep) BaaS for Agents to see if it can work together with `surveilr` AI Context Middleware pattern.

### DSPy (Python)

Use DSPy when you need:

* **Declarative pipelines** with **Signatures** (typed argument/return specs) and **Compilers** that *learn* few‑shot prompts and selectors automatically.
* **Structured I/O** validation and component composition (retrievers, rerankers, tool calls) with **optimization** over eval sets.
* **Offline tuning** of prompts and retrieval strategies using feedback/metrics—then “freeze” the compiled program.

Typical shape:

```python
# Pseudo-illustration
from dspy import Signature, Module
from my_prompts import load_from_surveillance_db  # you still source text from surveilr

class Triage(Signature):
    text: str
    risk_category: str  # learned mapping
    justification: str

class TriageModule(Module):
    def __init__(self):
        super().__init__()
        self.predict = Triage  # DSPy compilers optimize the prompt/demos

    def forward(self, text):
        return self.predict(text=text)

# Train/compile on eval set, then run on live inputs
```

### TypeScript

TODO: Add content to Use DSPy.js or Ax or other TypeScript-based "programmatic LLM orchestration" tools.

## The hybrid we recommend (what most teams end up doing)

* **Keep surveilr as the content source of truth.** Writers edit modular Markdown in `ai-context-engineering/**`. You ingest with `surveilr ingest`. SQL still composes stable “system” blocks you can reference.
* **Let DSPy / TS orchestrator pull from surveilr.** Your orchestrator loads the composed system prompts (or raw snippets) from the SQLite DB (or the exported `.build/**` files), then adds **code‑level logic**: branching, tool calls, eval loops, and typed outputs.
* **Round‑trip evidence back into surveilr.** Store compiled prompts, run artifacts, traces, and emitted system prompts back into `uniform_resource_transform` so you have auditability and reproducibility.
  If you want full run logs, use the orchestration tables (e.g., `orchestration_session*`) to capture input args, outputs, status, and diagnostics.
* **AnythingLLM stays happy.** For RAG ingestion, you still export the final prompt packs as clean Markdown files to `.build/anythingllm/**`. Programmatic flows (DSPy/TS) can generate additional artifacts (e.g., tool guides, policy cards) and drop them into that same build tree.

## Quick decision guide

* **Static assemblies, deterministic order, versioned content →** surveilr‑only is great.
* **“If X then Y” logic, tool calls, typed JSON outputs, few‑shot optimization, eval loops →** bring in **DSPy (Python)** or a **TypeScript orchestrator** (“Ax”) and have it *read from* surveilr and *write back* results/artifacts.

---

# Opinionated UI: “ AI Workforce™ ” Web App (SQLPage in surveilr)

**NOTE:**: This was AI-generated by Shahid on Aug 9, 2025 and needs more brainstorming. The idea is not to juse have a SQLPage WebUI but something that business analysts can use to visualize thier AI Workforce™ process. It should not be considered canonical or complete until Razak and Avinash have tested it thoroughly and gotten approval from Shahid.
(Avinash): We are making progress in evaluating a complete SQLPage pattern and will edit this section with the examples created.

This section defines a lean, deceptively simple—but useful—UI built with **SQLPage** inside `surveilr`. It treats prompts as first‑class, auditable content, and makes **composition, provenance, QA, and export** obvious. It’s optimized for teams who live in SQL but want a crisp web UX without building a whole SPA.

## Core principles

* **Provenance first.** Every screen exposes where content came from (file path, digest, session), and what transformed it.
* **Determinism by default.** Merge order, grouping, and export targets are visible and editable through metadata, never hidden in code.
* **Writer‑friendly.** Reflect the repo layout; don’t force authors to learn internal IDs to find their content.
* **No dead ends.** From any view you can: preview, diff, validate, compose, export.

## AI Workforce™ WebUI Navigation

1. **Dashboard**
2. **Modules & Snippets**
3. **Merge Groups**
4. **Compositions**
5. **Exports**
6. **Quality & Evals**
7. **Sessions & History**
8. **Settings**

A compact top bar offers **Search**, a **“Compose”** button (primary), and **Export** status.

## 1) Dashboard

**Audience:** Leads, reviewers, ops.

**Widgets**

* **Ingest health (Today / 7d / 30d):** files seen, files with content/frontmatter, youngest/oldest modified. (Working on creating a more detailed UI presentation of the RSSD content for this section.)
* **Prompt inventory:** counts of `*.prompt.md` and `*.prompt-snippet.md`, distinct merge groups, # of compositions ready. (Working on creating a more detailed UI presentation of the RSSD content for this section, so that data from the RSSD can be displayed.)
* **Risk/QA panel:** invalid frontmatter, missing `order`, duplicate `order` in group, oversized file warnings.
* **Recent changes:** rolling feed of updated/added modules with badging (added/updated/renamed).
* **Export pipeline status:** last export time, files produced, drift since last export (compositions newer than export).

**UX details**

* Clicking a KPI filters downstream pages (deep link with query params).
* Badges with colors (green=ok, amber=warn, red=fail) drive reviewers to fixes.

## 2) Modules & Snippets

**Audience:** Authors, librarians.

**Grid/table**

* Columns: **basename**, **merge\_group**, **order**, **tags**, **size**, **last modified**, **frontmatter status** (valid/invalid), **path** (rel), **digest** (short).
* Quick filters: extension (`.prompt.md` vs `.prompt-snippet.md`), group, tag, “missing order”, “no frontmatter”.
* Row actions: **Preview**, **Frontmatter**, **Diff**, **Open in repo**, **Add to composition**.
* Bulk actions: **Normalize metadata** (e.g., fix missing `order`), **Assign merge\_group**, **Retag**.

**Preview drawer**

* Renders Markdown.
* Shows parsed YAML frontmatter in a side panel.
* “Add to group” and “Set order” inline controls.

**Diff**

* Inline diff against previous digest/version (uses ingest history).
* Show **why** it changed (size delta, frontmatter delta, first/last 10 lines changed).

## 3) Merge Groups

**Audience:** Composers, reviewers.

**List of groups**

* Each card shows: group name, #modules, order coverage (sparkline), warnings (dup order, gaps), last composed timestamp.

**Group detail**

* **Timeline:** ordered list of items (`order`, filename, short summary).
* **Gaps & dups detector:** shows “missing orders” (e.g., 30 → 50 gap) and duplicates (two items at 40).
* **What‑if sandbox:** re‑order with drag handles (writes back to metadata on save).
* **Scoping tools:** include/exclude by tag, file pattern—saved as “views” (named filters).

## 4) Compositions

**Audience:** Composers, integrators.

**Compositions table**

* Columns: **name** (e.g., `core-system`), **merge strategy** (order asc), **post‑processing** (glue, headings, comment banners), **length (tokens)**, **last compiled**, **provenance% coverage** (how many rows have source links).
* Actions: **Preview composed**, **Tokenize & count**, **Save compiled** (stores a `uniform_resource_transform`), **Version compare**, **Set export path**.

**Composition preview**

* Two panes: **left** = source list (with orders), **right** = composed output.
* Toggle “annotate with source headers” (e.g., `<!-- file: path | ord: N -->`).
* Live token estimate and chunking suggestions.

**Version compare**

* Side‑by‑side of compiled artifacts (diff on composed text).
* Show which source snippets changed between versions.

## 5) Exports

**Audience:** RAG ops, platform.

**Collections view**

* Cards for export targets (e.g., AnythingLLM collections): **collection name**, **path prefix** (e.g., `.build/anythingllm/core/`), **# files**, **last export**, **drift** (# compositions newer than current files).

**Export run detail**

* Table: **target URI**, **bytes**, **hash**, **source composition**, **exported at**.
* Buttons: **Export now**, **Dry run**, **Manifest** (download checksums), **Clean & rebuild**.

**Drift inspector**

* Shows which compositions need export and why (source updated, metadata changed, post‑processing changed).

## 6) Quality & Evals

**Audience:** Editors, safety reviewers, MLEs.

**Metadata lint**

* Rules: missing `merge_group`, missing/duplicate `order`, invalid tags schema, frontmatter not JSON/YAML‑valid.
* One‑click **Autofix** where deterministic (e.g., suggest next free `order` slot).

**Content lint**

* Heuristics: lines > N chars, forbidden phrases, missing required safety blocks (e.g., policies).
* “Fix in source” link (opens repo URL or provides patch hints).

**Eval integration (optional)**

* Upload or pick eval sets (prompts/expected behaviors).
* Run **smoke checks**: compose → send to test LLM (or mock) → assert JSON schema, refusal where needed, citations present, etc.
* Store eval runs as artifacts; show pass/fail badges on compositions.

## 7) Sessions & History

**Audience:** Auditors, reliability.

**Ingest sessions**

* Timeline of `surveilr ingest` runs; counts by extension; min/avg/max size; youngest/oldest file timestamps.
* Click → see **files added/changed** in that run; diff quick links.

**Transform history**

* Every compiled artifact with **who**, **when**, **inputs summary**, **content digest**.
* Provenance graph: nodes = sources & transforms; edges = derivations. Click a node to open preview.

## 8) Settings

**Audience:** Admins.

* **Conventions:** default merge group names, default export paths, glue templates (header banners, separators).
* **Roles & permissions:** view vs compose vs export; “requires review” toggle before export.
* **Integrations:** repo host base URL (to “Open in repo”), AnythingLLM target roots, model providers for evals.
* **Tokenization models & limits:** configure for accurate length estimates and chunking hints.

## Search (global)

* Search by **filename**, **content substring**, **frontmatter fields** (`merge_group`, `tags`, `role`, `order`).
* Power filters: `group:core-system tag:safety has:dup-order changed:7d`.

## UX micro‑patterns that matter

* **Contextual chips** everywhere: clicking a chip applies a filter across the app.
* **Sticky provenance bar** in previews: `path · digest · last-modified · ingest-session`.
* **Keyboard shortcuts:** `/` to search, `g m` to go to Merge Groups, `c` to compose, `e` to export.
* **Dark mode** by default; monospace blocks for content; soft line‑length limits for readability.

## Pages to implement in SQLPage (suggested routes)

* `/` → Dashboard
* `/modules` → Modules & Snippets (table + previews)
* `/groups` → Merge Groups (cards + group detail)
* `/compose` → Compositions (list + builder/preview)
* `/exports` → Exports (collections + runs + drift)
* `/quality` → Quality & Evals (linters + results)
* `/sessions` → Sessions & History (ingest + transforms)
* `/settings` → Settings (conventions, roles, integrations)

Each page is backed by parameterized queries/views; state (filters, selected group, composition) is carried via query params. Write operations (e.g., setting `order`, assigning `merge_group`, saving a composed artifact, marking export path) are exposed as POST endpoints calling parameterized statements or stored procedures registered with surveilr.

## Data touchpoints (no SQL shown, just intent)

* **Inventory:** scan `ur_ingest_session_fs_path_entry` + `uniform_resource` for `*.prompt.md` and `*.prompt-snippet.md`.
* **Metadata:** read/write `frontmatter` JSON (merge\_group, order, tags, role).
* **Composition:** read source rows; persist compiled artifact into `uniform_resource_transform` with target `uri`.
* **History:** consult ingest sessions and transform tables; compute drift by comparing timestamps/digests.
* **Exports:** enumerate transform rows with URIs under `.build/anythingllm/**`; trigger export job to write files.

## Guardrails & opinions

* **Every snippet must have `merge_group` and `order`.** Missing values block composition (visible red badge).
* **Compositions require zero warnings** before export (dup order, invalid YAML, etc.).
* **Annotate sources** in composed output via HTML comments or Markdown headings—on by default for audit.
* **Frontmatter is contract.** No hidden merge logic; if it isn’t in metadata, it doesn’t exist.

## Why this UI works

It surfaces the “boring but critical” parts—**ordering, metadata quality, provenance, drift**—and turns them into one‑click actions. Authors stay in Markdown. Engineers stay in SQL. Ops gets deterministic builds for AnythingLLM. Everyone gets traceability, without a heavy frontend build.
