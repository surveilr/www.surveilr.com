# Site Quality Explorer (SQE) Pattern

The **Site Quality Explorer (SQE)** is a `surveilr` pattern designed for
conducting detailed and ongoing audits of website content quality. It helps
analyze how web pages perform across several key SEO factors, providing
actionable insights for improving search engine rankings. SQE integrates with
**`surveilr`**, leveraging its robust ingestion framework to capture and store
web content across multiple sources. It uses **SQLite** and **Full Text Search
(FTS)** to perform efficient queries and generate important SEO metrics.

### Importance of Site Quality Audits?

Regular site quality audits are crucial for maintaining and improving your
site's visibility on search engines. As search engines evolve, they prioritize
different aspects of content quality, usability, and performance. By
continuously auditing site quality, you ensure that content is optimized to meet
search engine guidelines, improve rankings, and capture organic traffic. These
audits can help identify technical issues (like slow load times or broken
links), optimize content for user intent, and ensure compliance with SEO best
practices over time.

### Key Factors of Site Quality that Impact SEO Rankings

1. **Content Relevance and Optimization**: Search engines prioritize content
   that matches user intent and is rich in targeted, well-placed keywords.
2. **Technical SEO**: Page speed, mobile-friendliness, proper use of structured
   data, and clean URL structures all affect rankings.
3. **Backlink Profile**: High-quality, relevant backlinks from authoritative
   sites significantly boost a site's reputation.
4. **Internal Linking and Structure**: Proper internal linking helps distribute
   authority across pages and makes content easier to discover.
5. **User Experience (Core Web Vitals)**: Metrics like Largest Contentful Paint
   (LCP), First Input Delay (FID), and Cumulative Layout Shift (CLS) influence
   how user-friendly a page is, which can impact rankings.

### Why Use `surveilr` and SQLite for Longitudinal Site Quality Audits?

By leveraging **`surveilr`**, engineers can capture and store a wide variety of
content and metadata from web crawls, CMS platforms, and Google Search Console
in a structured **`uniform_resource`** table. This data is then made queryable
using **SQLite** and its **Full Text Search (FTS)** capabilities. **`surveilr`
simplifies the ingestion process by continuously gathering data, while
**SQLite** efficiently processes and indexes this data for longitudinal studies.
This combination provides the following advantages:

- **Data Consistency**: With regular ingestion, content from multiple sources
  can be evaluated consistently over time.
- **Query Flexibility**: Using SQL, engineers can easily design custom queries
  to explore SEO metrics, site performance, and content quality.
- **Scalability and Performance**: SQLite provides lightweight, fast querying
  that is ideal for audits spanning long timeframes.
- **Historical Trend Analysis**: With ongoing data ingestion, longitudinal
  analysis is simple—allowing you to track the decay of content performance, the
  impact of optimizations, and trends in search rankings.

With SQE and `surveilr`, engineers can automate and scale site quality audits,
ensuring comprehensive, time-based insights that lead to better site
optimization and long-term SEO success.

## Ingesting Content Using `surveilr`

The **`surveilr`** platform provides powerful ingestion capabilities, enabling
engineers to collect content from a variety of sources including CSV files,
Google Search Console APIs, and web crawlers. This content is stored in the
**`uniform_resource`** table in a consistent format, and can be made searchable
via **SQLite Full Text Search (FTS)** for further analysis.

### Ingesting Content with `surveilr`

You can use **`surveilr ingest`** commands to pull content from:

