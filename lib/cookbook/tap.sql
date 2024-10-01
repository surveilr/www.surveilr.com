-- TEST this using:
-- $ rm -f test.db && cat ../../cookbook/tap-example2.sql | sqlite3 test.db && sqlite3 test.db -cmd "SELECT * FROM tap_report;"

-- Create a table for testing purposes
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    age INTEGER NOT NULL
);

-- Insert some sample data into the table
INSERT INTO users (name, age) VALUES ('Alice', 30);
INSERT INTO users (name, age) VALUES ('Bob', 25);

-- TAP Report: Combine all test cases directly into the final TAP report
-- Purpose: This view generates the final TAP output, including the TAP version declaration, the test plan, and the results of all test cases.
-- The TAP report starts with the TAP version (`TAP version 14`) and the test plan (`1..10`).
-- Each test case is executed using CTEs (Common Table Expressions) and the results are output as TAP-compliant lines.
-- Each section of the TAP report is constructed using a `UNION ALL` to aggregate the test results.

CREATE VIEW tap_report AS
    -- TAP Version Declaration
    WITH tap_version AS (
        SELECT 'TAP version 14' AS tap_result
    ),
    -- TAP Plan: Number of tests being run (including subtests)
    tap_plan AS (
        SELECT '1..10' AS tap_result
    ),
    -- Test Case 1: Check if a user named 'Alice' exists in the table
    test_case_1 AS (
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users WHERE name = 'Alice') = 1
            THEN 'ok 1 - User "Alice" exists in the table'
            ELSE 'not ok 1 - User "Alice" does not exist in the table\n  ---\n  expected: 1\n  got: ' || (SELECT COUNT(*) FROM users WHERE name = 'Alice') || '\n  ...'
        END AS tap_result
    ),
    -- Test Case 2: Check if a user named 'Charlie' exists in the table (TODO)
    test_case_2 AS (
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users WHERE name = 'Charlie') = 1
            THEN 'ok 2 - User "Charlie" exists in the table'
            ELSE 'not ok 2 - User "Charlie" does not exist in the table # TODO: Implement user creation for "Charlie"'
        END AS tap_result
    ),
    -- Test Case 3: Skip checking for a user named "Eve"
    test_case_3 AS (
        SELECT 'ok 3 - Skipping test for user "Eve" # SKIP: User "Eve" not expected in this dataset' AS tap_result
    ),
    -- Test Case 4: Subtests for verifying multiple conditions for "Bob"
    test_case_4 AS (
        SELECT 'ok 4.1 - "Bob" is 25 years old' AS tap_result
        WHERE (SELECT age FROM users WHERE name = 'Bob') = 25
        UNION ALL
        SELECT 'not ok 4.1 - "Bob" is not 25 years old\n  ---\n  expected: 25\n  got: ' || (SELECT age FROM users WHERE name = 'Bob') || '\n  ...'
        WHERE (SELECT age FROM users WHERE name = 'Bob') <> 25
        UNION ALL
        SELECT 'ok 4.2 - "Bob" has a 3-character name' AS tap_result
        WHERE (SELECT LENGTH(name) FROM users WHERE name = 'Bob') = 3
        UNION ALL
        SELECT 'not ok 4.2 - "Bob" does not have a 3-character name'
        WHERE (SELECT LENGTH(name) FROM users WHERE name = 'Bob') <> 3
    ),
    -- Test Case 5: Bail Out! if no users exist in the table
    test_case_5 AS (
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users) = 0
            THEN 'Bail out! - No users in the table, cannot continue testing'
            ELSE 'ok 5 - Users are present in the table'
        END AS tap_result
    ),
    -- Test Case 6: Perform multiple tests within a single view
    test_case_6 AS (
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users) = 2
            THEN 'ok 6.1 - There are exactly 2 users in the table'
            ELSE 'not ok 6.1 - The number of users in the table is incorrect\n  ---\n  expected: 2\n  got: ' || (SELECT COUNT(*) FROM users) || '\n  ...'
        END AS tap_result
        UNION ALL
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users WHERE name = 'Alice') = 1
            THEN 'ok 6.2 - There is exactly 1 user named "Alice"'
            ELSE 'not ok 6.2 - The number of users named "Alice" is incorrect\n  ---\n  expected: 1\n  got: ' || (SELECT COUNT(*) FROM users WHERE name = 'Alice') || '\n  ...'
        END AS tap_result
        UNION ALL
        SELECT CASE
            WHEN (SELECT COUNT(*) FROM users WHERE name = 'Bob') = 1
            THEN 'ok 6.3 - There is exactly 1 user named "Bob"'
            ELSE 'not ok 6.3 - The number of users named "Bob" is incorrect\n  ---\n  expected: 1\n  got: ' || (SELECT COUNT(*) FROM users WHERE name = 'Bob') || '\n  ...'
        END AS tap_result
    )
    -- Combine all the results into the final TAP report
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
