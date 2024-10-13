import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";
import { assertEquals } from "https://deno.land/std@0.224.0/assert/assert_equals.ts";
import { ingestDelimited } from "./ingest-delimited.ts";

// deno-lint-ignore no-explicit-any
type Any = any;

Deno.test("ingestDelimited should create table and insert rows correctly from CSV buffer", async () => {
    // Create a synthetic CSV in a buffer
    const csvContent =
        `id,name,age\n1,John Doe,30\n2,Jane Smith,25\n3,Bob Johnson,40`;

    // Use an in-memory SQLite database
    const db = new DB();

    // Ingest the CSV buffer into the SQLite database
    await ingestDelimited(db, csvContent, () => ({
        tableName: "test_table",
        dynamicTyping: true,
    }));

    // Verify that the table was created correctly
    const tables = [
        ...db.query(
            `SELECT name FROM sqlite_master WHERE type='table' AND name='test_table';`,
        ),
    ];
    assertEquals(tables.length, 1, "Table 'test_table' should exist.");

    // Verify that the table has the correct columns
    const columns = [...db.query(`PRAGMA table_info(test_table);`)];
    const columnNames = columns.map((col) => col[1]);
    assertEquals(
        columnNames,
        ["id", "name", "age"],
        "Table 'test_table' should have the correct columns.",
    );

    // Verify that the rows were inserted correctly
    const rows = [...db.query(`SELECT * FROM test_table ORDER BY id;`)];
    assertEquals(rows.length, 3, "Table 'test_table' should have 3 rows.");
    assertEquals(
        rows[0],
        [1, "John Doe", 30],
        "First row should match the expected values.",
    );
    assertEquals(
        rows[1],
        [2, "Jane Smith", 25],
        "Second row should match the expected values.",
    );
    assertEquals(
        rows[2],
        [3, "Bob Johnson", 40],
        "Third row should match the expected values.",
    );

    // Close the database
    db.close();
});

Deno.test("ingestDelimited should handle onRowIssue correctly", async () => {
    // Create a synthetic CSV with an issue in a row
    const csvContent =
        `id,name,age\n1,John Doe,30\n2,Jane Smith,invalid_age\n3,Bob Johnson,40`;

    // Use an in-memory SQLite database
    const db = new DB();

    let onRowIssuesCalled = 0;

    // Ingest the CSV buffer into the SQLite database with onRowIssue handling
    await ingestDelimited<{ age: number }>(db, csvContent, () => ({
        dynamicTyping: true,
        inspectRow: (row) => {
            // you could use Zod or other validations
            if (typeof row.data.age !== "number") {
                row.errors.push({
                    row: row.meta.cursor,
                    type: "FieldMismatch",
                    code: "NotANumber" as Any,
                    message: "Age is not a number",
                });
            }
        },
        tableName: "test_table_with_issues",
        onRowIssue: (_row, _error, _tableName, _db, _src) => {
            // you could use _db to insert into another table, etc.
            onRowIssuesCalled++;
            return false; // Skip the problematic row
        },
    }));

    // Verify that onRowIssue was called
    assertEquals(onRowIssuesCalled, 1, "onRowIssue should have been called.");

    // Verify that the table was created correctly
    const tables = [
        ...db.query(
            `SELECT name FROM sqlite_master WHERE type='table' AND name='test_table_with_issues';`,
        ),
    ];
    assertEquals(
        tables.length,
        1,
        "Table 'test_table_with_issues' should exist.",
    );

    // Verify that the rows were inserted correctly, skipping the problematic row
    const rows = [
        ...db.query(`SELECT * FROM test_table_with_issues ORDER BY id;`),
    ];
    assertEquals(
        rows.length,
        2,
        "Table 'test_table_with_issues' should have 2 rows after skipping the problematic row.",
    );
    assertEquals(
        rows[0],
        [1, "John Doe", 30],
        "First row should match the expected values.",
    );
    assertEquals(
        rows[1],
        [3, "Bob Johnson", 40],
        "Second row should match the expected values.",
    );

    // Close the database
    db.close();
});

Deno.test("ingestDelimited should handle multiple files", async () => {
    // Create synthetic CSV files
    const csvContent1 = `id,name,age\n1,John Doe,30`;
    const csvContent2 = `id,name,age\n2,Jane Smith,25`;

    // Use an in-memory SQLite database
    const db = new DB();

    // Ingest the CSV buffers into the SQLite database;
    await ingestDelimited(db, [csvContent1, csvContent2], (_src, index) => ({
        tableName: "test_table_multiple",
        dropTableDDL: index > 0
            ? () => `/* not dropping for second instance */`
            : undefined,
        createTableDDL: index > 0
            ? () => `/* not creating table for second instance */`
            : undefined,
    }));

    // Verify that the table was created correctly
    const tables = [
        ...db.query(
            `SELECT name FROM sqlite_master WHERE type='table' AND name='test_table_multiple';`,
        ),
    ];
    assertEquals(tables.length, 1, "Table 'test_table_multiple' should exist.");

    // Verify that the rows were inserted correctly
    const rows = [
        ...db.query(`SELECT * FROM test_table_multiple ORDER BY id;`),
    ];
    assertEquals(
        rows.length,
        2,
        "Table 'test_table_multiple' should have 2 rows.",
    );
    assertEquals(
        rows[0],
        ["1", "John Doe", "30"],
        "First row should match the expected values.",
    );
    assertEquals(
        rows[1],
        ["2", "Jane Smith", "25"],
        "Second row should match the expected values.",
    );

    // Close the database
    db.close();
});