- **Content Files**: Use
  [`wget --mirror`](https://gist.github.com/crittermike/fe02c59fed1aeebd0a9697cf7e9f5c0c)
  or [HTTrack](https://www.httrack.com/).
  - Download an entire site to a local directory, building recursively all
    directories, getting HTML, images, and other files from the server to your
    computer where you're running `surveilr`.
  - Use `surveilr ingest files` to load the content into an RSSD.
- **External Site Quality Files**: CSVs or JSON outputs from analytics platforms
  such as Google Analytics or SEO tools.
- **Google Search Console APIs**: Via Capturable Executables (CEs) that automate
  API requests and pull data from Google Search Console.
- **Custom Web Crawlers**: Using CEs written in TypeScript or Python that
  interact with web crawling libraries such as **Puppeteer**, **Playwright**, or
  **Scrapy** to fetch HTML content.

### Supported Formats

`surveilr` supports a variety of content formats for ingestion into the
**`uniform_resource`** table:

- **HTML**: Entire web pages or crawled sites.
- **Markdown**: Text-based content commonly used for blogs and documentation.
- **Frontmatter**: Metadata stored in YAML or JSON format, often used in
  Markdown-based static site generators like Jekyll or Hugo.

All formats are structured into the `uniform_resource` table, enabling uniform
querying and analysis.

### Structured Ingestion into `uniform_resource`

All ingested content is placed into the **`uniform_resource`** table with a
consistent structure. This table includes fields like `uri`, `content`,
`frontmatter`, and other metadata, ensuring that all data is stored in a way
that makes it easily queryable using SQL.

## Full Text Search (FTS) and Structured Queries

Once the content has been ingested and stored in the **`uniform_resource` table,
**SQLite Full Text Search (FTS)** can be created automatically. These FTS tables
enable efficient text searches across content, metadata, and frontmatter,
allowing engineers to perform detailed searches and analyses, such as:

- Keyword searches
- Content quality analysis
- Metadata filtering

This flexibility enables deep analysis of SEO performance, content quality, and
trends in a scalable manner.

## SEO-Focused Content Enhancement Tasks with SQL in SQE

## Automated Content Audits

Automated content audits can be achieved by creating SQL views that analyze
various aspects of content quality. These views will check for key SEO factors
like keyword density, meta tag usage, structured data, and internal links.\
**How**: Create views to assess the presence and correctness of metadata (title,
description), check the keyword density, validate the use of structured data
(e.g., Schema.org), and ensure internal linking between pages. These queries can
run automatically at regular intervals to flag missing or under-optimized
content.

## Ongoing Analysis for Informed Decisions

For ongoing analysis, you can set up scheduled SQL queries that pull data from
your database at regular intervals (daily, weekly, monthly). These queries will
analyze traffic trends, keyword rankings, and user engagement metrics for
decision-making.\
**How**: SQL queries can track changes in page performance by comparing data
over time, such as keyword rankings, impressions, clicks, and traffic. This
enables optimization based on insights into which pages are improving or
declining in performance.

## Page Prioritization

Page prioritization can be done by creating a SQL view that ranks pages based on
their potential to drive traffic growth. This is based on metrics like
impressions, click-through rate (CTR), and average keyword ranking position.\
**How**: Combine traffic and ranking data to calculate an opportunity score for
each page. Pages with high impression counts but low CTR or suboptimal keyword
rankings can be flagged as high-priority pages for optimization.

## Keyword Cannibalization

Keyword cannibalization occurs when multiple pages on the same website are
targeting the same keyword, causing them to compete with each other. This can be
detected using SQL queries that analyze keyword overlap.\
**How**: SQL queries can scan across page content and detect whether multiple
pages are ranking for the same keyword. Joining tables storing keyword data can
identify duplicate keyword targeting and help resolve content overlap.

## Decaying Pages

Decaying pages are those whose performance declines over time. SQL queries can
analyze historical performance data to identify such pages and flag them for
content updates or improvements.\
**How**: SQL queries can track traffic, CTR, and keyword ranking over time to
identify performance drops. By comparing historical data, pages that exhibit
consistent decline can be flagged as decaying.

## Low-Value Pages

Low-value pages are underperforming in terms of traffic, engagement, or
conversion. SQL can identify these pages based on metrics like traffic volume,
bounce rates, and engagement.\
**How**: SQL queries can filter pages with low traffic, minimal engagement, or
poor conversion rates. These pages can then be reviewed for improvement,
removal, or consolidation.

## Opportunity Suggestions

Opportunity suggestions involve using SQL to analyze traffic trends, keyword
performance, and page metrics to suggest optimizations. This could include
targeting new keywords, improving internal linking, or adding structured data.\
**How**: SQL queries can evaluate keyword gaps, analyze page performance, and
track competitor data to provide actionable suggestions for content improvement.

## Duplicate Content Detection

Duplicate content can harm SEO performance as it confuses search engines. SQL
queries can be used to detect similar or identical content across multiple
pages.\
**How**: SQL can analyze page content and compare keywords, metadata, and text.
Pages with excessive duplication can be flagged for content consolidation or
rewriting.

## Content Freshness Tracking

Content freshness plays a significant role in SEO performance. SQL can track the
publication and modification dates of pages and flag outdated content.\
**How**: SQL queries can compare the last modified date of a page with a defined
threshold (e.g., 6 months). Pages that have not been updated in a long time can
be flagged for refresh.

## Internal Linking Optimization

Internal linking affects how search engines crawl and index content. SQL queries
can analyze the internal link structure of a website and identify pages that
lack sufficient inbound links.\
**How**: SQL can calculate the number of inbound and outbound links on each
page. Pages that have few or no internal links can be identified and prioritized
for improved linking strategies.

## Schema Markup Validation

Schema markup helps search engines understand content better. SQL queries can
validate the presence and accuracy of schema markup across the site.\
**How**: SQL queries can scan HTML content stored in the database to check for
the presence of JSON-LD or microdata schema markup. Pages missing structured
data or having incorrect schemas can be flagged for correction.

## Meta Tag Optimization

Meta tags (titles and descriptions) are essential for SEO and click-through
rates. SQL can audit meta tags to ensure uniqueness, proper length, and keyword
optimization.\
**How**: SQL can query meta tags from the database and check for missing,
duplicated, or incorrectly formatted tags. Pages with improper meta tags can be
flagged for optimization.

## Mobile-Friendliness Check

Mobile usability is a ranking factor for search engines. SQL can analyze how
content is rendered across different devices and flag pages with poor mobile
performance.\
**How**: SQL queries can identify whether pages have been optimized for mobile,
such as checking for mobile viewport meta tags or ensuring that critical
rendering paths are not blocked by scripts.

## Social Metadata (Open Graph, Twitter Cards)

Social metadata allows pages to display optimally when shared on platforms like
Facebook or Twitter. SQL can audit pages for proper use of Open Graph and
Twitter Cards.\
**How**: SQL can analyze the presence and accuracy of social metadata tags.
Pages missing social metadata or with improperly configured tags can be flagged
for optimization.

## URL Structure Optimization

Clean and descriptive URLs improve search engine rankings and user experience.
SQL can be used to audit the URL structure of a website and ensure compliance
with SEO best practices.\
**How**: SQL queries can evaluate URL length, query strings, and the use of
readable, descriptive keywords in the URL. URLs with poor structures can be
flagged for revision.

## Crawl Budget Efficiency

Search engines allocate a crawl budget, and it is important to ensure that key
pages are prioritized. SQL can track how often pages are crawled and identify
unnecessary deep links.\
**How**: SQL queries can evaluate page depth (clicks from the homepage) and
crawl frequency to ensure that important pages are indexed properly. Pages that
are too deep in the structure or are not being crawled frequently enough can be
flagged.

## Readability and Content Quality

Readable and well-structured content increases user engagement and SEO
performance. SQL can track readability scores (such as Flesch-Kincaid) to ensure
content quality.\
**How**: SQL queries can analyze content to calculate readability scores based
on sentence structure and word complexity. Pages with poor readability can be
flagged for improvement.

## Security and SSL Audits

Websites using SSL (HTTPS) rank better and are more secure for users. SQL can
ensure that all pages use secure HTTPS connections and check for missing
security headers.\
**How**: SQL queries can scan for pages using HTTP instead of HTTPS or those
missing critical security headers. Pages not using SSL or with incomplete
security measures can be flagged for updates.

## Core Web Vitals Analysis

Core Web Vitals (LCP, FID, CLS) are critical for page experience and SEO
rankings. SQL can track these metrics and identify underperforming pages.\
**How**: SQL queries can analyze Core Web Vitals metrics for each page. Pages
that fail to meet thresholds for Largest Contentful Paint (LCP), First Input
Delay (FID), or Cumulative Layout Shift (CLS) can be flagged for performance
optimization.

## Comprehensive List of SEO Factors for SQLite Tables or Views in SQE

In the **Site Quality Explorer (SQE)** framework, all SEO-related data ingested
and stored in the `uniform_resource` table can be analyzed using SQL queries
that feed into SQLite tables or views. The goal is to monitor the performance of
a website over time and continuously optimize for search engine rankings. Below
is an exhaustive list of key SEO factors that can be represented as **SQLite
tables** or **views**, along with explanations of how these factors can be
calculated using the content stored in the `uniform_resource` table.

The combination of these key SEO factors, ingested into the `uniform_resource`
table, can be used to generate comprehensive **site quality scores** and perform
ongoing audits. By calculating weighted scores for each factor (e.g., keyword
optimization, page speed, backlink quality, etc.), you can produce a **site
health score** that reflects the overall performance of your website in terms of
SEO.

This score can be broken down into multiple components, allowing for granular
insights into where improvements are needed most. Each audit focuses on a
specific aspect of SEO (e.g., keyword optimization, technical SEO, mobile
performance), ensuring that every page is optimized for both search engines and
user experience. Over time, continuous auditing enables effective tracking of
site performance and long-term optimization strategies.

### Keyword Optimization

**Table/View**: Keyword analysis and density.

- **Purpose**: Search engines prioritize content that is relevant and optimized
  for targeted keywords. Keyword density, relevance, and placement (in titles,
  headers, etc.) all impact ranking.
- **Explanation**: The `uniform_resource` table stores the content of a web
  page, including text and metadata. The system can scan for specific keywords
  and calculate keyword density by dividing the number of keyword appearances by
  the total word count. You can also assess keyword placement in critical areas
  like titles, headers, and meta descriptions to optimize for SEO.

### Meta Tags & Structured Data

**Table/View**: Metadata audit (titles, descriptions, Open Graph, schema
markup).

- **Purpose**: Meta tags (titles, descriptions) and structured data (e.g.,
  Schema.org markup, Open Graph tags) play a crucial role in how search engines
  understand a page.
- **Explanation**: Metadata (e.g., title, meta description, Open Graph tags)
  stored in the `uniform_resource` table can be analyzed to ensure that each
  page has unique, properly formatted metadata. You can also evaluate the
  presence and accuracy of structured data (e.g., product information, reviews)
  to boost rich snippets on search engine results pages (SERPs).

### Internal Linking Structure

**Table/View**: Internal linking hierarchy and authority distribution.

- **Purpose**: Internal links help distribute page authority and allow search
  engines to crawl and index pages more effectively.
- **Explanation**: By analyzing `uniform_resource`, you can track the number and
  placement of internal links on each page. Tables or views can be created to
  determine which pages pass the most link authority and whether any pages are
  "orphaned" (lack inbound links), limiting their visibility to search engines.

### Backlink Profile

**Table/View**: Backlink analysis and quality audit.

- **Purpose**: Backlinks from external websites significantly impact a site's
  authority and rankings. High-quality, relevant backlinks are essential for
  off-page SEO.
- **Explanation**: Ingesting backlink data allows the creation of tables that
  analyze the quantity and quality of backlinks, identifying which pages are
  receiving valuable external links. You can track changes in the backlink
  profile over time and flag toxic or low-quality links that could harm the
  website's reputation.

### Page Load Speed and Core Web Vitals

**Table/View**: Page performance audit.

- **Purpose**: Page speed and **Core Web Vitals** (Largest Contentful Paint,
  First Input Delay, Cumulative Layout Shift) are important for both user
  experience and search engine rankings.
- **Explanation**: Using performance metrics captured from page loads (e.g.,
  load time, interaction delay), tables can monitor how quickly pages load and
  identify elements that cause slowdowns. Pages that fall below acceptable
  performance thresholds can be flagged for optimization.

### Mobile-Friendliness

**Table/View**: Mobile performance and responsiveness audit.

- **Purpose**: Mobile-friendliness is a critical ranking factor as more users
  access the web on mobile devices.
- **Explanation**: Content stored in `uniform_resource` includes information on
  how a page renders on different devices. You can create views to analyze the
  performance of mobile versions of pages, checking for responsiveness issues
  and ensuring that mobile-specific best practices (e.g., mobile-friendly
  layout, touch optimization) are followed.

### Content Freshness & Decay

**Table/View**: Content freshness and decay tracking.

- **Purpose**: Search engines favor content that is fresh and regularly updated.
  Over time, content that has decayed in relevance and traffic can hurt
  rankings.
- **Explanation**: By tracking historical data on page performance (e.g.,
  traffic, keyword rankings), you can create tables to flag content that is
  losing its effectiveness or traffic over time. These tables can be used to
  prioritize pages for updates and rewrites.

### Content Depth and Word Count

**Table/View**: Content quality and depth audit.

- **Purpose**: Search engines tend to favor longer, more in-depth content that
  comprehensively covers a topic.
- **Explanation**: You can use data in `uniform_resource` to track the word
  count and overall content depth of each page. Tables can calculate the average
  length of top-performing pages, and comparisons can be made to identify thin
  content (pages with insufficient depth).

### Crawl Efficiency and Indexing

**Table/View**: Crawl and indexing status audit.

- **Purpose**: Search engines allocate a "crawl budget" to websites, and
  ensuring that important pages are crawled and indexed efficiently is crucial.
- **Explanation**: Information in `uniform_resource` can be used to track crawl
  activity and assess whether key pages are being indexed by search engines.
  Views can flag pages that are excessively deep in the site structure or taking
  too long to be indexed.

### Redirect Chains and 404 Errors

**Table/View**: Redirect and error page tracking.

- **Purpose**: Redirect chains and broken links (404 errors) can hurt both user
  experience and SEO performance.
- **Explanation**: By monitoring URL redirects and 404 errors, you can create
  tables to identify and prioritize pages for fixing. Long redirect chains or
  broken links can be flagged, and alternative actions can be suggested, such as
  direct redirection or fixing broken links.

### URL Structure and Canonicalization

**Table/View**: URL optimization and canonical tag audit.

- **Purpose**: Clean, descriptive URLs and proper use of canonical tags help
  search engines understand page hierarchy and prevent duplicate content issues.
- **Explanation**: Data from `uniform_resource` allows you to audit URL
  structures across the site. Tables can track whether pages use canonical tags
  correctly, ensure that URLs are SEO-friendly (e.g., no unnecessary query
  strings or parameters), and flag pages that may create duplicate content
  issues.

### Social Media Metadata (Open Graph, Twitter Cards)

**Table/View**: Social media metadata audit.

- **Purpose**: Proper use of Open Graph and Twitter Cards ensures that content
  is optimized for sharing across social platforms, which can drive traffic and
  engagement.
- **Explanation**: The `uniform_resource` table can store metadata related to
  social media, such as Open Graph tags or Twitter Card data. Tables can analyze
  whether social metadata is present and optimized, ensuring that shared content
  appears correctly on social platforms.

### Multi-language SEO (hreflang Tags)

**Table/View**: Multi-language optimization and hreflang audit.

- **Purpose**: For international websites, proper hreflang tag usage ensures
  that search engines display the correct language and region versions of pages.
- **Explanation**: By capturing hreflang data in the `uniform_resource` table,
  you can create views to verify that multi-language versions of content are
  correctly tagged and indexed. Pages missing hreflang annotations can be
  flagged, and tables can track the relationship between language versions of
  the same content.

### Content Readability and Sentiment

**Table/View**: Readability score and sentiment analysis.

- **Purpose**: Content that is clear, readable, and aligns with user sentiment
  performs better in terms of user engagement and rankings.
- **Explanation**: Using natural language processing (NLP), you can assess the
  readability (e.g., Flesch-Kincaid scores) of content stored in
  `uniform_resource`. Sentiment analysis can help flag pages with negative or
  neutral sentiment for improvement. These views allow you to monitor content
  quality beyond keywords and technical SEO factors.

### Duplicate Content Detection

**Table/View**: Duplicate content and content cannibalization tracking.

- **Purpose**: Duplicate content can confuse search engines, lead to lower
  rankings, and hurt overall site performance. Content cannibalization happens
  when multiple pages target the same keyword and compete with each other.
- **Explanation**: Content from `uniform_resource` can be compared across pages
  to detect duplicate content or excessive keyword overlap. Tables can be
  created to analyze whether multiple pages are targeting the same search
  queries, and recommendations can be made to consolidate or differentiate
  content.

### SSL and Security Audits

**Table/View**: SSL certificate and security header audit.

- **Purpose**: A secure website using SSL encryption (HTTPS) and proper security
  headers (e.g., HSTS) is a key ranking factor and also critical for user trust.
- **Explanation**: Tables can track which pages use HTTPS and check the presence
  of security headers. Pages missing SSL certificates or using insecure HTTP can
  be flagged for correction, as this could negatively impact both SEO and user
  security.

### Integration Steps  

This document outlines the setup and usage instructions for the **Site Quality Explorer** project. Follow the steps below to ensure proper integration and utilization.  

---

## Directory Structure  

The project directory structure should resemble the following:  

```bash
site-quality-explorer
├── content
│   ├── site-quality-controls
│   ├── website-resources
├── package.sql.ts
├── stateful.sql.ts
└── stateless.sql
```

### File and Folder Details

#### `stateless.sql`
- Contains scripts for creating database views.
- These views define methods for extracting and presenting controls, policies, and SEO analysis data.

#### `stateful.sql`
- Creates tables for caching data extracted by the views.
- This improves performance by reducing the need to recompute data dynamically.

#### `package.sql.ts`
- Serves as the entry point for loading database objects and Web UI content.

#### `site-quality-controls`
- Contains editable markdown data for site quality controls.
- Each site quality control is organized into a separate folder, which includes a `control.md` file providing detailed and editable information about that specific control.
- Within each control folder, there is a subfolder named policies that stores the associated `policies` as markdown files.

#### `website-resources`
- Stores downloaded website resources for analysis.
- The process for downloading these resources is outlined in the subsequent sections of this documentation.

To download website resources and ingest the data into a SQLite database, run the following command:  

```bash
# Download website resources and create resource-surveillance.sqlite.db
$ deno run -A eg.surveilr.com-prepare.ts resourceName="surveilr.com" rssdPath="resource-surveillance.sqlite.db"
```

#### Parameters  
- **`rssdPath`**: Specifies the destination path and name of the SQLite database file.  
- **`resourceName`**: Indicates the resource or website to be downloaded.  
 
The `eg.surveilr.com-prepare.ts` script:  
1. Installs the necessary database extensions.  
2. Downloads website resources using the `wget --mirror` library.  

#### Post-Execution  
- Website resources are saved in the `content/website-resources` folder.  
- A SQLite database (`resource-surveillance.sqlite.db`) is created and populated with the ingested data for further analysis.  

After ingestion, your directory should look like this:

```bash
site-quality-explorer
├── content
│   ├── site-quality-controls
│   ├── website-resources
├── package.sql.ts
├── stateful.sql.ts
├── stateless.sql
└── resource-surveillance.sqlite.db
```

### Post-Ingestion Notes  
- The `surveilr` tool is no longer required after ingestion.  
- You can rename or archive the `resource-surveillance.sqlite.db` file and use it with tools like **DBeaver**, **DataGrip**, or any SQLite-compatible application.  

### Starting the Web UI  

##### Load Database Objects and Utilities:  

```bash
deno run -A ./package.sql.ts | surveilr shell   # Option 1  
surveilr shell ./package.sql.ts                 # Option 2  
```

This enables automatic reloading for `package.sql.ts`, making it easier to apply changes without restarting the application.  

```bash
../../std/surveilrctl.ts dev
```

#### Access the Application  

- **Surveilr Web UI**: [http://localhost:9000/](http://localhost:9000/)  
- Explore the user interface and interact with the ingested data.  

This setup also enables developers to test and debug changes to database objects or web UI components in real-time. 