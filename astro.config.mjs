import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";
import sitemap from "@astrojs/sitemap";
import compressor from "astro-compressor";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  // https://docs.astro.build/docs/guides/images/#authorizing-remote-images

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
        defaultLocale: "en", // All urls that don't contain `fr` after domain will be treated as default locale, i.e. `en`
        locales: {
          en: "en", // The `defaultLocale` value must present in `locales` keys
          fr: "fr",
        },
      },
    }),
    starlight({
      title: "surveilr Docs",
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
        // de: { label: "Deutsch", lang: "de" },
        // es: { label: "Español", lang: "es" },
        // fa: { label: "Persian", lang: "fa", dir: "rtl" },
        // fr: { label: "Français", lang: "fr" },
        // ja: { label: "日本語", lang: "ja" },
        // "zh-cn": { label: "简体中文", lang: "zh-CN" },
      },
      // https://starlight.astro.build/guides/sidebar/
      sidebar: [
        {
          label: "surveilr Core",
          items: [
            {
              label: "Getting Started",
              slug: "docs/core/getting-started",
            },
            {
              label: "surveilr CLI",
              items: [
                {
                  label: "Ingest Commands",
                  collapsed: true,
                  autogenerate: {
                    directory: "docs/core/cli/ingest-commands",
                  },
                },
                {
                  label: "CLI Commands",
                  slug: "docs/core/cli/cli-commands",
                },
              ],
            },
            {
              label: "Capturable Executables",
              collapsed: true,
              autogenerate: {
                directory: "docs/core/capturable-executables",
              },
            },
            {
              label: "Concepts",
              collapsed: true,
              autogenerate: {
                directory: "docs/core/concepts",
              },
            },
            {
              label: "Admin",
              collapsed: true,
              autogenerate: {
                directory: "docs/core/admin",
              },
            },
          ],
        },
        {
          label: "surveilr Pro",
          items: [],
        },
        {
          label: "Standard Library",
          items: [
            {
              label: "RSSD Schema",
              autogenerate: {
                directory: "docs/standard-library/rssd-schema",
              },
            },
            {
              label: "Notebooks Schema",
              autogenerate: {
                directory: "docs/standard-library/notebooks-schema",
              },
            },
          ],
        },
        {
          label: "Patterns",
          items: [
            {
              label: "Discipline-centric Patterns",
              collapsed: true,
              autogenerate: {
                directory: "docs/patterns/disciplines",
              },
            },
          ],
        },
        {
          label: "Services",
          items: [],
        },
        {
          label: "Cookbook and Snippets",
          items: [],
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
        MobileMenuFooter:
          "./src/components/ui/starlight/MobileMenuFooter.astro",
        ThemeSelect: "./src/components/ui/starlight/ThemeSelect.astro",
      },
      head: [
        {
          tag: "meta",
          attrs: {
            property: "og:image",
            content: "https://www.surveilr.com" + "/social.webp",
          },
        },
        {
          tag: "meta",
          attrs: {
            property: "twitter:image",
            content: "https://www.surveilr.com" + "/social.webp",
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
