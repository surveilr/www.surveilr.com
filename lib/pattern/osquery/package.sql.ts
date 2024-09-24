#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { codeNB as cnb } from "../../std/notebook/mod.ts";

/**
 * OsQuerySqlNotebook adds Code Notebook Cells which allow RSSDs to operate as
 * osQuery SQL suppliers (for ATCs).
 */
export class OsQuerySqlNotebook extends cnb.TypicalCodeNotebook {
  constructor() {
    super("osquery");
  }

  /**
   * Generates a JSON configuration for osquery's auto_table_construction
   * feature by inspecting the SQLite database schema. The SQL creates a
   * structured JSON object detailing each table within the database. For
   * every table, the object includes a standard SELECT query, the relevant
   * columns, and the database file path.
   *
   * The database file path is assumed to be stored in this.sessionStateTable
   * in a row with key `osQueryAtcPath`.
   *
   * @example
   * // The resultant JSON object is structured as follows:
   * {
   *   "auto_table_construction": {
   *     "table_name1": {
   *       "query": "SELECT column1, column2, ... FROM table_name1",
   *       "columns": ["column1", "column2", ...],
   *       "path": "./sqlite-src.db"   # <-- infoSchemaOsQueryATCs_path
   *     },
   *     ...
   *   }
   * }
   */
  @cnb.sqlCell({
    description: "Generate osQuery auto_table_construction JSON",
    arguments: "infoSchemaOsQueryATCs_path",
  })
  infoSchemaOsQueryATCs() {
    const args = this.activeSessionState({
      infoSchemaOsQueryATCs_path: "./sqlite-src.db",
    });
    return this.SQL`
          WITH table_columns AS (
              SELECT m.tbl_name AS table_name,
                     group_concat(c.name) AS column_names_for_select,
                     json_group_array(c.name) AS column_names_for_atc_json
                FROM sqlite_master m,
                     pragma_table_info(m.tbl_name) c
               WHERE m.type = 'table'
            GROUP BY m.tbl_name
          ),
          target AS (
            -- set SQLite parameter :osquery_atc_path to assign a different path
            SELECT COALESCE(${args.select.infoSchemaOsQueryATCs_path}, 'No infoSchemaOsQueryATCs_path argument supplied in ${this.sessionStateTable.tableName}') AS path
          ),
          table_query AS (
              SELECT table_name,
                     'SELECT ' || column_names_for_select || ' FROM ' || table_name AS query,
                     column_names_for_atc_json
                FROM table_columns
          )
          SELECT json_object('auto_table_construction',
                    json_group_object(
                        table_name,
                        json_object(
                            'query', query,
                            'columns', json(column_names_for_atc_json),
                            'path', path
                        )
                    )
                 ) AS osquery_auto_table_construction
            FROM table_query, target;`;
  }
}

export async function SQL() {
  return await OsQuerySqlNotebook.SQL(new OsQuerySqlNotebook());
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
