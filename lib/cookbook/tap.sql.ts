#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { tapNB } from "../std/notebook/mod.ts";

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

    "Ensure at least two users"() {
        return this.assertThat`
            SELECT COUNT(*) AS user_count FROM users`
            .case(
                "user_count = 2", // the assertion SQL expression goes into `CASE WHEN`
                "Found expected number of users (`|| user_count ||`)", // the literal or SQL expression for "pass"
                // no "fail" is given so it uses the same as "pass"
            );
    }

    "Check if a user named 'Alice' exists in the table"() {
        const checkUser = 'Alice';
        return this.assertThat`
            SELECT COUNT(*) AS user_count
              FROM users
             WHERE name = '${checkUser}'
        `.case(
            "user_count = 1", // the assertion SQL expression goes into `CASE WHEN`
            `User "${checkUser}" exists in the table`,
        );
    }

    "Check Bob's data"() {
        return this.assertThat`
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
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
    const SQL = await tapNB.TestSuiteNotebook.SQL(
        new SyntheticTestSuite("synthetic_test_suite"),
    );
    console.log(SQL.join("\n"));
}
