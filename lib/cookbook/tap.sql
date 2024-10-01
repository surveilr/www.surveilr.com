-- RUN THIS TEST this using CLI:
-- $ rm -f test.db && cat tap.sql | sqlite3 test.db && sqlite3 test.db -cmd "SELECT * FROM tap_report;"

/*
This script demonstrates how to create a Test Anything Protocol (TAP) report using SQLite, following TAP version 14.
It includes multiple test cases, and subtests are formatted with indentation per TAP 14's subtest style.

The `tap.sql.ts` source code shows how to generate TAP views via TypeScript classes.

Key Concepts Demonstrated:
1. TAP Version Declaration: Specifies that TAP version 14 is being used.
2. TAP Plan: Indicates how many tests will be run (1..7 main tests, but one test contains subtests).
3. Test Cases:
   - Basic tests checking if certain users exist in the table.
   - `TODO` Directive: Indicates a known unimplemented feature or issue.
   - `SKIP` Directive: Skips tests that are not relevant or expected to fail for known reasons.
   - Subtests: Uses TAP 14's indentation formatting for subtests within a main test.
   - `Bail Out!`: Stops further testing in case of critical failures.
4. Diagnostic Information: Uses YAML-like blocks for structured diagnostic output on test failures.

TAP Output Example
------------------
TAP version 14
1..7
# Checking if user "Alice" exists in the users table
ok 1 - User "Alice" exists in the table
# Checking if user "Charlie" exists in the users table
not ok 2 - User "Charlie" does not exist in the table # TODO: Implement user creation for "Charlie"
# Skipping the check for user "Eve" as she is not expected in the dataset
ok 3 - Skipping test for user "Eve" # SKIP: User "Eve" not expected in this dataset
# Checking user "Bob" with subtests for age and name length
# Subtest: Check user "Bob"
    1..2
    ok 1 - "Bob" is 25 years old
    ok 2 - "Bob" has a 3-character name
ok 4 - User "Bob" passed all subtests
# Checking if there are any users in the table, and stop if none are found
ok 5 - Users are present in the table
# Performing multiple checks in a single view: number of users, "Alice" count, and "Bob" count
ok 6.1 - There are exactly 2 users in the table
ok 6.2 - There is exactly 1 user named "Alice"
ok 6.3 - There is exactly 1 user named "Bob"
*/

/* Create a synthetic users table for the test cases */
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    age INTEGER NOT NULL
);

/* Insert sample data into the users table */
INSERT INTO users (name, age) VALUES ('Alice', 30);
INSERT INTO users (name, age) VALUES ('Bob', 25);

CREATE VIEW tap_report AS
    WITH tap_version AS (
        SELECT 'TAP version 14' AS tap_result
    ),
    tap_plan AS (
        SELECT '1..7' AS tap_result
    ),
    test_case_1 AS (
        SELECT '# Checking if user "Alice" exists in the users table' AS tap_result
        UNION ALL
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users WHERE name = 'Alice') = 1
            THEN 'ok 1 - User "Alice" exists in the table'
            ELSE 'not ok 1 - User "Alice" does not exist in the table\n  ---\n  expected: 1\n  got: ' || 
            (SELECT COUNT(*) FROM users WHERE name = 'Alice') || '\n  ...'
        END AS tap_result
    ),
    test_case_2 AS (
        SELECT '# Checking if user "Charlie" exists in the users table' AS tap_result
        UNION ALL
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users WHERE name = 'Charlie') = 1
            THEN 'ok 2 - User "Charlie" exists in the table'
            ELSE 'not ok 2 - User "Charlie" does not exist in the table # TODO: Implement user creation for "Charlie"'
        END AS tap_result
    ),
    test_case_3 AS (
        SELECT '# Skipping the check for user "Eve" as she is not expected in the dataset' AS tap_result
        UNION ALL
        SELECT 'ok 3 - Skipping test for user "Eve" # SKIP: User "Eve" not expected in this dataset' AS tap_result
    ),
    test_case_4 AS (
        SELECT '# Checking user "Bob" with subtests for age and name length' AS tap_result
        UNION ALL
        SELECT '# Subtest: Check user "Bob"' AS tap_result
        UNION ALL
        SELECT '    1..2'  -- Subtest plan: 2 subtests will be run
        UNION ALL
        /* Subtest 1: Check if Bob's age is 25, formatted as indented subtest */
        SELECT '    ok 1 - "Bob" is 25 years old' AS tap_result
        WHERE (SELECT age FROM users WHERE name = 'Bob') = 25
        UNION ALL
        SELECT '    not ok 1 - "Bob" is not 25 years old\n  ---\n  expected: 25\n  got: ' || 
        (SELECT age FROM users WHERE name = 'Bob') || '\n  ...'
        WHERE (SELECT age FROM users WHERE name = 'Bob') <> 25
        UNION ALL
        /* Subtest 2: Check if Bob's name has 3 characters, formatted as indented subtest */
        SELECT '    ok 2 - "Bob" has a 3-character name' AS tap_result
        WHERE (SELECT LENGTH(name) FROM users WHERE name = 'Bob') = 3
        UNION ALL
        SELECT '    not ok 2 - "Bob" does not have a 3-character name'
        WHERE (SELECT LENGTH(name) FROM users WHERE name = 'Bob') <> 3
        UNION ALL
        /* Main test case result after subtests */
        SELECT 'ok 4 - User "Bob" passed all subtests'  -- Main test case 4 for "Bob"
    ),
    test_case_5 AS (
        SELECT '# Checking if there are any users in the table, and stop if none are found' AS tap_result
        UNION ALL
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users) = 0
            THEN 'Bail out! - No users in the table, cannot continue testing'
            ELSE 'ok 5 - Users are present in the table'
        END AS tap_result
    ),
    test_case_6 AS (
        SELECT '# Performing multiple checks in a single view: number of users, "Alice" count, and "Bob" count' AS tap_result
        UNION ALL
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users) = 2
            THEN 'ok 6.1 - There are exactly 2 users in the table'
            ELSE 'not ok 6.1 - The number of users in the table is incorrect\n  ---\n  expected: 2\n  got: ' || 
            (SELECT COUNT(*) FROM users) || '\n  ...'
        END AS tap_result
        UNION ALL
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users WHERE name = 'Alice') = 1
            THEN 'ok 6.2 - There is exactly 1 user named "Alice"'
            ELSE 'not ok 6.2 - The number of users named "Alice" is incorrect\n  ---\n  expected: 1\n  got: ' || 
            (SELECT COUNT(*) FROM users WHERE name = 'Alice') || '\n  ...'
        END AS tap_result
        UNION ALL
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users WHERE name = 'Bob') = 1
            THEN 'ok 6.3 - There is exactly 1 user named "Bob"'
            ELSE 'not ok 6.3 - The number of users named "Bob" is incorrect\n  ---\n  expected: 1\n  got: ' || 
            (SELECT COUNT(*) FROM users WHERE name = 'Bob') || '\n  ...'
        END AS tap_result
    )
    SELECT * FROM tap_version
    UNION ALL
    SELECT * FROM tap_plan
    UNION ALL
    SELECT * FROM test_case_1
    UNION ALL
    SELECT * FROM test_case_2
    UNION ALL
    SELECT * FROM test_case_3
    UNION ALL
    SELECT * FROM test_case_4
    UNION ALL
    SELECT * FROM test_case_5
    UNION ALL
    SELECT * FROM test_case_6;