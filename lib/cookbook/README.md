# Surveilr Cookbook

Welcome to the `surveilr` Cookbook, your technical guide for leveraging SQLite
and SQL commands within the `surveilr` platform. This cookbook contains a
collection of reusable SQL recipes that streamline various data tasks, enabling
users to query, transform, and automate workflows within `surveilr`.

## Purpose of a Technical Cookbook

In software development, a technical cookbook provides a set of instructions, or
"recipes", to solve specific problems or perform routine tasks efficiently.
These recipes are designed to be reusable, adaptable, and often focus on
simplifying complex tasks into manageable steps.

In the context of `surveilr`, our recipes revolve around the use of SQLite,
executed via `surveilr shell` or `surveilr orchestrate` commands. Occasionally,
you may also run these recipes in a local `sqlite3` shell for quick testing or
development purposes.

## Overview of the Surveilr Cookbook

The `surveilr` Cookbook is designed to save you time and effort by providing
ready-made SQL recipes for common operations such as:

- Querying SQLite tables for specific data points.
- Transforming data to meet compliance requirements.
- Automating data exports, including exporting to CSV.
- Creating and running scheduled workflows that orchestrate multiple SQL tasks.

Each recipe is thoroughly documented and can be adapted for different use cases.
They provide a flexible way to interact with your `surveilr` data sources and
orchestrate automation routines effectively.

## How to Use the Cookbook

Using the `surveilr` Cookbook is straightforward:

1. **Find a Recipe**: Browse the collection of recipes in this directory to find
   one that meets your needs.
2. **Run the Recipe**: Use the `surveilr shell` command to run the SQL commands
   directly, or use `surveilr orchestrate` for automating recipes across
   multiple workflows.
3. **Adapt the Recipe**: Modify the recipes as needed to fit your specific use
   case. Most recipes are flexible and can be adapted to query different tables
   or output in various formats.

### Example Recipes

#### 1. Querying SQLite Tables

```sql
SELECT * FROM your_table WHERE column = 'value';
```

This simple query retrieves all rows from a table where the specified column
matches a given value. You can execute this directly in the `surveilr shell` or
`sqlite3` for testing.

#### 2. Automating Data Exports to CSV

```bash
surveilr orchestrate export-csv --table your_table --output /path/to/export.csv
```

This command automates exporting data from an SQLite table to a CSV file. The
export can be scheduled and integrated into larger workflows using
`surveilr orchestrate`.

#### 3. Data Transformation for Compliance

```sql
UPDATE your_table SET sensitive_column = NULL WHERE compliance_flag = 1;
```

This SQL statement ensures that sensitive data is anonymized or removed for
records flagged for compliance, maintaining data security standards.
