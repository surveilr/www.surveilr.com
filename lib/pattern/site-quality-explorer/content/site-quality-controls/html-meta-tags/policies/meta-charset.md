---
name: Meta Charset
site-quality-control-id: 1
description: HTML meta tags must include the charset specification.
property-name: charset
impact: Missing charset can cause incorrect rendering of text, especially for non-Latin languages.
suggested-solution: Specify the charset, such as UTF-8, to ensure proper character encoding and text display.
---

Define the character encoding using "UTF-8" to support various languages and
symbols, ensuring proper rendering of text across devices. The charset tag
should be placed within the <head> section and ideally be one of the first tags
to load for consistent encoding.
