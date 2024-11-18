---
name: Meta Generator
site-quality-control-id: 1
description: HTML meta tags must include a generator tag specifying the CMS.
property-name: generator
impact: Missing generator can lead to confusion about the site's platform.
suggested-solution: Include a generator tag specifying the CMS used (e.g., WordPress, Drupal).
---

The generator tag specifies the software or CMS used to create the page (e.g.,
"WordPress 5.8", "Drupal 9"). This helps with support and troubleshooting,
though it can sometimes pose a security risk if outdated versions are disclosed.
