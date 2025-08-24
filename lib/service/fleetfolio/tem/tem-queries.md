# SQL vs. Datalog (Google Mangle) Perspective

This is a quick analysis of [Mangle/Datalog](https://github.com/google/mangle) for use in threat exposure management (TEM).

While SQL is rooted in relational algebra, Datalog (and its extension, Mangle) is grounded in declarative logic programming. This is more than a syntactical difference; it's a fundamental shift in how you think about data and queries.

* Recursive Queries as a First-Class Citizen: While modern SQL has recursive CTEs (Common Table Expressions), they can often feel like an add-on, leading to verbose and sometimes awkward syntax. In Datalog, recursion is a native and elegant part of the language's core design. This is particularly powerful for problems involving transitive relationships, such as analyzing a dependency tree, mapping a hierarchical organizational structure, or traversing a knowledge graph. The logic is expressed simply and directly, without the need for complex procedural-like steps.
* Implicit Joins and Unification: SQL requires explicit `JOIN` clauses, which can become unwieldy in complex queries involving many tables. Datalog's syntax uses unification, where variables are automatically matched across different relations. This leads to a cleaner, more concise representation of complex joins. For instance, in Mangle's rule `projects_with_vulnerable_log4j(P) :- projects(P), contains_jar(P, "log4j"), jar_version_vulnerable("log4j").`, the variable `P` implicitly connects all three predicates, representing a join without a single `JOIN` keyword. This makes queries easier to read and reason about, especially for non-database experts.
* Focus on Business Logic, Not Data Retrieval: Datalog and Mangle's ability to define and reuse "rules" or "views" goes beyond what SQL views offer. A Datalog rule is not just a stored query; it's a piece of logical deduction. This allows developers to separate complex business logic from the raw data itself. You can create a library of rules that represent your organization's domain knowledge—for example, a rule for "employee is authorized to access X" or "this component is vulnerable"—and then simply query that rule without worrying about the underlying joins or data sources.

Despite its perceived verbosity and limitations in recursion, SQL's long history and pervasive use give it profound, often unappreciated, advantages that are difficult for new languages to overcome.

* The Query Optimizer is a Supercomputer: SQL's greatest and most under-the-radar strength is not the language itself, but the decades of engineering investment poured into its query optimizers. A SQL database's query planner is a marvel of computer science, capable of re-ordering operations, choosing the most efficient join algorithms (e.g., hash joins, sort-merge joins), and leveraging indexes to execute even the most poorly written queries with surprising efficiency. A Datalog engine, especially a new one like Mangle, does not have this same level of mature, battle-tested optimization. This means that while a Datalog query may be *logically* cleaner, its performance could be unpredictable, or even abysmal, on large, real-world datasets. The performance of a new Datalog query often relies on the user's deep understanding of its execution model, rather than on a mature optimizer.
* The "One-Size-Fits-Most" Pragmatism: SQL, unlike Datalog, is a Turing-complete language when you consider stored procedures, triggers, and user-defined functions (UDFs) available in most modern implementations. While this is often seen as a weakness (mixing procedural and declarative code), it's also a pragmatic strength. It means you can often solve a problem completely within the database, without leaving the database's execution environment. SQL's vast ecosystem of built-in functions, data types, and tooling for everything from geospatial data to JSON, makes it a versatile workhorse that doesn't force a strict adherence to pure logic. It is a messy but practical solution for a messy world.
* The Impedance Mismatch in Reverse: The object-relational impedance mismatch is a well-known problem when trying to map a relational database to an object-oriented programming language. However, a similar mismatch can occur when trying to fit a logical language like Datalog into an imperative programming paradigm. While Mangle is an embedded Go library, integrating its logical, bottom-up-evaluated results with a typical top-down, step-by-step imperative application flow requires careful thought. In contrast, SQL's tabular output is a simple, universally understood data structure that maps cleanly to objects, lists, and dataframes in virtually any programming language. It is a simple contract that every developer understands.

While Mangle and Datalog represent an elegant, powerful logical paradigm for complex reasoning, SQL remains a monument to pragmatic engineering and computational efficiency. The true test for Mangle won't be whether it can express recursive queries more cleanly, but whether it can build an ecosystem and an optimizer that rivals the decades of development that have made SQL the de facto standard for data access, regardless of its logical imperfections.

For analyzing a large collection of evidence, the choice between SQL and Mangle depends on the nature of the questions you're asking. SQL is a better fit for traditional data processing and aggregation, while Mangle excels at deep, interconnected logical reasoning.

## When to Use SQL

You should use SQL when your primary goal is aggregation, filtering, and reporting on a large, structured dataset. Think of SQL as the ideal tool for summarizing and counting what you've collected.

* Quantitative Analysis: SQL is unparalleled for tasks like counting the number of files of a certain type, calculating the average size of log entries, or finding the most common IP addresses in a log file. Its built-in aggregate functions (`COUNT`, `SUM`, `AVG`) and the `GROUP BY` clause are highly optimized for this kind of work, making it fast and efficient for large-scale reporting.
* Simple Joins and Filtering: If your queries involve linking tables based on a simple, direct relationship (e.g., finding the user associated with a specific file hash), SQL is straightforward and very performant. Its mature query optimizers can handle these operations with incredible speed and scalability, leveraging indexes to quickly retrieve data.
* Transactional Workloads: While your evidence collection might be static, if you were to build a system where evidence is continuously being added, updated, or deleted, SQL's ACID (Atomicity, Consistency, Isolation, Durability) properties and transactional control are essential for maintaining data integrity.

## When to Use Mangle (Datalog)

You should use Mangle when your problem is about deductive reasoning, security analysis, or traversing complex, recursive relationships. Mangle is the superior choice for asking "why" and "how" questions that go beyond simple data retrieval.

* Recursive Queries and Transitive Closure: Mangle's strength lies in its native handling of recursion. This is crucial for evidence analysis that requires exploring relationships of unknown depth. For instance, you could model "A depends on B" and then use a single recursive rule to find everything a vulnerable file depends on, including its dependencies' dependencies. This would be cumbersome and less readable in SQL's recursive CTEs.
* Modeling Rules and Policies: Mangle allows you to define reusable logical rules that represent your organization's security or operational policies. You can write a rule like, "a file is suspicious if it was modified by a user with a specific role and it's located in a critical directory." You can then query for all suspicious files without rewriting the complex logic. This makes your analysis rules clear, shareable, and separate from the raw data.
* Discovering Unobvious Connections: By representing your evidence as facts and rules, Mangle can automatically deduce new relationships that weren't explicitly stated in the original data. For example, if you have a rule that a "user is an admin if they belong to group 'X'" and another rule that "group 'X' has access to a secure server," Mangle can deduce that the user has access to the server, even if that fact isn't directly recorded. This makes it a powerful tool for discovering hidden vulnerabilities and connections.

When analyzing evidence, you would use SQL for direct, well-defined queries and Mangle for deeper, logical reasoning across interconnected data.

### Mangle Integration with SQL Databases

To use data from an SQLite database with Mangle, you must first extract the relevant information into a format Mangle can understand: facts. A fact is a simple statement of a relationship. For example, `file_size(‘C:\\Users\\Bob\\report.docx’, 1024)`.
approach is to write a script in a language like Python or Go that connects to the SQLite database, runs queries, and writes the results to a text file that Mangle can ingest.

Let's assume your SQLite database has two tables:

* `files`: `id`, `path`, `size`, `owner_id`
* `users`: `id`, `name`, `group_id`

```sql
SELECT 'file_size("' || path || '", ' || size ')' as fact FROM files;
```

You could generate a file called `file_facts.txt` using `sqlite3`:

```
file_size("C:\Users\Bob\report.docx", 1024).
file_size("C:\Windows\System32\config.ini", 512).
```

You would then load this file into your Mangle program using its `FromTextFile` function.

### Scenario: Finding Large Configuration Files

```sql
SELECT path, size
FROM files
WHERE path LIKE '%.ini' AND size > 102400; -- 100 KB = 102400 bytes
```

> Why Mangle is Not Ideal Here: While you could express this in Mangle, it would be more verbose and offer no significant advantage. The core problem doesn't require complex logic or recursive reasoning. You'd need a rule to define "large config files" and a query to find them.

```mangle
# Mangle rule for large config files
is_large_config_file(Path, Size) :- file_size(Path, Size), builtin.endsWith(Path, ".ini"), builtin.gt(Size, 102400).

# Mangle query to find them
? is_large_config_file(Path, Size).
```

### Scenario: Tracing a Vulnerability in a Dependency Chain

Mangle's recursive rules are the perfect tool to model and solve this.

```mangle
file_uses_library("app.exe", "lib_B.dll").
file_uses_library("lib_B.dll", "lib_A.dll").
file_uses_library("website.html", "script.js").
file_uses_library("script.js", "lib_A.dll").
```

Then, you define a single, elegant recursive rule in Mangle:

```mangle
# A file is vulnerable if it uses a vulnerable library (base case).
vulnerable_file(File) :- file_uses_library(File, VulnerableLib), is_vulnerable_library(VulnerableLib).

# A file is vulnerable if it uses another file that is itself vulnerable (recursive case).
vulnerable_file(File) :- file_uses_library(File, UsedFile), vulnerable_file(UsedFile).

# Fact about the known vulnerable library
is_vulnerable_library("lib_A.dll").

# Query to find all vulnerable files
? vulnerable_file(File).
```

> Why SQL is Not Ideal Here: While possible with recursive CTEs, the SQL query becomes much more complex and less intuitive. You would need to define a `WITH RECURSIVE` block that joins a table with itself, which can be hard to read and debug for developers unfamiliar with this pattern.

To convert your pen-test data from SQLite into Mangle facts, you'll use SQL `SELECT` queries to extract and format the data. This approach keeps your data management in a single database while using SQL's power to prepare the data for Mangle's logical reasoning. You won't be writing Mangle rules *in* SQL, but rather using SQL to generate the text files Mangle needs.

### Converting Pen Test RSSD Tables to Mangle Facts

First, assume you've already imported the raw data from your various tools into an SQLite database (via `surveilr` in an RSSD). For each tool's output, you'll run an SQL query with string concatenation to format the results directly as Mangle facts. You can then save the output of these queries to a file that Mangle can ingest.

General Process:

1. Run a `SELECT` statement on your SQLite table.
2. Use the `||` operator to concatenate strings and columns into the Mangle fact format: `predicate("string", value)`.
3. Redirect the query's output to a text file.

Let's look at examples for key tools, assuming each tool's output has been placed into its own table (e.g., `subfinder`, `dnsx`, etc.).

#### Subfinder

* Table: `subfinder` with columns `host`, `ip_address`.
* SQL Query:

```sql
SELECT 'subdomain_resolution("' || host || '", "' || ip_address || '").'
FROM subfinder;
```

#### dnsx

* Table: `dnsx` with columns `host`, `record_type`, `record_value`.
* SQL Query:

```sql
SELECT 'dns_record("' || host || '", "' || record_type || '", "' || record_value || '").'
FROM dnsx;
```

#### httpx

* Table: `httpx` with columns `url`, `status_code`, `title`.
* SQL Query:

```sql
-- For general HTTP responses
SELECT 'http_response("' || url || '", ' || status_code || ', "' || replace(title, '"', '\"') || '").'
FROM httpx;

-- Assuming you have a separate table for technologies
SELECT 'http_tech("' || url || '", "' || technology || '").'
FROM httpx_techs;
```

#### Naabu

* Table: `naabu` with columns `host`, `port`, `protocol`.
* SQL Query:

```sql
SELECT 'open_port("' || host || '", ' || port || ', "' || protocol || '").'
FROM naabu;
```

#### Nmap

* Table: `nmap` with columns `host`, `port`, `service_name`, `service_version`.
* SQL Query:

```sql
SELECT 'nmap_service("' || host || '", ' || port || ', "' || service_name || '", "' || service_version || '").'
FROM nmap;
```

### Defining Mangle Rules for Threat Assessment

Once you have your `facts.mangle` file, your focus shifts entirely to Mangle's logical rules. These rules combine the facts from your various pen-testing tools to deduce new insights, a task SQL is not well-suited for. Remember: Mangle variables start with an uppercase letter (e.g., `Host`, `Port`), while constants start with a lowercase letter or are quoted strings/numbers (e.g., `"high"`, `80`).

Example 1: Identifying High-Severity Vulnerabilities on Exposed Services 🚨

* Problem: Find hosts with an open port and a high-severity vulnerability reported by Nuclei.
* Why Mangle is Better: This requires correlating data across multiple sources and checking for a specific logical condition (open port AND high severity). SQL would require a complex `JOIN` and `WHERE` clause, and it can't express the concept of a `high-severity-vulnerability` as a reusable rule.

```
# Mangle facts generated by SQL
# open_port("example.com", 80, "tcp").
# vulnerability_finding("example.com", "http://example.com/login", "cve-2023-1234", "high", "Auth bypass").

# Mangle Rule to correlate the data
exposed_high_severity_vuln(Host, Port, Vuln) :-
    open_port(Host, Port, _),
    vulnerability_finding(Host, _, _, "high", Vuln).

# Query to find all such threats
? exposed_high_severity_vuln(Host, Port, Vuln).
```

Example 2: Tracing Outdated Web Technologies 🕰️

* Problem: Pinpoint public-facing web applications using outdated technology versions.
* Why Mangle is Better: You can define a list of outdated versions as facts and create a simple rule to check against them. This is a clear separation of data (the outdated versions) from the logic (the rule).

```
# Mangle facts from your SQL queries
# whatweb_finding("https://blog.example.com", "WordPress", "5.8.0").

# Manually add facts about known outdated versions
known_outdated_tech("WordPress", "5.8.0").

# Mangle Rule to correlate the data
outdated_public_web_tech(URL, Tech, Version) :-
    whatweb_finding(URL, Tech, Version),
    known_outdated_tech(Tech, Version).

# Query to find all outdated assets
? outdated_public_web_tech(URL, Tech, Version).
```

Example 3: Finding Exposed Internal Services 🕵️

* Problem: Discover public subdomains that resolve to internal IP addresses.
* Why Mangle is Better: This requires checking if an IP from one data source falls into a pre-defined range of internal IPs. Mangle can express this as a logical relationship without complex SQL `BETWEEN` or `LIKE` clauses that are brittle and hard to read.

```
# Mangle facts from your SQL queries
# subdomain_resolution("dev.example.com", "10.0.0.10").
# open_port("10.0.0.10", 22, "tcp").

# Define your internal IP ranges as facts
internal_ip_range("10.0.0.0/8").

# Mangle Rules
exposed_internal_asset(Subdomain, IP, Port) :-
    subdomain_resolution(Subdomain, IP),
    open_port(IP, Port, _),
    builtin.inCIDR(IP, "10.0.0.0/8").

# Query to find all such exposures
? exposed_internal_asset(Subdomain, IP, Port).
```

Example 4: Mismatched TLS Certificates (Potential Phishing/MITM or Misconfiguration) 🛡️

* Problem: Find public-facing hosts where the TLS certificate's Common Name (CN) or Subject Alternative Names (SANs) don't match the host's primary DNS record or the URL it's being accessed by.
* Logic:
  1. There's an HTTP/S service (`http_response`).
  2. TLS certificate information is available (`tls_cert_cn`, `tls_cert_san`).
  3. The certificate's identity (CN/SAN) does not match the observed hostname/URL.

```mangle
# facts.mangle
# http_response("https://badcert.com", 200, "Fake Site").
# tls_cert_cn("badcert.com", "valid-site.com").
# dns_record("badcert.com", "A", "192.0.2.1").

# Mangle Rules

# Rule 1: A host has an HTTP service with a specific CN
host_has_cert_cn(Host, CN) :-
    http_response(URL, _, _),
    builtin.contains(URL, Host), # Simplified URL to Host extraction
    tls_cert_cn(Host, CN).

# Rule 2: A host has an HTTP service with a specific SAN
host_has_cert_san(Host, SAN) :-
    http_response(URL, _, _),
    builtin.contains(URL, Host),
    tls_cert_san(Host, SAN).

# Rule 3: Find mismatched CN (where host in URL doesn't match cert's CN)
# builtin.extractHost(URL) would be needed for a more robust solution if Mangle provides it
mismatched_cert_cn(URL, Host, CertCN) :-
    http_response(URL, _, _),
    host_has_cert_cn(Host, CertCN),
    builtin.notEquals(Host, CertCN). # Simplified: direct comparison of host string vs CN

# Query for mismatched certs
? mismatched_cert_cn(URL, Host, CertCN).
```

Example 5: Correlating Nmap Service Versions with Nuclei Vulnerabilities 🔗

* Problem: Find specific Nmap-identified services (e.g., "Apache httpd 2.4.x") that have known vulnerabilities detected by Nuclei. This helps confirm and prioritize vulnerabilities.
* Logic:
  1. Nmap found a service with a specific version (`nmap_service`).
  2. Nuclei reported a vulnerability related to that host and potentially that service/version (`vulnerability_finding`).

```mangle
# facts.mangle
# nmap_service("webserver.example.com", 80, "http", "Apache httpd 2.4.52").
# vulnerability_finding("webserver.example.com", "http://webserver.example.com/", "apache-cve-2023-5678", "critical", "Apache RCE").

# Mangle Rules

# Rule: Connect Nmap service versions to Nuclei findings
nmap_nuclei_correlation(Host, Port, Service, Version, TemplateID, VulnName) :-
    nmap_service(Host, Port, Service, Version),
    vulnerability_finding(Host, _, TemplateID, Severity, VulnName),
    builtin.contains(VulnName, Service), # Check if the vulnerability name mentions the service
    builtin.contains(VulnName, Version). # Check if the vulnerability name mentions the version (simplistic)

# Query for these correlations
? nmap_nuclei_correlation(Host, Port, Service, Version, TemplateID, VulnName).
```

## Conclusion

This approach empowers you to:

* Unify Data: Treat all your pen-test outputs as a single, cohesive dataset.
* Express Complex Logic Clearly: Define what a "threat" or "misconfiguration" means in a way that's easy to read and understand, even for non-experts.
* Automate Deductions: Mangle will automatically find all instances that satisfy your rules, uncovering patterns and relationships you might miss with manual analysis or simple SQL queries.
* Iterate and Refine: As you learn more about potential threats, you can easily add, modify, or remove Mangle rules without changing how your data is collected or stored.

Start small, focus on one tool at a time for fact generation, and then build your Mangle rules incrementally. Happy hunting\! 🕵️‍♀️
