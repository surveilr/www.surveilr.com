# Resource Surveillance & Integration Engine (`surveilr`) Public Facing Omnibus Content

## Features

* **Astro-Powered:** Utilize a modern static-site generation framework.
* **Tailwind CSS:** Enjoy rapid UI development with a utility-first CSS framework.
* **Preline UI:** Implement prebuilt UI components for added elegance.
* **GSAP Integration:** Impress with professional and polished animations.
* **Markdown Content Collections:** Organize and manage our content seamlessly.
* **Starlight Documentation:** A sleek, user-friendly, full-featured documentation theme.
* **Internationalization (i18n):** Integrates Astro’s internationalization features.
* **SEO and Responsiveness:** Ensure our site is discoverable and accessible on any device.

### Installation

Start by installing the project dependencies. Open our terminal, navigate to the project's root directory, and execute:

```bash
npm install
```

This command will install all the necessary dependencies defined in the `package.json` file.

### Development Commands

With dependencies installed, you can utilize the following npm scripts to manage our project's development lifecycle:

* `npm run astro sync`: Make sure all the content collection types are sync'd
* `npm run dev`: Starts a local development server with hot reloading enabled.
* `npm run preview`: Serves our build output locally for preview before deployment.
* `npm run build`: Bundles our site into static files for production.

