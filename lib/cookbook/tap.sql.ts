#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { tapNB } from "../std/notebook/mod.ts";

type TestCaseContext = tapNB.TestCaseContext;

export class SyntheticTestSuite extends tapNB.TestSuiteNotebook {
    // any method that ends in DDL, SQL, DML, or DQL will be "arbitrary SQL"
    // and included in the SQL stream before all the test cases
    setupDDL() {
        return this.SQL`
            -- Create a table for testing purposes
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                age INTEGER NOT NULL
            );

            -- Insert some sample data into the table
            INSERT INTO users (name, age) VALUES ('Alice', 30);
            INSERT INTO users (name, age) VALUES ('Bob', 24);`;
    }

    @tapNB.isNotTestCase()
    simpleMethodNotATestCase() {
        // example showing that arbitrary methods are possible, too
    }

    "Ensure at least two users"(ctx: TestCaseContext) {
        return this.assertThat<"user_count">(ctx)`
            SELECT COUNT(*) AS user_count FROM users`
        .equals("user_count", 2);
    }

    "Check if a user named 'Alice' exists in the table"(ctx: TestCaseContext) {
        const checkUser = "Alice";
        return this.assertThat(ctx)`
            SELECT COUNT(*) AS user_count
              FROM users
             WHERE name = '${checkUser}'
        `.case(
            "user_count = 1", // the assertion SQL expression goes into `CASE WHEN`
            `User "${checkUser}" exists in the table`,
        );
    }

    "Check Bob's data custom cases"(ctx: TestCaseContext) {
        return this.assertThat(ctx)`
            SELECT age, LENGTH(name) AS name_length
              FROM users
             WHERE name = 'Bob'`
        .case(`age = 25`, `"Bob" is 25 years old`, {
            expr: `"Bob" is not 25 years old`,
            diags: {
                "expected": 25,
                "got": "` || age || `", // `...` signifies "break out of SQL literal and use SQL expression"
            },
        })
        .case(`name_length = 3`, `"Bob" has a 3-character name`);
    }

    "Check Bob's data simple cases"(ctx: TestCaseContext) {
        return this.assertThat<"age" | "name_length">(ctx)`
            SELECT age, LENGTH(name) AS name_length
              FROM users
             WHERE name = 'Bob'`
        .equals(`age`, 25)
        .equals(`name_length`, 3);
    }

    // instead of `assertThat`, use `testCase` for full control, be sure to use
    // ${this.tapResultColName} for proper `tap_result` column name
    another_test(ctx: TestCaseContext) {
        return this.testCase(ctx)`
            SELECT '# Skipping the check for user "Eve" as she is not expected in the dataset' AS ${this.tapResultColName}
            UNION ALL
            SELECT 'ok - Skipping test for user "Eve" # SKIP: User "Eve" not expected in this dataset' AS ${this.tapResultColName}`;
    }
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
    const SQL = await tapNB.TestSuiteNotebook.SQL(
        new SyntheticTestSuite("synthetic_test_suite"),
    );
    console.log(SQL.join("\n"));
    console.log(`SELECT * FROM synthetic_test_suite;`);
}
