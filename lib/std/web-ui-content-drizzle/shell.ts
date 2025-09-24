#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * Drizzle-based Shell SQLPages
 * 
 * Recreates the shell web UI content using Drizzle decorators instead of SQLa
 */

import { DrizzleSqlPageNotebook, shellDrizzle } from "../notebook-drizzle/drizzle-sqlpage.ts";

export class DrizzleShellSqlPages extends DrizzleSqlPageNotebook {
  private title: string;
  private logoImage: string;
  private favIcon: string;

  constructor(
    title: string = "Resource Surveillance State Database (RSSD)",
    logoImage: string = "surveilr-icon.png",
    favIcon: string = "favicon.ico",
  ) {
    super("shell");
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

  @shellDrizzle({ eliminate: true })
  "shell/shell.json"() {
    return this.SQL`${JSON.stringify(this.defaultShell(), undefined, "  ")}`;
  }

  @shellDrizzle({ eliminate: true })
  "shell/shell.sql"() {
    const shell = this.defaultShell();
    return this.SQL`SELECT 'shell' AS component,
      ${JSON.stringify(shell.title)} AS title,
      ${JSON.stringify(shell.icon)} AS icon,
      ${JSON.stringify(shell.favicon)} AS favicon,
      ${JSON.stringify(shell.image)} AS image,
      ${JSON.stringify(shell.layout)} AS layout,
      ${shell.fixed_top_menu ? 'TRUE' : 'FALSE'} AS fixed_top_menu,
      ${JSON.stringify(shell.link)} AS link,
      ${JSON.stringify(shell.menu_item)} AS menu_item,
      ${JSON.stringify(shell.javascript)} AS javascript,
      ${JSON.stringify(shell.footer)} AS footer;`;
  }

  "index.sql"() {
    return this.SQL`-- Resource Surveillance Web UI Home
SELECT 'hero' AS component,
    'Resource Surveillance State Database (RSSD)' AS title,
    'Monitor, analyze, and manage your digital resources with comprehensive surveillance capabilities.' AS description;

SELECT 'text' AS component,
    '## Welcome to surveilr

This web interface provides access to your Resource Surveillance State Database. Use the navigation menu to explore:

- **Console**: Administrative tools and system information
- **Uniform Resource**: Resource management and analysis  
- **Orchestration**: Workflow and process management
- **Documentation**: API documentation and help guides

' AS contents_md;`;
  }
}