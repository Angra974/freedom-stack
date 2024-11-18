import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";
import alpinejs from "@astrojs/alpinejs";
import netlify from "@astrojs/netlify";
import db from "@astrojs/db";
import clerk from "@clerk/astro";
import { copyTinymceToPublic } from "./src/integrations.ts";
import astroI18next from "astro-i18next";

// https://astro.build/config
export default defineConfig({
  integrations: [
    db(),
    tailwind(),
    alpinejs({
      entrypoint: "/src/entrypoint"
    }),
    copyTinymceToPublic(),
    clerk(),
    astroI18next()
  ],
  vite: {
    optimizeDeps: {
      exclude: ["astro:db"]
    }
  },
  output: "server",
  adapter: netlify(),
  experimental: {
    serverIslands: true
  }
});
