**Content Assembler Multi-modal Scored Links Aggregator (MMSLA)**

Across the internet, a massive amount of content is shared every day. Curators,
authors, and everyday users share links across various digital modes—digital
periodicals like email newsletters, news websites, professional networks (e.g.,
LinkedIn), social media platforms (e.g., Twitter, Instagram, Facebook), personal
emails, and more. Content creation is often dwarfed by the sharing of content,
highlighting a plentiful stream of high-quality content already available
through different channels.

However, these links are scattered across different modes of communication.
Despite the abundance of content being shared, it is fragmented and spread
across different networks, platforms, and newsletters, making it difficult to
fully leverage their potential. Herein lies the opportunity for a unique content
aggregator.

**Current Sharing Patterns:**

1. **Professional Networks**: On platforms like LinkedIn, users share posts and
   comments, which often include hyperlinks. It is these hyperlinks—not the
   accompanying post content—that form the real value for link aggregation and
   scoring.

2. **Social Media Networks**: On platforms like Facebook and Instagram, many
   posts include links to external content. Aggregating these links rather than
   focusing on the social commentary around them offers an opportunity to curate
   high-quality external resources.

3. **News Websites & Periodicals**: News organizations often distribute their
   links through a combination of professional networking platforms and social
   media, but email newsletters remain a primary vehicle for sharing content—as
   do RSS feeds, which continue to serve as a significant syndication medium for
   content aggregation.

4. **Thought Leadership**: Authors and influencers often share significant
   content through various modes, including LinkedIn, Twitter, and especially
   email newsletters (digital periodicals).

What becomes evident is that links to valuable content are shared across
multiple modes (i.e., "multi-modal" sharing). Aggregating these links could
allow us to create a vibrant link-sharing community—without relying entirely on
manual submissions by users.

**The MMSLA Vision:**

The **Multi-modal Scored Links Aggregator (MMSLA)** aims to gather links from
diverse sources—including RSS feeds, email newsletters, LinkedIn, Twitter, and
more—to build a continuously updated content hub. Instead of depending on user
submissions for links, MMSLA pulls from a wide array of sources, automatically
enriching the collection of relevant, high-quality content.

**How It Works:**

1. **Data Ingestion & Aggregation**: MMSLA ingests links from various modes into
   one of two systems:
   - **MiniFlux (PostgreSQL)**: For aggregating links from RSS feeds.
   - **SQLite (via `surveilr`)**: For aggregating email newsletters and other
     less structured content.

2. **Canonical URL Normalization**: As links are ingested, MMSLA normalizes them
   to find the "final" clean canonical URL. This process helps avoid redundancy
   and identifies when different sources share the same piece of content.

3. **Multi-source Scoring (Upvoting)**: When identical or similar content
   appears across different modes (e.g., email newsletters, LinkedIn, Facebook),
   MMSLA interprets this as an implicit "upvote." The more times a piece of
   content is shared across different modes, the higher it is ranked. MMSLA
   leverages technologies such as AI, NLP, and summarization to identify
   relationships between shared links, mapping these connections into graphs
   that trace their sources.

4. **Ranking & Display**: These aggregated links are then scored and ranked,
   similar to the concept of "upvotes" on community-driven platforms like Hacker
   News. This creates a dynamic, automatically curated content experience that
   appears fresh, lively, and regularly updated.

**End Goal:**

The **ultimate goal** of MMSLA is to foster a thriving, active link-sharing
community that mimics the style and engagement of platforms like Hacker News.
The difference is that MMSLA can operate effectively without requiring thousands
of users manually submitting links. Instead, once a link is shared
anywhere—especially through popular mediums like email newsletters or RSS
feeds—it becomes content for our platform.

By pulling links from many different sources and scoring them based on the
breadth of their reach, MMSLA helps position any link-sharing community as a
continually updated, high-quality content hub, even if user-generated
submissions are limited.

The **main problem** we must solve is making any link sharing system appear
lively, active, and rich in content—even without a large base of users
submitting links. MMSLA achieves this by aggregating links shared across the
internet, scoring them, and presenting them in an engaging manner that drives
readership and builds a growing audience.
