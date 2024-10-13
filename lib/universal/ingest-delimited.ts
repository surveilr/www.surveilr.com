import { DB, PreparedQuery } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";

/// <reference types="npm:@types/node" />
// @deno-types="npm:@types/papaparse"
import Papa from "npm:papaparse";

// deno-lint-ignore no-explicit-any
type Any = any;

/**
 * Ingests a delimited file (e.g., CSV) into an SQLite database.
 *
 * This function takes a delimited file (such as a CSV) and imports its data into a specified SQLite database.
 * It can either create a new SQLite database connection or use an existing one. The function dynamically creates
 * a table based on the headers in the CSV file and inserts the data into that table using prepared statements
 * for improved performance and security. The inserts are done into an SQLite table with untyped columns, making them flexible for later SQL type detections.
 *
 * @param dbInput - A string representing the path to the SQLite database file, or an existing SQLite connection (DB object).
 *                  If a string is provided, the function will open a new SQLite connection; if a DB object is provided,
 *                  it will use that existing connection.
 * @param content - The content to be ingested, which can be a string representing a URI or local path, an array of URIs,
 *                  an object with a `walk` property that specifies how to collect URIs (with an optional `walkAccept` filter),
 *                  or a Buffer containing CSV data.
 * @param ingestOptions - Optional configuration options for PapaParse to customize the parsing behavior.
 *                       This can include options like `delimiter`, `quoteChar`, etc., as well as `onRowIssue`, `onSrcIssue`,
 *                       `columnNames`, and `tableName` for custom error handling and table creation.
 *
 * @returns A promise that resolves when the data ingestion is complete.
 *
 * @throws Will throw an error if there is an issue with parsing the CSV file or interacting with the SQLite database.
 *
 * Usage Example:
 * ```typescript
 * import { ingestDelimited } from './ingest-csv.ts';
 *
 * ingestDelimited("./resource-surveillance.sqlite.db", "./example.csv", {
 *   tableName: (contentUri) => basename(contentUri, ".csv"), // same name as file without `.csv` extension
 *   columnNames: (_uri, meta) => meta.fields,
 * })
 *   .then(() => console.log("Data ingested successfully."))
 *   .catch(err => console.error("Failed to ingest data: ", err));
 * ```
 */
