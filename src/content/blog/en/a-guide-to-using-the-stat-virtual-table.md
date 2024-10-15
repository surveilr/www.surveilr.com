---
title: "Diagnosing RSSD Size Issues in surveilr shell"
metaTitle: "A Guide To Using the console_table_physical_stat Virtual Table"
description: "Discover how Surveilr's stateful integration and SQL interface help non-technical teams manage, query, and track data effortlessly while ensuring compliance."
author: "Abdulbaasit Seriki"
authorImage: "@/images/blog/user-no-image.avif"
authorImageAlt: "Avatar Description"
pubDate: 2024-15-10
cardImage: "@/images/blog/why-stateful-integration.avif"
cardImageAlt: "RSSD Size Diagnosis"
readTime: 5
tags: ["functions", "size", "RSSD", "virtual tables"]
---

In modern development environments, idempotent scripts play a critical role in maintaining the stability of systems. An idempotent script is designed to produce the same result, no matter how many times it is executed. For example, running an idempotent SQL script multiple times should leave the database unchanged after the first execution. However, a recently discovered bug in `surveilr shell` causes an unexpected increase in the RSSD file sizes when running such scripts multiple times.

This post will walk you through the issue, how we can diagnose it, and how to use a new tool, the `console_table_physical_stat` virtual table, to help identify size differentials in the RSSD file. If you're running into unexplained database bloat when using `surveilr shell`, this is for you.

## The Issue: Growing RSSD Files

Normally, in SQLite, when you run an idempotent script multiple times, the database remains unaffected after the first run. However, in `surveilr shell`, running the same idempotent script repeatedly causes the RSSD file size to increase unnecessarily. The problem worsens with larger RSSD files, resulting in performance bottlenecks and wasted storage space.

Imagine executing the same task over and over, expecting no change, but finding that each iteration makes things worse. If you've encountered this issue, you likely have already seen the dramatic file size increase, but it remains unclear why this is happening. Debugging this bug has been challenging, and we haven’t been able to pinpoint the exact cause.

## Introducing the `console_table_physical_stat` Virtual Table

To help users diagnose and monitor this file size growth, we’ve introduced a new virtual table called `console_table_physical_stat`. This table provides key statistics about your RSSD and allows you to track how your RSSD file size evolves after running scripts.

The virtual table dynamically calculates various physical stats of your database using SQLite pragmas. It offers a clear picture of what’s happening under the hood by presenting key information like:

- Table name
- Size in bytes
- Number of rows and columns
- Page count
- Used pages and freelist pages
- B-tree depth
- Payload and metadata bytes
- And much more...

Armed with this data, you can compare the state of the RSSD before and after executing an idempotent script, making it much easier to see where the problem lies.

## How to Test for RSSD File Size Increases Using `console_table_physical_stat`

To get a clear understanding of the issue and diagnose whether your RSSD file size is unnecessarily increasing, follow these steps:

### Step 1: Check the Initial Size of the RSSD

First, gather information on the initial state of your RSSD file before running any scripts. This will serve as your baseline for comparison.

Run the following command to collect stats on the empty RSSD:

```bash
surveilr shell https://raw.githubusercontent.com/surveilr/www.surveilr.com/refs/heads/main/lib/cookbook/rssd-stats.sqlr
```
Now, export the stats of your RSSD into a JSON file using the virtual table:

```bash
surveilr shell --cmd "SELECT * FROM console_information_schema_table_physical;" > space1.json
```
This command outputs a file space1.json containing the current statistics of your database, such as its size, number of rows, columns, pages, and more. At this point, the database should be empty or minimally affected, depending on its starting state.

### Step 2: Execute an Idempotent Script
Next, execute the idempotent script that should modify the database on the first run but leave it unchanged if run multiple times, for example:

```bash
surveilr shell https://www.surveilr.com/lib/service/diabetes-research-hub/package.sql
```
This script is expected to make changes to the RSSD the first time it runs but remain inactive (and leave the RSSD unchanged) on subsequent executions.

### Step 3: Recheck the Size After Execution

After running the script, regenerate the stats to see if anything has changed:

```bash
surveilr shell https://raw.githubusercontent.com/surveilr/www.surveilr.com/refs/heads/main/lib/cookbook/rssd-stats.sqlr
```
Export the updated stats into a second JSON file:

```bash
surveilr shell --cmd "SELECT * FROM console_information_schema_table_physical;" > space2.json
```
At this point, you should expect some difference between space1.json (before executing the script) and space2.json (after executing the script), as the idempotent script should have made changes to the database on its first run.

### Step 4: Run the Script Again
Now, re-run the idempotent script to check whether executing it a second time affects the RSSD:
1. Run the script again like in step 2.
2. Regenerate the RSSD stats with the same command as before as in step 3.
3. Export the results to `space3.json`.

### Step 5: Compare the Results
Finally, compare the JSON files to see how the RSSD has evolved:

- Compare `space1.json` and `space2.json` to see the difference after running the script for the first time. There should be some differences here since the script made changes to the empty RSSD.
- Compare `space2.json` and `space3.json`. Since the script is idempotent, no differences should be observed between these two files. If there is a difference, it indicates a problem—namely, that `surveilr shell` is increasing the size of the RSSD unnecessarily when the script is executed multiple times.

### Alternative Method: Using the Built-In SQLite Stats Function
If you prefer, you can achieve similar results using a built-in SQLite stats function provided by `surveilr` instead of relying on `.sqlr` files. Here’s how to do it:

**Check Initial Stats**:
```bash
surveilr shell --cmd "SELECT * FROM surveilr_info_schema_table_physical_stat();" > space1.json
```

**Execute Script**:
```bash
surveilr shell https://www.surveilr.com/lib/service/diabetes-research-hub/package.sql
```

**Recheck Stats**:
```bash
surveilr shell --cmd "SELECT * FROM surveilr_info_schema_table_physical_stat();" > space2.json
```

**Compare the Results**:
Compare space1.json and space2.json to see if there are any unnecessary increases in size after running the script multiple times.

## Why This Matters
This new `console_table_physical_stat` virtual table allows you to easily track and diagnose size increases in your RSSD, providing much-needed insight into the performance of your RSSD. By following this method, you can quickly identify any irregularities, pinpoint where the bloat is occurring, and ultimately report to the team to fix the problem.

As we continue to work on a solution to this bug, we encourage you to use this virtual table as a diagnostic tool. If you notice unexpected differences in file sizes after running idempotent scripts, it might be related to this issue, and having the ability to monitor these changes is critical to resolving it.

We hope this guide helps you better understand and diagnose the issue of growing RSSD file sizes in `surveilr shell`. If you have any feedback, questions, or need further assistance, feel free to reach out to our team!