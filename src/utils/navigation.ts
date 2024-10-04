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
      { name: "Core vs. Patterns", url: "/blog/surveilr-core-vs-patterns" },
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
      { name: "Discord", url: "https://discord.gg/fYHv3zzB" },
    ],
  },
];
// An object of links for social icons
const socialLinks = {
  linkedIn: "https://www.linkedin.com/company/netspective-communications-llc",
  x: "https://twitter.com/netspective",
  github: "https://github.com/surveilr",
  google: "https://plus.google.com/+Netspective",
  discord: "https://discord.gg/fYHv3zzB",
};

export default {
  navBarLinks,
  footerLinks,
  socialLinks,
};
