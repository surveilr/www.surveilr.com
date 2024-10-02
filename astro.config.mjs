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
                  label: "CLI Commands",
                  link: "/docs/core/cli/cli-commands",
                },
              ],
            },
            {
              label: "Capturable Executables",
              collapsed: true,
              items: [
                {
                  label: "Content Extensibility with Capturable Executables",
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
            {
              label: "Concepts",
              collapsed: true,
              items: [
                {
                  label: "RSSD",
                  link: "/docs/core/concepts/resource-surveillance",
                },
                {
                  label: "WPAs",
                  link: "/docs/core/concepts/work-product-artifacts",
                },
              ],
            },
            {
              label: "Admin",
              collapsed: true,
              items: [
                {
                  label: "Merge",
                  link: "/docs/core/admin/merge",
                },
              ],
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
              collapsed: true,
              items: [
                {
                  label: "State Schema",
                  link: "/docs/standard-library/rssd-schema/state_schema",
                },
                {
                  label: "Behavior",
                  link: "/docs/standard-library/rssd-schema/behavior",
                },
                {
                  label: "Device",
                  link: "/docs/standard-library/rssd-schema/device",
                },
                {
                  label: "Device Party Relationship",
                  link: "/docs/standard-library/rssd-schema/device_party_relationship",
                },
                {
                  label: "Gender Type",
                  link: "/docs/standard-library/rssd-schema/gender_type",
                },
                {
                  label: "Orchestration Nature",
                  link: "/docs/standard-library/rssd-schema/orchestration_nature",
                },
                {
                  label: "Orchestration Session",
                  link: "/docs/standard-library/rssd-schema/orchestration_session",
                },
                {
                  label: "Orchestration Session Log",
                  link: "/docs/standard-library/rssd-schema/orchestration_session_log",
                },
                {
                  label: "Orchestration Session Entry",
                  link: "/docs/standard-library/rssd-schema/orchestration_session_entry",
                },
                {
                  label: "Orchestration Session Exec",
                  link: "/docs/standard-library/rssd-schema/orchestration_session_exec",
                },
                {
                  label: "Orchestration Session Issue",
                  link: "/docs/standard-library/rssd-schema/orchestration_session_issue",
                },
                {
                  label: "Orchestration Session Issue Relation",
                  link: "/docs/standard-library/rssd-schema/orchestration_session_issue_relation",
                },
                {
                  label: "Orchestration Session State",
                  link: "/docs/standard-library/rssd-schema/orchestration_session_state",
                },
                {
                  label: "Organization",
                  link: "/docs/standard-library/rssd-schema/organization",
                },
                {
                  label: "Organization Role",
                  link: "/docs/standard-library/rssd-schema/organization_role",
                },
                {
                  label: "Organization Role Type",
                  link: "/docs/standard-library/rssd-schema/organization_role_type",
                },
                {
                  label: "Party",
                  link: "/docs/standard-library/rssd-schema/party",
                },
                {
                  label: "Party Type",
                  link: "/docs/standard-library/rssd-schema/party_type",
                },
                {
                  label: "Party Relation",
                  link: "/docs/standard-library/rssd-schema/party_relation",
                },
                {
                  label: "Party Relation Type",
                  link: "/docs/standard-library/rssd-schema/party_relation_type",
                },
                {
                  label: "Person",
                  link: "/docs/standard-library/rssd-schema/person",
                },
                {
                  label: "Uniform Resource",
                  link: "/docs/standard-library/rssd-schema/uniform_resource",
                },
                {
                  label: "Uniform Resource Transform",
                  link: "/docs/standard-library/rssd-schema/uniform_resource_transform",
                },
                {
                  label: "Uniform Resource Ingest Resource Path Match Rule ",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_resource_path_match_rule",
                },
                {
                  label: "Uniform Resource Ingest Resource Path Rewrite Rule ",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_resource_path_rewrite_rule",
                },
                {
                  label: "Uniform Resource Ingest Session",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session",
                },
                {
                  label: "Uniform Resource Ingest Session Attachment",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_attachment",
                },
                {
                  label: "Uniform Resource Ingest Session Fs Path",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_fs_path",
                },
                {
                  label: "Uniform Resource Ingest Session Fs Path Entry",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_fs_path_entry",
                },
                {
                  label: "Uniform Resource Ingest Session IMAP Account",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_imap_account",
                },
                {
                  label: "Uniform Resource Ingest Session IMAP Account Folder",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_imap_acct_folder",
                },
                {
                  label:
                    "Uniform Resource Ingest Session IMAP Account Folder Message",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_imap_acct_folder_message",
                },
                {
                  label: "Uniform Resource Ingest Session PLM Account",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_account",
                },
                {
                  label: "Uniform Resource Ingest Session PLM Account Label",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_acct_label",
                },
                {
                  label: "Uniform Resource Ingest Session PLM Account Project",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_acct_project",
                },
                {
                  label:
                    "Uniform Resource Ingest Session PLM Account Project Issue",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_acct_project_issue",
                },
                {
                  label:
                    "Uniform Resource Ingest Session PLM Account Relationship",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_acct_relationship",
                },
                {
                  label: "Uniform Resource Ingest Session PLM Comment",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_comment",
                },
                {
                  label: "Uniform Resource Ingest Session PLM Issue Reaction",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_issue_reaction",
                },
                {
                  label: "Uniform Resource Ingest Session PLM Issue Type",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_issue_type",
                },
                {
                  label: "Uniform Resource Ingest Session PLM Milestone",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_milestone",
                },
                {
                  label: "Uniform Resource Ingest Session PLM Reaction",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_reaction",
                },
                {
                  label: "Uniform Resource Ingest Session PLM User",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_plm_user",
                },
                {
                  label: "Uniform Resource Ingest Session Task",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_task",
                },
                {
                  label: "Uniform Resource Ingest Session UDI-PGP SQL",
                  link: "/docs/standard-library/rssd-schema/ur_ingest_session_udi_pgp_sql",
                },
              ],
            },
            {
              label: "Notebooks Schema",
              collapsed: true,
              items: [
                {
                  label: "Notebooks Schema",
                  link: "/docs/standard-library/notebooks-schema/notebooks_schema",
                },
                {
                  label: "Assurance Schema",
                  link: "/docs/standard-library/notebooks-schema/assurance_schema",
                },
                {
                  label: "Code Notebook Cell",
                  link: "/docs/standard-library/notebooks-schema/code_notebook_cell",
                },
                {
                  label: "Code Notebook Kernel",
                  link: "/docs/standard-library/notebooks-schema/code_notebook_kernel",
                },
                {
                  label: "Code Notebook State",
                  link: "/docs/standard-library/notebooks-schema/code_notebook_state",
                },
              ],
            },
          ],
        },

        {
          label: "Patterns",
          items: [
            {
              label: "Discipline-centric Patterns",
              collapsed: true,
              items: [
                {
                  label: "Software Engineers",
                  link: "/docs/patterns/disciplines/software-engineer",
                },
                {
                  label: "System Engineers",
                  link: "/docs/patterns/disciplines/system-engineer",
                },
                {
                  label: "QA Engineers",
                  link: "/docs/patterns/disciplines/qa",
                },
                {
                  label: "Security Analysts/Engineers",
                  link: "/docs/patterns/disciplines/security-analyst",
                },
                {
                  label: "Compliance Officers",
                  link: "/docs/patterns/disciplines/compliance-officer",
                },
                {
                  label: "Regulatory Affairs Specialists",
                  link: "/docs/patterns/disciplines/regulatory-affairs",
                },
                {
                  label: "Project Managers",
                  link: "/docs/patterns/disciplines/project-manager",
                },
                {
                  label: "Configuration Management Specialists",
                  link: "/docs/patterns/disciplines/configuration",
                },
                {
                  label: "Database Administrators",
                  link: "/docs/patterns/disciplines/database-admin",
                },
                {
                  label: "Network Administrators",
                  link: "/docs/patterns/disciplines/network-admin",
                },
                {
                  label: "DevOps Engineers",
                  link: "/docs/patterns/disciplines/devops",
                },
                {
                  label: "Technical Writers",
                  link: "/docs/patterns/disciplines/technical-writer",
                },
                {
                  label: "UI/UX Designers",
                  link: "/docs/patterns/disciplines/user-experience",
                },
                {
                  label: "Legal Counsel",
                  link: "/docs/patterns/disciplines/legal-counsel",
                },
                {
                  label: "Subject Matter Experts",
                  link: "/docs/patterns/disciplines/subject-matter-expert",
                },
                {
                  label: "Customer Support Representatives",
                  link: "/docs/patterns/disciplines/customer-support",
                },
                {
                  label: "Training and Education Specialists",
                  link: "/docs/patterns/disciplines/training",
                },
                {
                  label: "Risk Management Specialists",
                  link: "/docs/patterns/disciplines/risk-management",
                },
                {
                  label: "Incident Response Team Members",
                  link: "/docs/patterns/disciplines/incident-response",
                },
                {
                  label: "Performance and Reliability Engineers",
                  link: "/docs/patterns/disciplines/performance-reliability",
                },
                {
                  label: "Procurement Specialists",
                  link: "/docs/patterns/disciplines/procurement-specialist",
                },
                {
                  label: "Auditors",
                  link: "/docs/patterns/disciplines/auditors",
                },
                {
                  label: "External Assessors",
                  link: "/docs/patterns/disciplines/external-assessor",
                },
                {
                  label: "Ethical Hackers",
                  link: "/docs/patterns/disciplines/ethical-hacker",
                },
                {
                  label: "Penetration Testers",
                  link: "/docs/patterns/disciplines/penetration-tester",
                },
                {
                  label: "Compliance Automation Specialists",
                  link: "/docs/patterns/disciplines/compliance-automation",
                },
                {
                  label: "Business Analysts",
                  link: "/docs/patterns/disciplines/business-analyst",
                },
                {
                  label: "Product Owners",
                  link: "/docs/patterns/disciplines/product-owner",
                },
                {
                  label: "Product Managers",
                  link: "/docs/patterns/disciplines/product-managers",
                },
                {
                  label: "Human Factors Engineers",
                  link: "/docs/patterns/disciplines/human-factors-engineers",
                },
                {
                  label: "System Integrators",
                  link: "/docs/patterns/disciplines/system-integrators",
                },
                {
                  label: "Change Management Specialists",
                  link: "/docs/patterns/disciplines/change-management",
                },
                {
                  label: "Legal and Regulatory Consultants",
                  link: "/docs/patterns/disciplines/legal-consultants",
                },
                {
                  label: "Supply Chain Managers",
                  link: "/docs/patterns/disciplines/supply-chain-managers",
                },
                {
                  label: "Facilities Managers",
                  link: "/docs/patterns/disciplines/facilities-managers",
                },
                {
                  label: "Medical Device Specialists",
                  link: "/docs/patterns/disciplines/medical-device-specialists",
                },
                {
                  label: "Aerospace Engineers",
                  link: "/docs/patterns/disciplines/aerospace-engineers",
                },
                {
                  label: "Automotive Engineers",
                  link: "/docs/patterns/disciplines/automotive-engineers",
                },
              ],
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