For detailed help with Astro CLI commands, visit [Astro's documentation](https://docs.astro.build/en/reference/cli-reference/).

## Deployment

### Building Your Site

Before deployment, you need to create a production build:

```bash
npm run build
```

This creates a `dist/` directory with our built site (configurable via [outDir in Astro](https://docs.astro.build/en/reference/configuration-reference/#outdir)).

## Project Structure

```md

lib/                      # surveilr Patterns code
src/                      # Astro site code
├── assets/               
│   ├── scripts/          # JS scripts
│   └── styles/           # CSS styles
├── components/           # Reusable components
│   ├── Meta.astro        # Meta component for SEO
│   ├── sections/         # Components for various sections of the website
│   ├── ThemeIcon.astro   # Component for toggling light/dark themes
│   └── ui/               # UI components categorized by functionality
├── content/              # Markdown files for blog posts, insights, patterns, and site configuration
│   ├── blog/
│   ├── docs/           
│   ├── insights/
│   ├── patterns/         
│   └── config.ts         # Contains site-wide configuration options
├── data_files/           # Strings stored as JSON files
├── images/               # Static image assets for use across the website
├── layouts/              # Components defining layout templates
│   └── MainLayout.astro  # The main wrapping layout for all pages
├── pages/                # Astro files representing individual pages and website sections
│   ├── 404.astro         # Custom 404 page
│   ├── blog/   
│   ├── fr/               # Localized content
│   ├── contact.astro     
│   ├── index.astro       # The landing/home page
│   ├── insights/         # TODO: need to make this singular         
│   ├── pattern/         
│   ├── robots.txt.ts     # Dynamically generates robots.txt
│   └── services.astro
└── utils/                # Shared utility functions and helpers

```

## Static Assets and Public Resources

Static files served directly to the browser are within the `public` directory at the root of the project.

```md

public/
└── banner-pattern.svg
    
```

### Editing Component Variables

Some components have properties defined as TypeScript variables within the component file. Here's an example of customizing the `FeaturesGeneral` component:

```typescript
// Define the string variables title and subTitle for the main heading and sub-heading text.
const title: string = "Meeting Industry Demands";
const subTitle: string =
  "At `surveilr`, we tackle the unique challenges encountered in the cybersecurity and compliance sectors.";
```

For collections of content like testimonials or statistics, edit the corresponding array of objects:

```typescript
// An array of testimonials
const testimonials: Testimonial[] = [...];

// An array of statistics
const statistics: StatProps[] = [...];
```

Modify the content within these arrays to reflect our data.

### Props in Component Instances

You can pass values to props directly in the page files for components used across pages. Here's an example of a `HeroSection` and `ClientsSection` component with inline props:

```html
<HeroSection
  subTitle="Top-quality hardware tools and expert construction services for every project need."
  primaryBtn="Start Exploring"
  primaryBtnURL="/explore"
/>

<ClientsSection
  title="Trusted by Industry Leaders"
  subTitle="Experience the reliability chosen by industry giants."
/>
```

Edit the props such as `title`, `subTitle`, `primaryBtn`, etc., to personalize these sections. Ensure that you maintain the structure and data types of the props.

### Customizing Navigation and Footer Links

Edit the `navigation.ts` file within the `utils` directory to manage navigation bar and footer links:

#### Navigation Bar Links

Edit the `navBarLinks` array to adjust navigation bar links:

```typescript
// An array of links for the navigation bar
export const navBarLinks: NavLink[] = [
  { name: "Home", url: "/" },
  { name: "Patterns", url: "/patterns" },
  { name: "Services", url: "/services" },
  { name: "Blog", url: "/blog" },
  { name: "Contact", url: "/contact" },
];
```

Replace `name` with the display text and `url` with the appropriate path to pages on our site.

#### Footer Links

Similarly, adjust the links displayed in the footer by editing the `footerLinks` array:

```typescript
// An array of links for the footer
export const footerLinks: FooterLinkSection[] = [
  {
    section: "Product",
    links: [
      { name: "Tools & Equipment", url: "/tools-equipment" },
      { name: "Construction Services", url: "/construction-services" },
      { name: "Pricing", url: "/pricing" },
    ],
  },
  {
    section: "Company",
    links: [
      { name: "About us", url: "/about" },
      { name: "Blog", url: "/blog" },
      { name: "Careers", url: "/careers" },
      { name: "Customers", url: "/customers" },
    ],
  },
];
```

Each section within the `footerLinks` array represents a group of links. Update the `section` value for the group heading and modify each link's `name` and `url` as needed.

#### Social Media Links

Replace the placeholder URLs in the `socialLinks` object with our social media profiles:

```typescript
// An object of links for social icons
export const socialLinks: SocialLinks = {
  facebook: "#",
  twitter: "#",
  github: "#",
  linkedin: "#",
  instagram: "#",
};
```

> [!NOTE]
> Remember to add complete and valid URLs for the navigation to function properly. These customizations will reflect throughout our Astro site, promoting consistency across all pages.

#### Additional Components

We also have `Navbar.astro` and `NavbarMegaMenu.astro` components located in `src/components/sections/navbar&footer`. Ensure to update these components if additional customization or specific configurations are required for the navigation bar or mega menu.

### Starlight Documentation

Key Features:

* **Site Navigation and Search**: Navigate through the documentation with ease using intuitive sidebar and built-in search functionality.
* **Internationalization**: Cater to a global audience with the ability to switch languages, making documentation accessible to everyone, everywhere.
* **SEO Friendly**: Optimized for search engines to help users quickly find the information they need.
* **Code Highlighting and Dark Mode**: Enhances code readability with syntax highlighting, and offers a dark mode to reduce eye strain for users.
* **Mobile Responsive Design**: Whether you're on a phone, tablet, or desktop, the documentation adapts to our screen size for optimal readability.

With Starlight, you gain access to a wealth of powerful features and integrations, along with extensive customization options to fit our needs.

> [!NOTE]
> Dive into the Starlight's comprehensive feature list and learn how it can streamline our development process by visiting the theme's [documentation site](https://starlight.astro.build/).

### Lenis for Smooth Scrolling

Experience buttery smooth scrolling with [Lenis](https://lenis.studiofreight.com/). We've integrated Lenis to provide an enhanced scrolling experience that's both fluid and responsive.

Here's how we set up Lenis in `src/assets/scripts/lenisSmoothScroll.js`:

```js
// src/assets/scripts/lenisSmoothScroll.js
import "@styles/lenis.css";

import Lenis from "lenis";

const lenis = new Lenis();

function raf(time) {
    lenis.raf(time);
    requestAnimationFrame(raf);
}

requestAnimationFrame(raf);
```

And then add it to `MainLayout.astro`:

```astro
<script>
  import "@scripts/lenisSmoothScroll.js";
</script>
```

Please note that smooth scrolling can affect accessibility and performance on some devices, so be sure to test it comprehensively across different environments.

> [!NOTE]
> If you would like to remove Lenis and return to the browser's default scrolling behavior, simply comment out or delete these lines from the `MainLayout.astro` file and `/starlight/Head.astro` if you are using Docs.

### GSAP Integration

For individual pattern pages, [GSAP](https://gsap.com/) has been integrated to add engaging animations that execute as soon as the pattern page loads. You can find and modify the GSAP configuration in the script sections of the pattern page file located at `src/pages/pattern/[...slug].astro` and the insights page at `src/pages/insights/[...slug].astro`:

```astro
<script>
  import { gsap } from "gsap";
  // Initialize GSAP animations...
</script>
```

**Customizing Animations:**

Please tailor the GSAP animations within this script to fit our project's look and feel. The provided example is a starting point, representing how to leverage GSAP for immediate visual impact as a pattern page loads.

**Modifying or Removing Animations:**

* To modify an animation, update the properties and parameters within the `gsap.from()` method, or add new GSAP animation calls as required.
* Should GSAP not be needed, or if you prefer a different animation method, simply remove the aforementioned script segment.

> [!NOTE]
> We've chosen to keep the integration lean and focused, but GSAP's comprehensive documentation can be referred to for more complex animations: [GSAP Documentation](https://gsap.com/docs/v3/).

### Hiding Scrollbar

To achieve a cleaner and more spacious design, the default scrollbar has been visually removed. While this choice fits the aesthetic goals of the project, it's important to consider that hiding scrollbars can sometimes affect accessibility and user experience. We recommend evaluating this design decision within the context of our user base and their needs.

For those who prefer custom-styled scrollbars, we suggest using the [tailwind-scrollbar](https://adoxography.github.io/tailwind-scrollbar/) plugin, which adds Tailwind CSS utilities for scrollbar styles, allowing for more controlled customization that can also meet accessibility standards.

> [!NOTE]
> If you wish to return the default scrollbar, you can comment out or remove the following CSS from `src/layouts/MainLayout.astro`:

```html
<style>
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>
```

Additionally, update the `<html>` tag to remove the `scrollbar-hide` class, resulting in:

```html
<html lang="en" class="scroll-pt-16">
```

### SEO Configuration

The SEO Configuration is designed to empower users in optimizing their website's visibility on search engines and social media platforms. This documentation outlines the implementation details and usage instructions for effectively managing SEO settings.

#### Using constants.ts

The SEO configuration has been centralized using the `constants.ts` file. This file manages SEO-related data such as page titles, descriptions, structured data, and Open Graph tags, providing a more structured and manageable approach to SEO management.

To customize SEO settings, modify the values in the `constants.ts` file. Key configurations include SITE, SEO, and OG, allowing developers to define site-wide SEO parameters.

```astro
// constants.ts

export const SITE = {
  title: "surveilr",
  // Other SITE properties...
};

export const SEO = {
  title: SITE.title,
  // Other SEO properties...
};

export const OG = {
  title: `${SITE.title}: Compliance Services`,
  // Other OG properties...
};
```

#### Applying Metadata in Layouts

When applying metadata within our layouts, such as `MainLayout.astro`, you can pass the desired metadata values as props to the `Meta` component:

```astro
---
// In MainLayout.astro file
const { meta } = Astro.props;

interface Props {
  meta?: string;
}
---

<Meta meta={meta} />
```

#### Passing Individual Schema

For page-specific SEO overrides, developers can pass individual schema properties within specific page files.

```astro
---
import { SITE } from "@/data_files/constants";
---
<MainLayout
  title={`Example Page | ${SITE.title}`}
  structuredData={{
    "@type": "WebPage",
    // Other structured data properties...
  }}
>
  <!-- Page content -->
</MainLayout>

```

With this setup, the Meta component receives the custom meta description and applies it to the page's metadata. If no custom value is passed, the default from `Meta.astro` will be used instead.

#### Extending Metadata for SEO

For a more robust SEO strategy, you can create additional properties in the `Meta.astro` component. For instance, you may want to include specific Open Graph tags for article publishing dates or tags for Twitter-specific metadata.

#### Structured Data and Rich Snippets

Structured data in JSON-LD format can be managed by the `Meta.astro` component, improving how search engines understand our page content and potentially enhancing search results with rich snippets. Modify the `structuredData` property with relevant [schema.org](https://schema.org) types and properties:

```astro
<MainLayout
  structuredData={{
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "surveilr",
    "url": "https://surveilr.com",
    "description": "Discover top-quality compliance tools and services"
  }}
>
```

#### Using Astro SEO Integrations

While the template provides a custom SEO solution, you may choose to utilize an Astro integration such as [Astro SEO](https://github.com/jonasmerlin/astro-seo#readme) for additional SEO features and optimizations. Integrating such a package might provide more automated metadata management and additional SEO-focused functionality.

### Robots.txt

`robots.txt` is dynamically generated using the code found in src/pages/robots.txt.ts. This configuration follows the example from the Astro Docs:

```ts
import type { APIRoute } from 'astro';

const robotsTxt = `
User-agent: *
Allow: /

Sitemap: ${new URL('sitemap-index.xml', import.meta.env.SITE).href}
`.trim();

export const GET: APIRoute = () => {
  return new Response(robotsTxt, {
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
    },
  });
};
```

### Markdown/MDX

#### Image Integration

The addition of `.vscode/settings.json` file in the root directory facilitates image integration directly into content collections within Markdown editors. This feature enables effortless creation of Markdown links with media files and seamless copying into the workspace.

##### Usage

* **Paste/Drop Images**: Activate by pressing <kbd>Shift</kbd> while dropping the file.
* **Markdown Link**: Image is linked using Markdown syntax `(![alt text](../../images/content/<path>))`.
* **File Handling**: Images are organized in `src/images/content/<path>`.

##### Example

Pasting `getting-started.png` into `src/content/post-1.md` results in:

* Adding `![alt text](../../images/content/post-1/getting-started.png)` to `post-1.md`.
* Moving the image file to `src/images/content/post-1/getting-started.png`.

> [!NOTE]
> Remember to press <kbd>Shift</kbd> while dropping images.

### Astro Integrations

Maximize our website's efficiency with these built-in Astro integrations:

* [Astro Compressor](https://github.com/sondr3/astro-compressor#readme): Automatically compresses Astro-generated site using gzip or brotli, ensuring faster load times.
Configure the compressor in `astro.config.mjs` file:

```mjs
   export default defineConfig({
     // ...other Astro configurations
    integrations: [...other Astro integrations, compressor({ gzip: false, brotli: true })],
   });
```

* [Astro Sitemap](https://docs.astro.build/en/guides/integrations-guide/sitemap/): Automatically generates a sitemap for a website, which is vital for SEO and helping search engine bots crawl pages effectively. To set up the Astro Sitemap, be sure to specify our site's base URL and any additional options in `astro.config.mjs` file:

```mjs
   export default defineConfig({
  // ...
  site: 'https://example.com',
  integrations: [sitemap()],
});
```

* [Bag of Tricks for Astro's View Tran­si­tions](https://github.com/martrapp/astro-vtbot#readme): is a collection of extensions and support aimed at enhancing Astro's view transitions. Whether you're looking to add flair to our website or streamline user experience, this toolkit offers various techniques to elevate our projects. In the template, it was used to add View Transitions to a Starlight docs.

### Flexibility with Integrations

The great thing about Astro is its rich ecosystem of integrations, allowing you to tailor project functionalities to our exact needs. Feel free to explore [Astro integrations page](https://astro.build/integrations/) and add additional capabilities as you see fit.

## Tools and Technologies

This project is built using a variety of tools and technologies that enhance its performance, maintainability, and developer experience. Below is a list of the key tools and their roles in the project:

### Preline UI

Interactive components like navbars, modals, and accordions are built using [Preline UI](https://preline.co), a comprehensive open-source component library.

### Tailwind CSS

Styling across our project leverages the utility-first classes offered by [Tailwind CSS](https://tailwindcss.com). This methodology allows us to create custom layouts and components with speed and efficiency.

To ensure consistent code formatting, particularly for class sorting, we have integrated the `prettier-plugin-tailwindcss` [plugin](https://github.com/tailwindlabs/prettier-plugin-tailwindcss). The following configuration is set in the `.prettierrc` file at the root of the project:

```json
{
  "plugins": ["prettier-plugin-tailwindcss"]
}
```

### Deployment and Security

We deploy our project on [Vercel](https://vercel.com), capitalizing on their robust platform for seamless CI/CD workflows. Using `vercel.json`, we set stringent security headers and caching policies, ensuring adherence to security and performance best practices:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; [other-directives]"
        },
        "Additional security headers..."
      ]
    }
  ]
}
```

### HTML Minification

For optimal site performance, we post-process our HTML files with `process-html.mjs`, a [custom script](https://straffesites.com/en/blog/optimize-astro-html-post-build) that minifies HTML after the build phase to reduce file size and improve load times.

Here is a snippet from our HTML minification script in `process-html.mjs`:

```mjs
/process-html.mjs
// Post-build HTML minification script snippet
// ...
await Promise.all(
  files.map(async (file) => {
    // File processing and minification logic
  })
);
```

We encourage you to refer to the detailed documentation for each tool to fully understand their capabilities and how they contribute to the project:

* [Preline UI Documentation](https://preline.co/docs)
* [Tailwind CSS Documentation](https://tailwindcss.com/docs)
* [Vercel Documentation](https://vercel.com/docs)
* [html-minifier-terser Documentation](https://github.com/terser/html-minifier-terser)
