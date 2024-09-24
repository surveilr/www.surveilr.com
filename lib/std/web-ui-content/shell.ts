import * as spn from "../notebook/sqlpage.ts";

export class ShellSqlPages extends spn.TypicalSqlPageNotebook {
  defaultShell() {
    return {
      component: "shell",
      title: "Resource Surveillance State Database (RSSD)",
      icon: "database",
      layout: "fluid",
      fixed_top_menu: true,
      link: "/",
      menu_item: [
        { link: "/", title: "Home" },
      ],
      javascript: [
        "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
        "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
        "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
        "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js",
      ],
      footer: `Resource Surveillance Web UI`,
    };
  }

  @spn.shell({ eliminate: true })
  "shell/shell.json"() {
    return this.SQL`
      ${JSON.stringify(this.defaultShell(), undefined, "  ")}
    `;
  }

  @spn.shell({ eliminate: true })
  "shell/shell.sql"() {
    const literal = (value: unknown) =>
      typeof value === "number"
        ? value
        : value
        ? this.emitCtx.sqlTextEmitOptions.quotedLiteral(value)[1]
        : "NULL";
    const selectNavMenuItems = (rootPath: string, caption: string) =>
      `json_object(
              'link', '${rootPath}',
              'title', ${literal(caption)},
              'submenu', (
                  SELECT json_group_array(
                      json_object(
                          'title', title,
                          'link', link,
                          'description', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = 'prime' AND parent_path = '${rootPath}'
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item`;

    const handlers = {
      DEFAULT: (key: string, value: unknown) => `${literal(value)} AS ${key}`,
      menu_item: (key: string, items: Record<string, unknown>[]) =>
        items.map((item) => `${literal(JSON.stringify(item))} AS ${key}`),
      javascript: (key: string, scripts: string[]) => {
        const items = scripts.map((s) => `${literal(s)} AS ${key}`);
        items.push(selectNavMenuItems("/ur", "Uniform Resource"));
        items.push(selectNavMenuItems("/console", "Console"));
        items.push(selectNavMenuItems("/orchestration", "Orchestration"));
        return items;
      },
      footer: () =>
        // TODO: add "open in IDE" feature like in other Shahid apps
        literal(`Resource Surveillance Web UI (v`) +
        ` || sqlpage.version() || ') ' || ` +
        `'📄 [' || substr(sqlpage.path(), 2) || '](/console/sqlpage-files/sqlpage-file.sql?path=' || substr(sqlpage.path(), 2) || ')' as footer`,
    };
    const shell = this.defaultShell();
    const sqlSelectExpr = Object.entries(shell).flatMap(([k, v]) => {
      switch (k) {
        case "menu_item":
          return handlers.menu_item(k, v as Record<string, unknown>[]);
        case "javascript":
          return handlers.javascript(k, v as string[]);
        case "footer":
          return handlers.footer();
        default:
          return handlers.DEFAULT(k, v);
      }
    });
    return this.SQL`
      SELECT ${sqlSelectExpr.join(",\n       ")};
    `;
  }
}
