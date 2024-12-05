import * as spn from "../notebook/sqlpage.ts";

export class ShellSqlPages extends spn.TypicalSqlPageNotebook {
  private title: string;
  private logoImage: string;
  private favIcon: string;

  constructor(title: string = 'Resource Surveillance State Database (RSSD)', logoImage: string = 'surveilr-icon.png', favIcon: string = 'favicon.ico') {
    super();
    this.title = title;
    this.logoImage = logoImage;
    this.favIcon = favIcon;
  }

  defaultShell() {
    return {
      component: "shell",
      title: this.title,
      icon: "",
      favicon: `https://www.surveilr.com/assets/brand/${this.favIcon}`,
      image: `https://www.surveilr.com/assets/brand/${this.logoImage}`,
      layout: "fluid",
      fixed_top_menu: true,
      link: "index.sql",
      menu_item: [
        { link: "index.sql", title: "Home" },
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
              'link', ${this.absoluteURL("")}||'${rootPath}',
              'title', ${literal(caption)},
              'submenu', (
                  SELECT json_group_array(
                      json_object(
                          'title', title,
                          'link', ${this.absoluteURL("/")}||link,
                          'description', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = 'prime' AND parent_path = '${rootPath}/index.sql'
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
        items.push(selectNavMenuItems("/docs/index.sql", "Docs"));
        items.push(selectNavMenuItems("ur", "Uniform Resource"));
        items.push(selectNavMenuItems("console", "Console"));
        items.push(selectNavMenuItems("orchestration", "Orchestration"));
        return items;
      },
      footer: () =>
        // TODO: add "open in IDE" feature like in other Shahid apps
        literal(`Resource Surveillance Web UI (v`) +
        ` || sqlpage.version() || ') ' || ` +
        `'📄 [' || substr(sqlpage.path(), 2) || '](' || ${this.absoluteURL("/console/sqlpage-files/sqlpage-file.sql?path=")
        } || substr(sqlpage.path(), 2) || ')' as footer`,
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
