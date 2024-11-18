---
name: Meta Http-Equiv
site-quality-control-id: 1
description: HTML meta tags must include http-equiv to define HTTP headers.
property-name: http-equiv
impact: Missing http-equiv meta tags can lead to improper HTTP header settings.
suggested-solution: Include http-equiv meta tags to define Content-Type, browser compatibility, and security headers effectively.
---

Use http-equiv to set HTTP headers in HTML, such as Content-Type,
X-UA-Compatible, and Content-Security-Policy. The most common use is setting the
Content-Type as "text/html; charset=UTF-8". This can also control browser
compatibility and security.
