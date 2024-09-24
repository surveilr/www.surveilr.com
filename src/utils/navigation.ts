// An array of links for navigation bar
const navBarLinks = [
  { name: "Home", url: "/" },
  { name: "Docs", url: "/docs" },
  { name: "Patterns", url: "/pattern" },
  { name: "Services", url: "/services" },
  { name: "Blog", url: "/blog" },
  { name: "Contact", url: "/contact" },
];
// An array of links for footer
const footerLinks = [
  {
    section: "Ecosystem",
    links: [
      { name: "Core vs. Patterns", url: "/blog/surveilr-core-vs-patterns"},
      { name: "Compliant Insecurity", url: "https://compliantinsecurity.com" },
      { name: "SQL Aide", url: "https://sql-aide.com" },
      { name: "Professional Services", url: "/services" },
    ],
  },
  {
    section: "Organization",
    links: [
      { name: "About Netspective", url: "https://www.netspective.com" },
      { name: "About Opsfolio", url: "https://www.opsfolio.com" },
      { name: "Blog", url: "/blog" },
      { name: "Discord", url: "#" },
    ],
  },
];
// An object of links for social icons
const socialLinks = {
  facebook: "https://www.facebook.com/",
  x: "https://twitter.com/",
  github: "https://github.com/mearashadowfax/ScrewFast",
  google: "https://www.google.com/",
  slack: "https://slack.com/",
};

export default {
  navBarLinks,
  footerLinks,
  socialLinks,
};