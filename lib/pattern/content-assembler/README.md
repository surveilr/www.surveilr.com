## surveilr Content Assembler Pattern

The Content Assembler is designed to harness the value of pre-curated content
shared by various people across the internet, including influencers, curators,
and other authoritative voices.

Many of these individuals share links that are generally considered valuable for
community use or as part of B2B content marketing efforts. The Content Assembler
utilizes multiple sources to ingest these authoritative links, making them
available for reuse across multiple channels.

The Content Assembler is a pattern for surveilr designed to collect, clean,
de-duplicate, and score content-focused links from multiple sources. It creates
a unified ingestion system capable of handling links shared via various
platforms, such as email newsletters, Twitter, LinkedIn, Facebook, and
Instagram. This system aims to provide a comprehensive view of content by
transforming shared links into canonical links, extracting relevant metadata,
and scoring link importance.

### Key Features and Workflow

1. ##### Link Ingestion from Multiple Sources
   - Accept links from diverse sources,including but not limited to:
     - Email newsletters
     - Twitter, LinkedIn, Facebook, and Instagram posts
     - RSS feeds or direct API submissions
   - Accept all ingestions via surveilr or custom scripts into an RSSD's
     uniform_resource table schema.
   - If the source of ingestion is email, links must be filtered for unsubscribe
     and related email list admin texts and then visited to get the actual link
     the emailed link points to.
2. ##### Link Cleaning and Normalization
   - Removal of Query Parameters:
     - Remove UTM parameters (e.g., utm_source, utm_medium) and other marketing
       query strings to clean URLs.
   - Handling URL Shorteners and Redirects:
     - Follow links through common URL shorteners (e.g., bit.ly, t.co) and
       redirections.
     - Extract the final destination URL to ensure a canonical representation of
       each link.
3. ##### Canonical Link Determination
   - Normalize URLs to a canonical form, taking into account:
     - Removing tracking codes and unnecessary query parameters.
     - Ensuring consistency in case (e.g., standardizing domain casing).
     - Resolving content served under different URLs to the same canonical link
       if applicable (e.g., ensuring HTTP/HTTPS or www differences are
       reconciled).
4. ##### Visit Canonical Links to Extract Metadata
   - HTML Metadata:
   - Extract standard HTML metadata like
     `bash<title>,<meta name="description">.`
   - OpenGraph and Twitter Card Payloads:
     - Parse OpenGraph (og:*) and Twitter Card metadata to obtain content
       descriptions, images, and other valuable attributes.
   - Additional Informational Metadata:
     - Retrieve structured data (e.g., JSON-LD for article metadata) to enrich
       content descriptions.
   - Core Content Extraction:
     - Use the Mozilla Readability library to extract the core content of the
       page without advertising or other "fluff" to ensure effective
       de-duplication and scoring.
5. ##### De-Duplication
   - Hashing for Comparison:
     - Generate hash values based on canonical URLs and metadata to identify
       duplicate links.
   - Cluster Similar Links:
     - Cluster similar links that may be different on the surface but share the
       same canonical URL and metadata.
6. ##### Link Scoring and Weighting
   - Assign scores to links based on various criteria:
     - **Source Reliability:** Score links higher if they come from verified,
       reputable sources.
     - **Engagement Metrics:** Factor in engagement signals (e.g., number of
       shares, likes, or reposts).
     - **Frequency of Occurrence:** Boost the score of links that are found
       through multiple independent sources.
     - **Metadata Quality:** Increase the score for links with rich metadata
       (e.g., high-quality OpenGraph or Twitter Card data).
7. ##### Output and Integration

   - Produce an organized collection of canonical links with metadata and
     scoring information.
   - Provide API access for querying and extracting the final canonical content,
     including:
     - Enriched metadata payloads.
     - Filtered and ranked list of links based on calculated scores.
     - Reporting and Insights: Offer insights on content popularity, source
       diversity, and engagement levels to assist decision-makers.

### Commands Used:

1. **Ingest Mail Data into Resource Surveillance Database**:
   ```bash
   surveilr ingest imap -f="Inbox" -u="account@test.com" -p="password" -a="imap.com"
   ```
   This command ingests email data from the specified inbox into the
   `uniform_resource` table in the resource surveillance database.

2. **Transform and Save Email Content**:
   ```bash
   surveilr orchestrate transform-html --css-select 'email-anchors:a'
   ```
   This command is used to transform the ingested email content based on
   specific CSS selectors and save it in the `uniform_resource_transform` table.

### Workflow Summary:

1. The system identifies the business need and curates a list of web feeds or
   URLs related to the industry.
2. The feeds are ingested, filtered, and categorized.
3. Using machine learning and automated filters, irrelevant topics are
   discarded.
4. The filtered content is transformed and posted to social media or websites.
5. Analytics and reviews are performed to assess content impact, and the
   strategy is refined for continuous improvement.

This framework helps ensure efficient, automated content management with the
ability to adapt and optimize over time.

### TBD: To up WebUI

```bash
# load the "Console" and other menu/routing utilities plus FHIR Web UI (both are same, just run one)
$ deno run -A ./package.sql.ts | surveilr shell   # option 1 (same as option 2)
$ surveilr shell ./package.sql.ts                 # option 2 (same as option 1)

# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ ../../std/surveilrctl.ts dev
# browse http://localhost:9000/ to see surveilr web UI
# browse http://localhost:9000/dms/info-schema.sql to see DMS-specific schema
```

Once you apply `stateless.sql` you can ignore that files and all content will be
accessed through views or `*.cached` tables in
`resource-surveillance.sqlite.db`. At this point you can rename the SQLite
database file, archive it, use in reporting tools, DBeaver, DataGrip, or any
other SQLite data access tools.

## Automatically reloading SQL when it changes

On sandboxes during development and editing of `.sql` or `.sql.ts` you may want
to automatically re-load the contents into SQLite regularly. Since it can be
time-consuming to re-run the same command in the CLI manually each time a file
changes, you can use _watch mode_ instead.

See: [`surveilrctl.ts`](../../std/surveilrctl.ts).
