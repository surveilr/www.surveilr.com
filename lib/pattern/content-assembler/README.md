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
   `uniform_resource` table in the resource surveillance database. Specifically:

   - Email content is added to the content field of the `uniform_resource`
     table.
   - An entry is also created for the ingest_imap_acct_folder_id field in the
     `uniform_resource` table to establish the link between the ingested email
     content and its folder.
   - Additionally, information about the email’s folder is stored in the
     `ur_ingest_session_imap_acct_folder` table, and individual email data is
     added to the `ur_ingest_session_imap_acct_folder_message` table.

     ###### Related Table Details:
     - `ur_ingest_session_imap_acct_folder` table stores folder details of the
       ingested emails, including:
       - `ur_ingest_session_imap_acct_folder_id`: Primary key to uniquely
         identify each folder entry.
       - `ingest_session_id` and ingest_account_id: Link the folder to specific
         ingest sessions and accounts.
       - `folder_name`: Name of the email folder (e.g., "Inbox").
       - `elaboration`: Optional JSON field to store extra details about the
         folder.
       - `created_at` and `updated_at`: Timestamps for tracking when the folder
         entry was created and last updated.

     - `ur_ingest_session_imap_acct_folder_message` table captures detailed
       message data from each email within a folder:

       - `ur_ingest_session_imap_acct_folder_message_id`: Primary key for unique
         identification of each message.
       - `ingest_session_id`: Links each message to its ingest session.
       - `ingest_imap_acct_folder_id`: Foreign key linking each message to its
         folder in `ur_ingest_session_imap_acct_folder`.
       - `uniform_resource_id`: Links the message to a corresponding entry in
         `uniform_resource`.
       - `message_id`, `subject`, `from`, `cc`, `bcc`, and `status`: Fields to
         store details such as message ID, subject, sender, CC, BCC, and status
         of the email.
       - `date`: Date of the email message.
       - `email_references`: JSON array of email references related to the
         message.

2. **Transform and Save Email Content**:
   ```bash
   surveilr orchestrate transform-html --css-select 'email-anchors:a'
   ```

This command transforms email content stored in the `uniform_resource` table,
selecting specific elements based on CSS selectors (in this case,
email-anchors:a). The transformation process extracts and refines portions of
the original email data, which is then saved in the `uniform_resource_transform`
table.

The transformed data in `uniform_resource_transform` serves as a processed
version of the original, enabling efficient retrieval and further analysis of
specific content elements, such as URLs or images, while maintaining a link to
the source email.

###### Table Details: uniform_resource_transform

The `uniform_resource_transform` table holds each transformed email’s processed
content, linked back to its original data in `uniform_resource`. Key fields in
this table include:

- `uniform_resource_transform_id`: Unique identifier for each transformation
  record, serving as the primary key.
- `uniform_resource_id`: Foreign key linking the transformed content to the
  original entry in `uniform_resource`, ensuring a traceable connection between
  raw and transformed data.
- `uri`: Stores the URI associated with the transformed content, enabling
  reference to specific resources or sections within an email.
- `content_digest`: A digest or hash of the transformed content to track unique
  transformations and detect duplicates.
- `content`: Holds the transformed content itself, stored as a BLOB. This
  content is extracted and processed based on the CSS selectors specified during
  transformation.
- `nature`: An optional field to classify the content type (e.g., “text”,
  “html”, “image”), enabling refined filtering or categorization of transformed
  resources.
- `size_bytes`: Indicates the size of the transformed content in bytes, aiding
  in managing storage and retrieval performance.

- `elaboration`: A JSON field to capture additional metadata or notes about the
  transformation process, such as processing details or criteria applied. This
  field accepts only valid JSON data or remains empty if unused.

### Additional Tables Created for Processing Email Links

After transforming the email content, a series of tables is generated to filter
and categorize specific types of anchor links commonly found in email
newsletters, such as subscription management or general content links.

1. **Flattened Email Anchors Table** (ur_transform_html_flattened_email_anchor)
   **Purpose**: This table is used to extract and flatten all anchor tags found
   within the transformed email content, allowing easy access to each URL and
   its accompanying text.

   _**Fields**_:

- `uniform_resource_transform_id` and `uniform_resource_id`: Link back to the
  source of the transformed content.
- `anchor`: Contains the URL from each anchor tag.
- `anchor_text`: The text displayed for the link, which often indicates its
  purpose (e.g., "Unsubscribe" or "View Online").

  This flat structure simplifies the process of applying filters and
  categorizing each link by providing a clean list of anchors extracted from the
  HTML.

2. **Filtered Subscription Management Anchors Table**
   (ur_transform_html_email_anchor_subscription_filter)

   **Purpose**: This table categorizes anchors based on keywords associated with
   common newsletter actions, such as unsubscribing, managing preferences, or
   updating subscription settings. By categorizing links in this way, specific
   actions (e.g., "Unsubscribe") can be quickly identified and processed.

   **Categories**:

   - Unsubscribe: Captures links with keywords like "unsubscribe" or
     "list-unsubscribe."
   - Optout: Recognizes links labeled "optout" or "opt-out."
   - Additional categories include Preferences, Remove, Manage, Email-settings,
     Subscribe, and mailto, covering various newsletter management options.

   **Fields**:

   - `uniform_resource_transform_id` and `uniform_resource_id`: Link back to the
     original email content.
   - `anchor`: Stores the URL within each anchor tag.
   - `anchor_type`: Categorizes each link based on its identified purpose.
   - `anchor_text`: Provides the display text of the categorized link for
     further context.

3. **General Email Anchors Table** (ur_transform_html_email_anchor)

   **Purpose**: The final table isolates all non-subscription-related links,
   capturing only general content links for later analysis. This allows a
   distinction between subscription management links and other types of links
   found in email content.

   **Fields**:

   - `uniform_resource_transform_id` and `uniform_resource_id`: Reference the
     source of the transformed content.
   - `anchor`: Contains the URL for each non-subscription link.
   - `anchor_text`: Provides the display text for each general link.

   By excluding subscription management links, this table presents a filtered
   view of links directly related to the content of the email, such as links to
   articles or promotional content.

### To up WebUI

```bash
# load the "Console" and other menu/routing utilities plus FHIR Web UI (both are same, just run one)
$ deno run -A ./package.sql.ts | surveilr shell   # option 1 (same as option 2)
$ surveilr shell ./package.sql.ts    
$ SURVEILR_SQLPKG=~/.sqlpkg surveilr shell ./package.sql.ts             # option 2 (same as option 1)

# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ SQLPAGE_SITE_PREFIX=/lib/pattern/content-assembler ../../std/surveilrctl.ts dev
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

## How to Run the Tests

To execute test and ensure that `surveilr` is functioning correctly:

1. Run the tests using Deno:

   ```bash
   deno test -A  # Executes test
   ```

This process will create an 'assurance' folder, where you can find the files
related to the test, including the database and ingestion folder

The `-A` flag provides all necessary permissions for the tests to run, including
file system access and network permissions.
