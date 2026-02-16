import { defineCollection, z } from "astro:content";
import { docsLoader, i18nLoader } from "@astrojs/starlight/loaders";
import { docsSchema, i18nSchema } from "@astrojs/starlight/schema";
import { glob } from "astro/loaders";


const ctaSection = defineCollection({
  loader: glob({
    pattern: "**/*.{md,mdx}",
    base: "src/content/sections",
  }),
  schema: z.object({
    title: z.string().optional(),
    description: z.string().optional(),
    enable: z.boolean().optional(),
    fill_button: z.object({
      label: z.string().optional(),
      link: z.string().optional(),
      enable: z.boolean().optional(),
    }),
    outline_button: z.object({
      label: z.string().optional(),
      link: z.string().optional(),
      enable: z.boolean().optional(),
    }),
  }),
});

const articles = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    publishDate: z.coerce.date(),
    author: z.string().optional(),
    tags: z.array(z.string()).optional(),
    draft: z.boolean().default(false),
  }),
});

const examples = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    difficulty: z.enum(['beginner', 'intermediate', 'advanced']).optional(),
    tags: z.array(z.string()).optional(),
    githubUrl: z.string().url().optional(),
  }),
});

const skills = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    category: z.string(),
    toolType: z.enum(['skill', 'command', 'agent', 'workflow']),
    featured: z.boolean().default(false),
    installUrl: z.string().url().optional(),
  }),
});

export const collections = {
  docs: defineCollection({
    loader: docsLoader(),
    schema: docsSchema(),
  }),
  i18n: defineCollection({ loader: i18nLoader(), schema: i18nSchema() }),
  ctaSection,
  articles,
  examples,
  skills,
};
