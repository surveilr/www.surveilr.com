export type SQLQuery = { text: string; values: readonly unknown[] };

export type SQL = {
  safe(options?: {
    identifier?: "$" | ":" | ((position: number) => string);
  }): SQLQuery;

  text(options?: { ifDate?: (d: Date) => string }): string;
  toString(): string;
};

// SQL template literal tag function
export function SQL(strings: TemplateStringsArray, ...values: unknown[]): SQL {
  return new SQLImpl(strings, values);
}

// Raw SQL helper for verbatim inclusion
export function raw(sql: string): SQLRaw {
  return new SQLRaw(sql);
}

class SQLRaw {
  constructor(public readonly sql: string) {}
}

class SQLImpl implements SQL {
  constructor(
    private strings: TemplateStringsArray,
    private values: unknown[]
  ) {}

  safe(options: { identifier?: "$" | ":" | ((position: number) => string) } = {}): SQLQuery {
    const { identifier = "$" } = options;
    let text = "";
    let params: unknown[] = [];
    let paramIndex = 1;

    for (let i = 0; i < this.strings.length; i++) {
      text += this.strings[i];

      if (i < this.values.length) {
        const value = this.values[i];
        
        if (value instanceof SQLRaw) {
          text += value.sql;
        } else if (value instanceof SQLImpl) {
          const nested = value.safe({ identifier });
          text += nested.text;
          params = params.concat(nested.values);
          paramIndex += nested.values.length;
        } else {
          const placeholder = typeof identifier === "function" 
            ? identifier(paramIndex)
            : `${identifier}${paramIndex}`;
          text += placeholder;
          params.push(value);
          paramIndex++;
        }
      }
    }

    return { text, values: params };
  }

  text(options: { ifDate?: (d: Date) => string } = {}): string {
    const { ifDate = (d: Date) => d.toISOString() } = options;
    let result = "";

    for (let i = 0; i < this.strings.length; i++) {
      result += this.strings[i];

      if (i < this.values.length) {
        const value = this.values[i];
        
        if (value instanceof SQLRaw) {
          result += value.sql;
        } else if (value instanceof SQLImpl) {
          result += value.text({ ifDate });
        } else {
          result += formatValue(value, ifDate);
        }
      }
    }

    return result;
  }

  toString(): string {
    return this.text();
  }
}

function formatValue(value: unknown, ifDate: (d: Date) => string): string {
  if (value === null || value === undefined) {
    return "NULL";
  }
  
  if (typeof value === "string") {
    return `'${value.replace(/'/g, "''")}'`;
  }
  
  if (typeof value === "number") {
    return value.toString();
  }
  
  if (typeof value === "boolean") {
    return value ? "TRUE" : "FALSE";
  }
  
  if (value instanceof Date) {
    return `'${ifDate(value)}'`;
  }
  
  if (Array.isArray(value)) {
    return `(${value.map(v => formatValue(v, ifDate)).join(", ")})`;
  }
  
  return `'${String(value).replace(/'/g, "''")}'`;
}

// Convenience function for inlined SQL (same as .text())
export function inlinedSQL(sqlImpl: SQL): string {
  return sqlImpl.text();
}