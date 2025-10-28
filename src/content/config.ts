// https://docs.astro.build/en/guides/content-collections/#defining-collections

import { defineCollection, z } from "astro:content";
import { docsSchema } from "@astrojs/starlight/schema";

const patternsCollection = defineCollection({
  type: "content",
  schema: ({ image }) =>
    z.object({
      title: z.string(),
      description: z.string(),
      main: z.object({
        id: z.number(),
        content: z.string(),
        imgCard: image(),
        imgMain: image(),
        imgAlt: z.string(),
      }),
      tabs: z.array(
        z.object({
          id: z.string(),
          dataTab: z.string(),
          title: z.string(),
        }),
      ),
      longDescription: z.object({
        title: z.string(),
        subTitle: z.string(),
        btnTitle: z.string().optional(),
        btnURL: z.string().optional(),
      }),
      descriptionList: z.array(
        z.object({
          title: z.string(),
          subTitle: z.string(),
        }),
      ),
      specificationsLeft: z.array(
        z.object({
          title: z.string(),
          subTitle: z.string(),
        }),
      ),
      specificationsRight: z.array(
        z.object({
          title: z.string(),
          subTitle: z.string(),
        }),
      ).optional(),
      tableData: z.array(
        z.object({
          feature: z.array(z.string()),
          description: z.array(z.array(z.string())),
        }),
      ).optional(),
      blueprints: z.object({
        first: image().optional(),
        second: image().optional(),
      }).optional(),
      liveDemo: z.object({
        btnTitle: z.string().optional(),
        btnURL: z.string().optional(),
      }).optional(),
      getStarted: z.object({
        btnTitle: z.string().optional(),
        btnURL: z.string().optional(),
      })
        .optional(),
    }),
});

const blogCollection = defineCollection({
  type: "content",
  schema: ({ image }) =>
    z.object({
      title: z.string(),
      description: z.string(),
      author: z.string(),
      role: z.string().optional(),
      authorImage: image(),
      authorImageAlt: z.string(),
      pubDate: z.date(),
      cardImage: image(),
      cardImageAlt: z.string(),
      readTime: z.number(),
      tags: z.array(z.string()).optional(),
      metaTitle: z.string().optional(),
    }),
});

const insightsCollection = defineCollection({
  type: "content",
  schema: ({ image }) =>
    z.object({
      title: z.string(),
      description: z.string(),
      // contents: z.array(z.string()),
      cardImage: image(),
      cardImageAlt: z.string(),
    }),
});
const legalCollection = defineCollection({
  type: "content",
  schema: () =>
    z.object({
      title: z.string(),
      metaTitle: z.string().optional(),
      description: z.string().optional(),
    }),
});

export const collections = {
  docs: defineCollection({ schema: docsSchema() }),
  "patterns": patternsCollection,
  "blog": blogCollection,
  "insights": insightsCollection,
  "legal": legalCollection,
};
