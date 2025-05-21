# Synthetic Data Generator for Diabetes Research Hub

This script generates synthetic data for diabetes research studies. It creates various tables and inserts synthetic data into them, including study metadata, participants, fitness data, meal data, and continuous glucose monitoring (CGM) data.

## Prerequisites
[Deno](https://deno.land/) installed on your system.

## Usage

To execute the script, use the following command:
``` deno run -A ./synthetic-data-generator/generate-synthetic-data-per-study.ts ```
The script will prompt you for the following inputs:

Study Name: Enter the name of the study (e.g., DCLP100).
Tenant Name: Enter the name of the tenant (e.g., University of Virginia Synthetic).
Number of Participants: Enter the number of participants (maximum 1000).
CGM Data Frequency: Enter the number of days for CGM data (14, 30, or 90 days).

### Example
``` 
Enter study name: DCLP100
Enter tenant name: University of Virginia Synthetic
Enter number of participants (max 1000): 2
Enter CGM data frequency (14, 30, 90 days): 14
```

## Output
The script will generate synthetic data and display progress in the console. Upon completion, it will provide a summary of the generated data, including the study ID, number of participants, and total data points.

## Error Handling
If any errors occur during execution, the script will attempt to roll back any ongoing transactions and close the database connection. The error details will be logged to the console.

## Database
The script uses an SQLite database (resource-surveillance.sqlite.db) to store the generated data. The database schema includes tables for studies, participants, fitness data, meal data, CGM data, and more.

# synthetic study generation and sqlpage setup steps
```bash
deno run -A ./synthetic-data-generator/generate-synthetic-data-per-study.ts 
deno run -A ./study-specific-stateless/generate-cgm-combined-sql.ts saveJsonCgm
deno run -A ./study-specific-stateless/generate-cgm-combined-sql.ts generateMealFitnessandMetadataJson
surveilr shell ./synthetic-data-generator/synthetic-package.sql.ts
SQLPAGE_SITE_PREFIX="" surveilr web-ui --port 9000
```