export async function ingestDelimited<T = unknown>(
    dbInput: string | DB,
    content: string | string[] | Papa.LocalFile | Papa.LocalFile[] | {
        walk: () => AsyncIterable<string | Papa.LocalFile>;
        walkAccept?: (uri: string | Papa.LocalFile) => boolean;
    },
    ingestOptions?: (src: string | Papa.LocalFile, index: number) =>
        & (
            | (Papa.ParseConfig<T> & {
                download?: false | undefined;
                worker?: false | undefined;
            })
            | (Papa.ParseWorkerConfig<T> & { download?: false | undefined })
            | Papa.ParseRemoteConfig<T>
        )
        & {
            tableName?: string;
            columnNames?: (meta: Papa.ParseMeta) => string[];
            dropTableDDL?: (tableName: string) => string;
            createTableDDL?: (
                tableName: string,
                columnNames: string[],
            ) => string;
            insertRowStmtDML?: (
                tableName: string,
                columnNames: string[],
            ) => string;
            insertRowBindValues?: (
                results: Papa.ParseStepResult<T>,
                csvFieldNames: string[],
            ) => unknown[];
            inspectRow?: (
                row: Papa.ParseStepResult<T>,
                tableName: string,
                db: DB,
                src: string | Papa.LocalFile,
            ) => void | Promise<void>;
            onRowIssue?: (
                row: Papa.ParseStepResult<T>,
                error: Error | undefined,
                tableName: string,
                db: DB,
                src: string | Papa.LocalFile,
            ) => boolean | Promise<boolean>;
            onSrcIssue?: (
                src: string | Papa.LocalFile,
                error: Error,
                db: DB,
                tableName: string,
            ) => void | Promise<void>;
        },
) {
    // Open or use the existing SQLite database connection
    const db = typeof dbInput === "string" ? new DB(dbInput) : dbInput;
    const closeDb = typeof dbInput === "string";

    // Helper function to parse a CSV file and insert into the database
    const parseAndInsert = (
        contentSrc: string | Papa.LocalFile,
        index: number,
    ) => {
        const options = ingestOptions?.(contentSrc, index);
        const tableName = options?.tableName ?? "import_csv";
        const columnNamesFn = options?.columnNames ??
            ((meta: Papa.ParseMeta) => meta.fields ?? []);
        const insertRowBindValues = options?.insertRowBindValues ??
            ((stepResults, fieldNames) =>
                fieldNames.map((f) => (stepResults.data as Any)[f] ?? null));
        const inspectRow = options?.inspectRow;

        let tablePrepared = false;
        let csvFieldNames: string[] | undefined = [];
        let tableColNames: string[] = [];
        let insertStmt: PreparedQuery;
        let rowsInsertedCount = 0;

        return new Promise<{
            readonly contentSrc: string | Papa.LocalFile;
            readonly tableName: string;
            readonly tableColNames: string[];
            readonly rowsInsertedCount: number;
        }>((resolve, reject) => {
            // TODO: figure out how to not pass in `as any` (issue with @types/papaparse overloads)
            (Papa.parse as Any)(contentSrc, {
                download: typeof contentSrc === "string" &&
                    contentSrc.startsWith("http"),
                header: true,
                skipEmptyLines: true,
                ...options,
                step: async (
                    results: Papa.ParseStepResult<T>,
                    parser: Papa.Parser,
                ) => {
                    // this might change the content of results
                    inspectRow?.(results, tableName, db, contentSrc);

                    const { meta, errors } = results;
                    if (errors.length > 0) {
                        if (options?.onRowIssue) {
                            const stay = await options?.onRowIssue(
                                results,
                                undefined,
                                tableName,
                                db,
                                contentSrc,
                            );
                            // rows with errors can be kept or discarded
                            if (!stay) return;
                        } else {
                            // by default don't store rows with errors
                            return;
                        }
                    }

                    if (!tablePrepared) {
                        const dropTableDDL = options?.dropTableDDL ??
                            ((tableName) =>
                                `DROP TABLE IF EXISTS "${tableName}"`);
                        const createTableDDL = options?.createTableDDL ??
                            ((tableName, colNames) => {
                                // deno-fmt-ignore
                                return `CREATE TABLE "${tableName}" (${colNames.map((cn) => `"${cn}"`).join(", ")})`;
                            });
                        const insertRowStmtDML = options?.insertRowStmtDML ??
                            ((tableName, colNames) => {
                                // deno-fmt-ignore
                                return `INSERT INTO "${tableName}" VALUES (${colNames.map(() => "?").join(", ")})`;
                            });

                        csvFieldNames = meta.fields;
                        tableColNames = columnNamesFn(meta);

                        if (!csvFieldNames || !csvFieldNames.length) {
                            parser.abort();
                            reject(
                                new Error("No headers found in the CSV file."),
                            );
                            return;
                        }

                        db.execute(dropTableDDL(tableName));
                        db.execute(createTableDDL(tableName, tableColNames));
                        insertStmt = db.prepareQuery(
                            insertRowStmtDML(tableName, tableColNames),
                        );
                        tablePrepared = true;
                    }

                    try {
                        insertStmt.execute(
                            insertRowBindValues(results, csvFieldNames!),
                        );
                        rowsInsertedCount++;
                    } catch (rowError) {
                        await options?.onRowIssue?.(
                            results,
                            rowError,
                            tableName,
                            db,
                            contentSrc,
                        );
                    }
                },
                complete: () => {
                    if (insertStmt) insertStmt.finalize();
                    resolve({
                        contentSrc,
                        tableName,
                        tableColNames,
                        rowsInsertedCount,
                    });
                },
            });
        });
    };

    try {
        // Process content to get URIs
        let sources: (string | Papa.LocalFile)[] = [];
        if (typeof content === "object" && "walk" in content) {
            for await (const uri of content.walk()) {
                if (!content.walkAccept || content.walkAccept(uri)) {
                    sources.push(uri);
                }
            }
        } else if (Array.isArray(content)) {
            sources = content;
        } else {
            sources = [content];
        }

        // Parse and ingest each URI
        const results = [];
        for (const uri of sources) {
            results.push(await parseAndInsert(uri, results.length));
        }
        return results;
    } catch (error) {
        console.error("Error during content processing: ", error);
        throw error;
    } finally {
        if (closeDb) db.close();
    }
}
