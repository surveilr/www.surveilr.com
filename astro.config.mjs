import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";
import sitemap from "@astrojs/sitemap";
import compressor from "astro-compressor";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  // https://docs.astro.build/en/guides/images/#authorizing-remote-images
  //site: "https://screwfast.uk",
  site: "https://www.surveilr.com",
  image: {
    domains: ["images.unsplash.com"],
  },
  // i18n: {
  //   defaultLocale: "en",
  //   locales: ["en", "fr"],
  //   fallback: {
  //     fr: "en",
  //   },
  //   routing: {
  //     prefixDefaultLocale: false,
  //   },
  // },
  prefetch: true,
  integrations: [
    tailwind(),
    sitemap({
      i18n: {
        defaultLocale: "en", // All urls that don't contain `fr` after `https://screwfast.uk/` will be treated as default locale, i.e. `en`
        locales: {
          en: "en", // The `defaultLocale` value must present in `locales` keys
          fr: "fr",
        },
      },
    }),
    starlight({
      title: "ScrewFast Docs",
      defaultLocale: "root",
      // https://github.com/withastro/starlight/blob/main/packages/starlight/CHANGELOG.md
      // If no Astro and Starlight i18n configurations are provided, the built-in default locale is used in Starlight and a matching Astro i18n configuration is generated/used.
      // If only a Starlight i18n configuration is provided, an equivalent Astro i18n configuration is generated/used.
      // If only an Astro i18n configuration is provided, the Starlight i18n configuration is updated to match it.
      // If both an Astro and Starlight i18n configurations are provided, an error is thrown.
      locales: {
        root: {
          label: "English",
          lang: "en",
        },
        de: { label: "Deutsch", lang: "de" },
        es: { label: "Español", lang: "es" },
        fa: { label: "Persian", lang: "fa", dir: "rtl" },
        fr: { label: "Français", lang: "fr" },
        ja: { label: "日本語", lang: "ja" },
        "zh-cn": { label: "简体中文", lang: "zh-CN" },
      },
      // https://starlight.astro.build/guides/sidebar/
      sidebar: [               
         {
          label: "surveilr Core",
          items: [
            {              
              label: "Getting Started",
              link: "/docs/core/getting-started",              
            },
            {              
              label: "surveilr CLI",
              items: [
                {
                  label: "Ingest Commands",
                  collapsed: true,
                  items: [
                    {
                      label: "Files Ingestion",
                      link: "/docs/core/cli/ingest-commands/files",
                    },
                    {
                      label: "Tasks Ingestion",
                      link: "/docs/core/cli/ingest-commands/tasks",
                    },
                    {
                      label: "Capturable Executables",
                      link: "/docs/core/cli/ingest-commands/capexec",
                    },
                    {
                      label: "IMAP Emails Ingestion",
                      link: "/docs/core/cli/ingest-commands/imap",
                    },
                  ],
                },
                {
                  label: "Other Commands",
                  collapsed: true,
                  items: [
                    {
                      label: "CLI Commands",
                      link: "/docs/core/cli/other-commands/commands",
                    },
                  ],
                },
              ]
            },
            {
              label: "Standard library",
              items: [                
                {
                  label: "Notebooks Schema",
                  collapsed: true,
                  items: [
                    {
                      label: "Notebooks Schema",
                      link: "/docs/core/standard-library/surveilr-code-notebooks-schema/notebooks_schema",
                    },
                    {
                      label: "Assurance Schema",
                      link: "/docs/core/standard-library/surveilr-code-notebooks-schema/assurance_schema",
                    },
                    {
                      label: "Code Notebook Cell",
                      link: "/docs/core/standard-library/surveilr-code-notebooks-schema/code_notebook_cell",
                    },
                    {
                      label: "Code Notebook Kernel",
                      link: "/docs/core/standard-library/surveilr-code-notebooks-schema/code_notebook_kernel",
                    },
                    {
                      label: "Code Notebook State",
                      link: "/docs/core/standard-library/surveilr-code-notebooks-schema/code_notebook_state",
                    },
                  ],
                },
              ],
            },
            {
              label: "Capturable Executables",
              collapsed: true,
                  items: [
                    {
                      label:
                        "Content Extensibility with Capturable Executables",
                      link: "/docs/core/capturable-executables/content-extensibility",
                    },
                    {
                      label: "SQL DDL Extensibility with SQL Notebooks",
                      link: "/docs/core/capturable-executables/sql-ddl-extensibility",
                    },
                    {
                      label:
                        "Integrated TypeScript programmability and scriptability",
                      link: "/docs/core/capturable-executables/integrated-ts",
                    },
                  ],
            },
            
          ],
        },{
          label: "surveilr Pro",
          items:[
            
          ],
        },{
          label: "Standard library",
          items:[],
        },{
          label: "Patterns",
          items: [            
          ],
        },{
          label: "Services",
          items:[
                     ],
        },{
          label: "Cookbook and Snippets",
          items:[],
        },

      ],
      social: {
        github: "https://github.com/surveilr",
      },
      disable404Route: true,
      customCss: ["./src/assets/styles/starlight.css"],
      favicon: "/favicon.ico",
      components: {
        SiteTitle: "./src/components/ui/starlight/SiteTitle.astro",
        Head: "./src/components/ui/starlight/Head.astro",
        MobileMenuFooter: "./src/components/ui/starlight/MobileMenuFooter.astro",
        ThemeSelect: "./src/components/ui/starlight/ThemeSelect.astro",
      },
      head: [
        {
          tag: "meta",
          attrs: {
            property: "og:image",
            content: "https://screwfast.uk" + "/social.webp",
          },
        },
        {
          tag: "meta",
          attrs: {
            property: "twitter:image",
            content: "https://screwfast.uk" + "/social.webp",
          },
        },
      ],
    }),
    compressor({
      gzip: false,
      brotli: true,
    }),
  ],
  output: "static",
  experimental: {
    clientPrerender: true,
    directRenderScript: true,
  },
});
