import { defineAction, ActionError } from "astro:actions";
import { db, Posts, eq } from "astro:db";
import { z } from "astro:schema";
import { purgeCache } from "@netlify/functions";

export const posts = {
  // Create post
  create: defineAction({
    accept: "form",
    input: z.object({
      title: z.string(),
      pubDate: z.string().transform((str) => new Date(str)),
      description: z.string(),
      author: z.string(),
      imageUrl: z.string().nullable(),
      imageAlt: z.string().nullable(),
      tags: z
        .string()
        .transform((str) => JSON.parse(str))
        .nullable(),
      slug: z.string(),
      content: z.string()
    }),
    handler: async (input) => {
      try {
        const post = await db.insert(Posts).values(input).returning();

        try {
          await purgeCache({ tags: ["posts"] });
        } catch (error) {
          console.error("Error purging cache:", error);
        }

        return {
          success: true as const,
          data: { post }
        };
      } catch (error) {
        throw new ActionError({
          code: "INTERNAL_SERVER_ERROR",
          message: "Error creating post"
        });
      }
    }
  }),

  // Read post
  get: defineAction({
    input: z.object({
      slug: z.string()
    }),
    handler: async ({ slug }) => {
      const post = await db.select().from(Posts).where(eq(Posts.slug, slug));
      if (!post) {
        throw new ActionError({
          code: "NOT_FOUND",
          message: "Post not found"
        });
      }
      return {
        success: true as const,
        data: { post }
      };
    }
  }),

  // Update post
  update: defineAction({
    accept: "form",
    input: z.object({
      id: z.number(),
      title: z.string().optional(),
      pubDate: z
        .string()
        .transform((str) => new Date(str))
        .optional(),
      description: z.string().optional(),
      author: z.string().optional(),
      imageUrl: z.string().nullable().optional(),
      imageAlt: z.string().nullable().optional(),
      tags: z
        .string()
        .transform((str) => JSON.parse(str))
        .nullable()
        .optional(),
      slug: z.string().optional(),
      content: z.string().optional()
    }),
    handler: async (input) => {
      try {
        const post = await db.update(Posts).set(input).where(eq(Posts.id, input.id)).returning();

        try {
          await purgeCache({ tags: ["posts"] });
        } catch (error) {
          console.error("Error purging cache:", error);
        }

        return {
          success: true as const,
          data: { post }
        };
      } catch (error) {
        throw new ActionError({
          code: "INTERNAL_SERVER_ERROR",
          message: "Error updating post"
        });
      }
    }
  }),

  // Delete post
  delete: defineAction({
    input: z.object({
      id: z.number()
    }),
    handler: async ({ id }) => {
      try {
        const post = await db.delete(Posts).where(eq(Posts.id, id));
        if (!post) {
          throw new ActionError({
            code: "NOT_FOUND",
            message: "Post not found"
          });
        }

        try {
          await purgeCache({ tags: ["posts"] });
        } catch (error) {
          console.error("Error purging cache:", error);
        }

        return {
          success: true as const,
          data: { post }
        };
      } catch (error) {
        throw new ActionError({
          code: "INTERNAL_SERVER_ERROR",
          message: "Error deleting post"
        });
      }
    }
  })
};
