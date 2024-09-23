import ogImageSrc from "@images/social.png";

export const SITE = {
  title: "surveilr",
  organization: "Netspective Communications LLC",
  tagline: "Resource Surveillance & Integration Engine",
  description: "Prove Security, Quality, and Compliance with Auditable, Queryable, and Machine-Attestable Evidence",
  description_short: "Evidence Collection & Integration Engine",
  url: "https://surveilr.com",
  author: "Shahid N. Shah",
};

export const SEO = {
  title: SITE.title,
  description: SITE.description,
  structuredData: {
    "@context": "https://schema.org",
    "@type": "WebPage",
    inLanguage: "en-US",
    "@id": SITE.url,
    url: SITE.url,
    name: SITE.title,
    description: SITE.description,
    isPartOf: {
      "@type": "WebSite",
      url: SITE.url,
      name: SITE.title,
      description: SITE.description,
    },
  },
};

export const OG = {
  locale: "en_US",
  type: "website",
  url: SITE.url,
  title: `${SITE.title} :: Resource Surveillance & Integration Engine`,
  description: SITE.description,
  image: ogImageSrc,
};
