#!/bin/bash

# Create project directory


# Install dependencies
pnpm install astro-i18next i18next

# Create necessary directories
mkdir -p src/i18n/locales/en src/i18n/locales/fr

# Create configuration files
cat <<EOF > src/i18n/config.ts
import { defineConfig } from "astro-i18next";

export const i18nConfig = defineConfig({
  defaultLocale: "en",
  locales: ["en", "fr"],
  namespaces: ["common"],
  i18next: {
    debug: true,
    fallbackLng: "en",
    load: "languageOnly",
    interpolation: {
      escapeValue: false,
    },
  },
});
EOF

cat <<EOF > src/i18n/locales/en/common.json
{
  "welcome": "Welcome to Freedom Stack",
  "description": "A full-stack Astro starter kit that feels freeing and is free."
}
EOF

cat <<EOF > src/i18n/locales/fr/common.json
{
  "welcome": "Bienvenue sur Freedom Stack",
  "description": "Un kit de démarrage full-stack Astro qui se sent libérateur et est gratuit."
}
EOF

# Create Astro configuration file
cat <<EOF > astro.config.mjs
import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";
import alpinejs from "@astrojs/alpinejs";
import netlify from "@astrojs/netlify";
import db from "@astrojs/db";
import clerk from "@clerk/astro";
import { copyTinymceToPublic } from "./src/integrations.ts";
import { i18nConfig } from "./src/i18n/config";

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
    i18nConfig()
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
EOF

# Create example Astro page
cat <<EOF > src/pages/index.astro
---
import Layout from "@/layouts/Layout.astro";
import { useTranslation } from "astro-i18next";

const { t } = useTranslation();
---

<Layout title={t("welcome")}>
  <p>{t("description")}</p>
</Layout>
EOF

# Create example layout file
cat <<EOF > src/layouts/Layout.astro
---
import { SEO } from "astro-seo";
import Icon from "astro-iconify";
import "@/global.css";

interface Props {
  title: string;
  description?: string;
  bodyClasses?: string;
  canonicalUrl?: string;
  faviconUrl?: string;
  ogImageUrl?: string;
}

const { title, description = "", bodyClasses, canonicalUrl, faviconUrl, ogImageUrl = "/og-image.png" } = Astro.props;
---

<!doctype html>
<html
  lang="en"
  x-data={`{
    toastMessage: '',
    toastErrorMessage: ''
  }`}
  class="bg-slate-50"
>
  <!-- "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life." John 3:16 NIV -->
  <head>
    <meta charset="UTF-8" />
    <meta name="description" content={description || title} />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no, viewport-fit=cover"
    />
    <meta name="generator" content={Astro.generator} />
    <link rel="sitemap" href="/sitemap.xml" />

    <slot name="head" />

    <SEO
      charset="utf-8"
      title={title}
      description={description}
      canonical={canonicalUrl || Astro.url}
      openGraph={{
        basic: {
          title: title,
          type: "website",
          image: ogImageUrl
        },
        optional: {
          description: description
        }
      }}
      twitter={{
        card: "summary_large_image",
        title: title,
        description: description,
        image: ogImageUrl,
        site: canonicalUrl || Astro.url.href,
        imageAlt: description
      }}
      extend={{
        link: [
          {
            rel: "icon",
            href: faviconUrl || "/favicon.svg",
            type: faviconUrl ? "image/png" : "image/svg+xml"
          }
          // {
          //   rel: "apple-touch-icon",
          //   href: "/apple-touch-icon.png"
          // }
        ]
      }}
    />
  </head>

  <body class={`max-w-screen w-full ${bodyClasses}`}>
    <div
      x-data={`{
        backupOfToastMessage: '',
        init() {
          $watch('toastMessage', () => {
            if (toastMessage) {
              this.backupOfToastMessage = toastMessage
            }
          })
        }
      }`}
      x-cloak
      x-show="toastMessage"
      x-transition:enter="transition ease-out duration-300"
      x-transition:enter-start="opacity-0 transform -translate-y-2"
      x-transition:enter-end="opacity-100 transform translate-y-0"
      x-transition:leave="transition ease-in duration-300"
      x-transition:leave-start="opacity-100 transform translate-y-0"
      x-transition:leave-end="opacity-0 transform -translate-y-2"
      x-init="setTimeout(() => toastMessage = '', 5000)"
      class="z-30 toast toast-top toast-center max-w-sm w-full"
    >
      <div role="alert" class="max-w-sm w-full shadow-lg alert alert-info bg-cyan-100 border-cyan-200 text-cyan-900">
        <Icon pack="lucide" name="check-circle" height={20} width={20} class="shrink-0" />
        <span class="p-0 m-0 w-full text-wrap inline-block" x-text="toastMessage || '-'"></span>
      </div>
    </div>

    <div
      x-data={`{
        backupOfToastErrorMessage: '',
        init() {
          $watch('toastErrorMessage', () => {
            if (toastErrorMessage) {
              this.backupOfToastErrorMessage = toastErrorMessage
            }
          })
        }
      }`}
      x-cloak
      x-show="toastErrorMessage"
      x-transition:enter="transition ease-out duration-300"
      x-transition:enter-start="opacity-0 transform -translate-y-2"
      x-transition:enter-end="opacity-100 transform translate-y-0"
      x-transition:leave="transition ease-in duration-300"
      x-transition:leave-start="opacity-100 transform translate-y-0"
      x-transition:leave-end="opacity-0 transform -translate-y-2"
      class="z-30 toast toast-top toast-center max-w-sm w-full"
    >
      <div
        role="alert"
        class="max-w-sm w-full grid grid-cols-[auto_1fr] gap-2 shadow-lg alert alert-error bg-red-100 border-red-200 text-red-900"
      >
        <Icon pack="lucide" name="octagon-alert" height={20} width={20} class="shrink-0" />
        <p class="p-0 m-0 w-full text-wrap inline-block" x-text="backupOfToastErrorMessage || '-'" class="w-full"></p>
      </div>
    </div>

    {
      /* The prose class from @tailwindcss/typography plugin provides beautiful typographic defaults for HTML content like articles, blog posts, and documentation. It styles headings, lists, code blocks, tables etc. */
    }
    <div class="prose max-w-[unset]">
      <slot />
    </div>
  </body>
</html>

<script>
  // @ts-ignore
  import * as htmx from "htmx.org";

  window.htmx = htmx;
</script>
EOF

# Create example global CSS file
cat <<EOF > src/global.css
/* Add CSS styles below. */
.example-class {
  /* You can even apply Tailwind classes here. */
  @apply bg-red-500 text-white;
}

/* Override some of the Tailwind .prose CSS */
.prose h1,
.prose h2,
.prose h3,
.prose h4,
.prose h5,
.prose h6 {
  @apply m-0 mb-2;
  text-wrap: balance;
}

.balanced {
  max-inline-size: 50ch;
  text-wrap: balance;
}

/* Daisy UI Overrides */
.breadcrumbs > ul > li,
.breadcrumbs > ol > li {
  @apply p-0;
}

.text-muted {
  @apply text-gray-500;
}

.container {
  max-width: 768px;
}

/* Alpine.js */
[x-cloak] {
  display: none;
}

.btn-outline {
  @apply border-2 border-slate-200 hover:border-slate-200 hover:bg-inherit hover:text-inherit;
}

.btn-primary {
  @apply text-white;
}
EOF

# Create example entrypoint file
cat <<EOF > src/entrypoint.ts
import type { Alpine } from "alpinejs";
// @ts-ignore - Has no associated types.
import intersect from "@alpinejs/intersect";
// @ts-ignore - Has no associated types.
import persist from "@alpinejs/persist";
// @ts-ignore - Has no associated types.
import collapse from "@alpinejs/collapse";
// @ts-ignore - Has no associated types.
import mask from "@alpinejs/mask";

export default (Alpine: Alpine) => {
  Alpine.plugin(intersect);
  Alpine.plugin(persist);
  Alpine.plugin(collapse);
  Alpine.plugin(mask);
};
EOF

# Create example environment type definitions
cat <<EOF > src/env.d.ts
/// <reference types="astro/client" />
/// <reference types="@clerk/astro/dist/types" />
/// <reference path="../.astro/db-types.d.ts" />
/// <reference path="../.astro/types.d.ts" />

import * as htmx from "htmx.org";
import type { Auth, UserResource } from "@clerk/types";

declare global {
  interface Window {
    Alpine: import("alpinejs").Alpine;
    htmx: typeof htmx;
  }

  namespace App {
    interface Locals {
      auth: () => Auth;
      currentUser: () => Promise<UserResource | null>;
    }
  }
}

// https://docs.astro.build/en/guides/environment-variables/#intellisense-for-typescript
interface ImportMetaEnv {
  /** https://docs.astro.build/en/guides/astro-db/#libsql */
  readonly ASTRO_DB_REMOTE_URL: string;
  /** https://docs.astro.build/en/guides/astro-db/#libsql */
  readonly ASTRO_DB_APP_TOKEN: string;
  /** https://clerk.com/docs/deployments/clerk-environment-variables#clerk-environment-variables */
  readonly PUBLIC_CLERK_PUBLISHABLE_KEY: string;
  /** https://clerk.com/docs/deployments/clerk-environment-variables#clerk-environment-variables */
  readonly CLERK_SECRET_KEY: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
EOF

# Create example package.json
cat <<EOF > package.json
{
  "name": "freedom-stack",
  "type": "module",
  "version": "1.2.1",
  "scripts": {
    "check:env": "node scripts/check-env.js",
    "dev": "npm run check:env && astro dev",
    "dev:host": "npm run check:env && astro dev --host",
    "start": "npm run check:env && astro dev",
    "build": "astro check && astro build --remote",
    "preview": "astro preview",
    "format": "prettier -w .",
    "packages:update": "npx npm-check-updates -u",
    "db:update-schemas": "astro db push --remote",
    "host:deploy": "npx netlify deploy",
    "host:login": "npx netlify login"
  },
  "dependencies": {
    "@alpinejs/collapse": "^3.14.3",
    "@alpinejs/intersect": "^3.14.3",
    "@alpinejs/mask": "^3.14.3",
    "@alpinejs/persist": "^3.14.3",
    "@astrojs/alpinejs": "^0.4.0",
    "@astrojs/check": "^0.9.4",
    "@astrojs/db": "^0.14.3",
    "@astrojs/netlify": "^5.5.4",
    "@astrojs/tailwind": "^5.1.2",
    "@clerk/astro": "^1.4.1",
    "@iconify-json/lucide": "^1.2.10",
    "@iconify-json/lucide-lab": "^1.2.1",
    "alpinejs": "^3.14.3",
    "astro": "^4.16.7",
    "astro-iconify": "^1.2.0",
    "astro-seo": "^0.8.4",
    "better-sqlite3": "^11.5.0",
    "htmx.org": "2.0.1",
    "isomorphic-dompurify": "^2.16.0",
    "marked": "^14.1.3",
    "tinymce": "^7.4.1"
  },
  "devDependencies": {
    "@tailwindcss/typography": "^0.5.15",
    "@types/alpinejs": "^3.13.10",
    "@types/better-sqlite3": "^7.6.11",
    "daisyui": "^4.12.14",
    "netlify-cli": "^17.37.2",
    "prettier": "^3.3.3",
    "prettier-plugin-astro": "^0.14.1",
    "tailwindcss": "^3.4.14",
    "typescript": "^5.6.3"
  }
}
EOF

# Create example tailwind.config.mjs
cat <<EOF > tailwind.config.mjs
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      container: {
        center: true,
        padding: "24px",
        maxWidth: "1000px"
      }
    }
  },
  // Change your theme at https://daisyui.com/docs/themes/.
  daisyui: {
    themes: [
      {
        mytheme: {
          primary: "#1f2937",
          secondary: "#f5f5f4",
          accent: "#6d28d9",
          neutral: "#d1d5db",
          "base-100": "#f3f4f6",
          info: "#a5f3fc",
          success: "#86efac",
          warning: "#fca5a5",
          error: "#fb7185",
          "--rounded-btn": "99px"
        }
      }
    ]
  },
  plugins: [require("@tailwindcss/typography"), require("daisyui")],
  darkMode: "class"
};
EOF

# Create example tsconfig.json
cat <<EOF > tsconfig.json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "outDir": "dist",
    "jsx": "react-jsx",
    "jsxImportSource": "react",
    "strictNullChecks": true,
    "allowJs": true,
    "baseUrl": ".",
    "paths": {
      "@/*": [
        "src/*"
      ],
      "@sections/*": [
        "src/components/sections/*"
      ]
    }
  },
  "exclude": [
    "node_modules",
    "dist",
    "public"
  ]
}
EOF

# Create example middleware file
cat <<EOF > src/middleware.ts
import { clerkMiddleware, createRouteMatcher } from "@clerk/astro/server";

const isProtectedRoute = createRouteMatcher(["/dashboard(.*)"]);

export const onRequest = clerkMiddleware((auth, context) => {
  const { redirectToSignIn, userId } = auth();

  if (!userId && isProtectedRoute(context.request)) {
    // Add custom logic to run before redirecting

    return redirectToSignIn();
  }
});
EOF

# Create example integration file
cat <<EOF > src/integrations.ts
import type { AstroIntegration } from "astro";

async function cpPkg(sourceDir: string, destDir: string) {
  const fs = await import("fs");
  const path = await import("path");

  const sourcePath = path.resolve(sourceDir);
  const destinationPath = path.resolve(destDir);

  // Ensure the public directory exists
  if (!fs.existsSync(path.dirname(destinationPath))) {
    fs.mkdirSync(path.dirname(destinationPath), { recursive: true });
  } else {
    return "";
  }

  // Copy entire directory from node_modules to public directory
  fs.cpSync(sourcePath, destinationPath, { recursive: true });

  // Log the successful copy
  console.log(\`\${sourcePath} has been copied to the public folder.\`);
}

// Self-host TinyMCE so that it's allowed to be on the free-tier.
export function copyTinymceToPublic(): AstroIntegration {
  return {
    name: "copy-tinymce-to-public",
    hooks: {
      "astro:config:setup": async () => {
        await cpPkg("./node_modules/tinymce/", "./public/tinymce/");
      },
      "astro:build:setup": async () => {
        await cpPkg("./node_modules/tinymce/", "./public/tinymce/");
      }
    }
  };
}
EOF

# Create example check-env script
cat <<EOF > scripts/check-env.js
import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Read .env.example to get required variables
const envExample = readFileSync(join(__dirname, "../.env.example"), "utf8");
const requiredVars = envExample
  .split("\n")
  .filter((line) => line && !line.startsWith("#"))
  .map((line) => line.split("=")[0]);

// Read .env file
let envVars = {};
try {
  const envFile = readFileSync(join(__dirname, "../.env"), "utf8");
  envVars = Object.fromEntries(
    envFile
      .split("\n")
      .filter((line) => line && !line.startsWith("#"))
      .map((line) => line.split("=").map((part) => part.trim()))
  );
} catch (error) {
  console.error("\x1b[33m%s\x1b[0m", "No .env file found. Creating one from .env.example...");
  try {
    const { execSync } = require("child_process");
    execSync("cp .env.example .env");
    console.log("\x1b[32m%s\x1b[0m", "Created .env file from .env.example");
    const exampleEnv = readFileSync(join(__dirname, "../.env.example"), "utf8");
    envVars = Object.fromEntries(
      exampleEnv
        .split("\n")
        .filter((line) => line && !line.startsWith("#"))
        .map((line) => line.split("=").map((part) => part.trim()))
    );
  } catch (error) {
    console.error("\x1b[31m%s\x1b[0m", "Error: Failed to create .env file!");
    process.exit(1);
  }
  process.exit(1);
}

// Check if all required variables are set
const missingVars = requiredVars.filter((varName) => !envVars[varName]);

if (missingVars.length > 0) {
  console.error("\x1b[31m%s\x1b[0m", "Error: You have some missing required environment variables:");

  // Read .env.example again to get comments
  const envExampleLines = envExample.split("\n");
  const varComments = new Map();

  let currentComment = "";
  envExampleLines.forEach((line) => {
    if (line.startsWith("#")) {
      currentComment = line.substring(1).trim();
    } else if (line && !line.startsWith("#")) {
      const varName = line.split("=")[0];
      varComments.set(varName, currentComment);
    }
  });

  missingVars.forEach((varName) => {
    console.error("\x1b[33m%s\x1b[0m", \`- \${varName}\`);
    const comment = varComments.get(varName);
    if (comment) {
      console.error("\x1b[36m%s\x1b[0m", \`  → \${comment}\`);
    }
  });

  console.error("\n\x1b[37m%s\x1b[0m", "Please set these variables in your .env file before running the dev server.");
  process.exit(1);
}
EOF

# Create example netlify.toml
cat <<EOF > netlify.toml
[build]
  command = "npm run build"
  publish = "dist"

[template]
  [template.environment]
    ASTRO_DB_REMOTE_URL = "Your Turso database URL"
    ASTRO_DB_APP_TOKEN = "Your Turso database app token"
    CLERK_SECRET_KEY = "Your Clerk secret key"
    CLERK_PUBLISHABLE_KEY = "Your Clerk publishable key"

# Force HTTPS
[[redirects]]
  from = "http://*"
  to = "https://:splat"
  status = 301
  force = true
EOF

# Create example LICENSE
cat <<EOF > LICENSE
MIT License

Copyright (c) 2024 Cameron Pak, FAITH TOOLS SOFTWARE SOLUTIONS, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Create example README.md
cat <<EOF > README.md
# Freedom Stack • Full-Stack Starter Kit

[![Netlify Status](https://api.netlify.com/api/v1/badges/78803fc4-5d36-4efb-82cd-2daeb5684fb6/deploy-status)](https://app.netlify.com/sites/freedom-stack/deploys) [![Github Stars](https://img.shields.io/github/stars/cameronapak/freedom-stack?style=flat-square)](https://github.com/cameronapak/freedom-stack/stargazers)

An Astro-based full-stack starter kit that feels freeing, and is free. Make development fun again. [See the demo site](https://freedom.faith.tools).

I wanted to provide a stack that's powerful like Ruby on Rails _("The One Person Framework")_, but with the ease and "vanilla" web dev feel of Astro.

<a href="https://app.netlify.com/start/deploy?repository=https://github.com/cameronapak/freedom-stack"><img src="https://www.netlify.com/img/deploy/button.svg" alt="Deploy to Netlify"></a>

![freedom stack](public/og-image.png)

## Learning Resources 📚

### The Frontend Layer

If you want to learn more about the frontend layer, I recommend the [Astro Web Framework Crash Course by freeCodeCamp](https://www.youtube.com/watch?v=e-hTm5VmofI).

### The Interactivity Layer

If you want to learn more about Alpine.js, I recommend [Learn Alpine.js on codecourse](https://codecourse.com/courses/learn-alpine-js).

### The Database Layer

If you want to learn more about the database layer, I recommend learning from [High Performance SQLite course](https://highperformancesqlite.com/), sponsored by [Turso](https://turso.tech/).

### The Philosophy Layer

A starter kit like this can save hours, days, or even weeks of development time. However, it's not enough just to have the baseline. You will need to have a philosophy around building a site or web app, so that you can make the most of the tooling and minimize wasting time. I recommend reading Getting Real by 37signals. [It's free to read online](https://books.37signals.com/8/getting-real). _(While the book says a few choice words, it's a great, practical resource for building great software.)_

## Here's What's Included 🔋🔋🔋

Ogres have layers. Onions have layers. Parfaits have layers. And, Freedom Stack has layers!

### UI Layer

- [Astro](https://astro.build/) - A simple web metaframework.
- [Tailwind CSS](https://tailwindcss.com/) - For styling.
- [Preline UI](https://preline.co/) - Tailwind-based HTML components.
- [Daisy UI](https://daisyui.com/) - For a Bootstrap-like UI CSS component
  library, built upon Tailwind.
- [Lucide Icons](https://lucide.dev/) - For a beautiful icon library.

### Interactivity Layer

- [TypeScript](https://www.typescriptlang.org/) - For type safety.
- [AlpineJS](https://alpinejs.dev/) - For state management and interactivity.
- [HTMX](https://htmx.org/) - For sending HTML partials/snippets over the wire.

### Backend Data Layer

- [Astro DB](https://astro.build/db) - Astro DB is a fully managed SQL database
  that is fast, lightweight, and ridiculously easy-to-use.
- [Drizzle ORM](https://orm.drizzle.team/) - Use your database without having to know or worry about SQL syntax.
- [Clerk](https://clerk.com/) - For authentication.

### Bonus Layer

- A well-prompted `.cursorrules` file for [Cursor's AI IDE](https://cursor.com/) to be a friendly guide helping you using this stack easier.

## Get Started 🚀

### 1. Setup Your Codebase

To create your own instance of this codebase, click the "Use this template"
button on the [repo's home page](https://github.com/cameronapak/freedom-stack).

Then, clone your new repo to your local machine.

### 2. Setup Your Database

We use [Turso](https://turso.tech/) for the fully-managed libSQL database. [Follow these instructions to get started with Turso](https://docs.astro.build/en/guides/astro-db/#getting-started-with-turso).

_[Want to visualize your data through a GUI?](https://docs.turso.tech/local-development#connecting-a-gui)_

### 3. Setup Your Authentication Provider

Create a new [Clerk](https://clerk.com/) project.

### 4. Set Environment Variables

Let's create the `.env` file by copying the `.env.example` file.

\`\`\`bash
cp .env.example .env
\`\`\`

This project uses the following environment variables:

| Variable                       | Description                              | Required | More Info                                                                                                 |
| ------------------------------ | ---------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------- |
| \`ASTRO_DB_REMOTE_URL\`          | The connection URL to your libSQL server | Required | [Astro DB](https://docs.astro.build/en/guides/astro-db/#connect-a-libsql-database-for-production)         |
| \`ASTRO_DB_APP_TOKEN\`           | The auth token to your libSQL server     | Required | [Astro DB](https://docs.astro.build/en/guides/astro-db/#connect-a-libsql-database-for-production)         |
| \`CLERK_SECRET_KEY\`             | Secret key for Clerk authentication      | Required | [Clerk](https://clerk.com/docs/deployments/clerk-environment-variables#clerk-publishable-and-secret-keys) |
| \`PUBLIC_CLERK_PUBLISHABLE_KEY\` | Publishable key for Clerk authentication | Required | [Clerk](https://clerk.com/docs/deployments/clerk-environment-variables#clerk-publishable-and-secret-keys) |

Make sure to set these variables in your environment or `.env` file before running the application.

### 5. Run the Development Server

Install the dependencies.

\`\`\`bash
npm install
\`\`\`

Then, run the development server.

\`\`\`bash
npm run dev
\`\`\`

Viola! Your development server is now running on [\`localhost:4321\`](http://localhost:4321).

### 6. Have fun!

Create because you love creating. Make development fun again!

---

## Host Your Project ☁️

Host your site with [Netlify](https://netlify.com) in under a minute.

First, you must login to Netlify:

\`\`\`bash
npm run host:login
\`\`\`

Then, you can deploy your site with:

\`\`\`bash
npm run host:deploy
\`\`\`

> [!IMPORTANT]
> Remember to set the environment variables in Netlify so that it builds successfully.

[Learn more about hosting Astro sites on Netlify](https://docs.astro.build/en/guides/deploy/netlify/).

---

## Vision ❤️

I dream of a lightweight, simple web development stack that invokes a fun web
experience at the cheapest possible maintainance, backend, and server cost. As
close to free as possible.

### Core Principles

- **Approachable** — I want those new to web development to feel comfortable
  using this stack. Things like database management should feel intuitive.
  Remove barriers of traditional JavaScript frameworks, such as excessive
  boilerplate code or intense state management. Go back to the basics of web
  development. (_While this is not vanilla, the dev experience will feel very
  natural._)
- **Flow-able** — Use an HTML-first approach, where almost all of the work is
  done on the DOM layer: styling, structuring, and interactivity. An opinionated
  stack helps you avoid analysis paralysis of trying to decide what tooling to
  pick or how to put things together. Instead, spend your thinking time
  building. This simple stack helps you focus and get in the flow of code
  faster. Fast setup. Fast building. Fast shipping.
- **Pocket-friendly** — Using this stack will be financially maintainable to
  anyone, especially indie hackers and those creating startup sites / web apps.

## Showcase 🏆

- [faith.tools](https://faith.tools)
- [freedom](https://freedom.melos.church)
- [Be Still](https://ft-be-still.netlify.app)
- [kit](https://kit.faith.tools)

Have a project that uses Freedom Stack? [Open a PR](https://github.com/cameronapak/freedom-stack) to add it to the list!

## Available Scripts ⚡

| Command                     | Description                                      |
| --------------------------- | ------------------------------------------------ |
| \`npm run dev\`               | Start the development server                     |
| \`npm run dev:host\`          | Start development server accessible from network |
| \`npm run build\`             | Build the production site with remote database   |
| \`npm run preview\`           | Preview the built site locally                   |
| \`npm run format\`            | Format all files using Prettier                  |
| \`npm run packages:update\`   | Update all packages to their latest versions     |
| \`npm run db:update-schemas\` | Push database schema changes to remote database  |

## Contributions 🤝

Contributions welcomed. Please
[open an issue](https://github.com/cameronapak/astwoah-stack/issues) if you'd
like to contribute.

<a href="https://github.com/cameronapak/freedom-stack/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cameronapak/freedom-stack" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

---

## License 📜

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Code of Conduct 📜

See the [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) file for details.

---

Freedom Stack is made with 🕊️ by [Cameron Pak](https://cameronpak.com), brought to you by [faith.tools](https://faith.tools).
EOF

# Create example CODE_OF_CONDUCT.md
cat <<EOF > CODE_OF_CONDUCT.md
# Code of Conduct

## Our Pledge

Freedom Stack is committed to being a welcoming community that empowers developers to create with freedom and joy. We pledge to make participation in our project and community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

## Our Values

- **Approachability**: We believe in making web development accessible to everyone, regardless of their experience level. We welcome questions, encourage learning, and support those new to our stack.

- **Flow-ability**: We value simplicity and focus. Our community interactions should reflect this by being clear, helpful, and free from unnecessary complexity or gatekeeping.

- **Pocket-friendly**: We work hard to make full-stack web development financially accessible to everyone.

- **Generosity**: We believe that it is better to give than to receive, a lesson taught by Jesus in the Bible. While this project is created by a Christian, anyone can contribute to this project.

## Expected Behavior

- Use welcoming and kind language
- Be respectful to one another
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members
- Help others learn and grow

## Unacceptable Behavior

The following behaviors are considered harassment and are unacceptable:

- The use of sexualized language or imagery
- Personal attacks or derogatory comments
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate in a professional setting
- Trolling, insulting/derogatory comments, and personal or political attacks
- Promoting discrimination of any kind

## Enforcement Responsibilities

Project maintainers are responsible for clarifying and enforcing standards of acceptable behavior and will take appropriate and fair corrective action in response to any behavior that they deem inappropriate, threatening, offensive, or harmful.

## Reporting Process

If you experience or witness unacceptable behavior, please report it by:

1. Opening an issue in the repository
2. Contacting the project maintainers directly
3. Emailing [Cameron Pak](https://letterbird.co/cameronandrewpak)

All complaints will be reviewed and investigated promptly and fairly. All community leaders are obligated to respect the privacy and security of the reporter of any incident.

## Enforcement

Project maintainers have the right and responsibility to remove, edit, or reject comments, commits, code, wiki edits, issues, and other contributions that are not aligned with this Code of Conduct. Project maintainers who do not follow or enforce the Code of Conduct may be temporarily or permanently removed from the project team.

## Attribution

This Code of Conduct is adapted from the [Project Include](https://projectinclude.org/writing_cocs) guidelines and inspired by the [Contributor Covenant](https://www.contributor-covenant.org/), version 2.0.

## Questions?

If you have questions about this Code of Conduct, please open an issue in the repository or contact the project maintainers.

## Project Maintenance

This project is maintained by Cameron Pak as the sole maintainer, operating under FAITH TOOLS SOFTWARE SOLUTIONS, LLC. While community contributions are welcome, final decisions and project direction are managed through this structure.

---

Freedom Stack is made with 🕊️ by [Cameron Pak](https://cameronpak.com), brought to you by [faith.tools](https://faith.tools).
EOF

# Create example generate_output_code.sh
cat <<EOF > generate_output_code.sh
#!/bin/bash

# =============================================
# CONFIGURATION VARIABLES - Edit these as needed
# =============================================

# Base paths
ROOT_DIR=\$(pwd)
DOCS_BASE_PATH="src/content/docs"

# Root folders to process
ADDITIONAL_ROOT_FOLDERS=(
    "\$ROOT_DIR/src"
    "\$ROOT_DIR/scripts"
    "\$ROOT_DIR/db"
)

# Docs subfolders to process (empty array = no docs processing)
DOCS_SUBFOLDERS=("fr")

# Files to exclude
exclude_files=(
    "pnpm-lock.yaml"
    "\$output_file"
    "\$output_docs_file"
)

# Directories to exclude
exclude_dirs=(
    "node_modules"
    ".git"
    "dist"
    "build"
    "public"
)

# File extensions to exclude
exclude_extensions=(
    ".DS_Store"
    ".png"
    ".jpg"
    ".jpeg"
    ".svg"
    ".gif"
    ".webp"
    ".mp4"
    ".mp3"
    ".avi"
    ".mov"
    ".mkv"
)

# Output files
output_file="astro-chatgpt-ai-template.txt"
output_docs_file="output_docs.txt"

# =============================================
# Script logic below - No need to modify unless changing functionality
# =============================================

# Clean output files at start
rm -f "\$output_file"
rm -f "\$output_docs_file"

# Global arrays to store subdirectories and files
FOLDER_NAMES=()
FOLDER_SUBDIRS=()
FOLDER_FILES=()

# Function to check if a path should be excluded
should_exclude() {
    local path="\$1"
    local base_name=\$(basename "\$path")
    local ext="\${base_name##*.}"

    # Check excluded directories
    for exclude_dir in "\${exclude_dirs[@]}"; do
        if [[ "\$path" == *"/\$exclude_dir"* ]]; then
            return 0
        fi
    done

    # Check excluded files
    for exclude in "\${exclude_files[@]}"; do
        if [[ "\$base_name" == "\$exclude" ]]; then
            return 0
        fi
    done

    # Check excluded extensions
    for exclude in "\${exclude_extensions[@]}"; do
        if [[ ".\$ext" == "\$exclude" ]]; then
            return 0
        fi
    done

    return 1
}

# Function to check if a directory is allowed
is_allowed_directory() {
    local dir="\$1"

    # Block src/content/docs path when not in specified DOCS_SUBFOLDERS
    if [[ "\$dir" == *"/\$DOCS_BASE_PATH/"* ]]; then
        for subdir in "\${DOCS_SUBFOLDERS[@]}"; do
            if [[ "\$dir" == *"/\$DOCS_BASE_PATH/\$subdir"* ]]; then
                return 0
            fi
        done
        return 1
    fi

    # Check if directory is in ADDITIONAL_ROOT_FOLDERS
    for allowed_dir in "\${ADDITIONAL_ROOT_FOLDERS[@]}"; do
        if [[ "\$dir" == "\$allowed_dir"* ]]; then
            return 0
        fi
    done

    return 1
}

# Function to recursively list subdirectories and files
recursive_list() {
    local dir="\$1"
    local base_dir="\${2:-\$dir}"

    for item in "\$dir"/*; do
        if [ -d "\$item" ]; then
            if ! should_exclude "\$item" && is_allowed_directory "\$item"; then
                FOLDER_SUBDIRS+=("\$item")
                recursive_list "\$item" "\$base_dir"
            fi
        elif [ -f "\$item" ]; then
            if ! should_exclude "\$item" && is_allowed_directory "\$(dirname "\$item")"; then
                FOLDER_FILES+=("\$item")
            fi
        fi
    done
}

# Function to add the content of a file to the appropriate output file
add_file_content() {
    local file_path="\$1"
    local target_file="\$output_file"
    local relative_path=".\${file_path#\$ROOT_DIR}"

    if [[ "\$file_path" == *"/\$DOCS_BASE_PATH/"* ]]; then
        target_file="\$output_docs_file"
    fi

    echo "# Start of \$relative_path" >> "\$target_file"
    if [[ "\$file_path" == *.json ]]; then
        python3 -c "import json; import sys; print(json.dumps(json.load(sys.stdin), indent=4, ensure_ascii=False))" < "\$file_path" >> "\$target_file"
    else
        cat "\$file_path" >> "\$target_file"
    fi
    echo "# End of \$relative_path" >> "\$target_file"
    echo "" >> "\$target_file"
}

# Function to add files in the include_dirs while excluding specific file types
add_files_in_dirs() {
    for dir_name in "\${ADDITIONAL_ROOT_FOLDERS[@]}"; do
        if [ -d "\$dir_name" ]; then
            find "\$dir_name" -type f | while read -r file_name; do
                if ! should_exclude "\$file_name" && is_allowed_directory "\$(dirname "\$file_name")"; then
                    add_file_content "\$file_name"
                fi
            done
        fi
    done
}

# Main script logic

# List all subdirectories and files in the additional root folders
for folder in "\${ADDITIONAL_ROOT_FOLDERS[@]}"; do
    if [ -d "\$folder" ]; then
        FOLDER_NAMES+=("\$folder")
        recursive_list "\$folder" "\$folder"
    fi
done

# List files in the root directory (only direct files, not in subdirectories)
for file in "\$ROOT_DIR"/*; do
    if [ -f "\$file" ] && ! should_exclude "\$file"; then
        FOLDER_FILES+=("\$file")
        add_file_content "\$file"
    fi
done

# Add files in the include_dirs to the output file
add_files_in_dirs

# Process and display results for each folder
for folder in "\${FOLDER_NAMES[@]}"; do
    echo "Subdirectories in \$folder:"
    for subdir in "\${FOLDER_SUBDIRS[@]}"; do
        [[ \$subdir == \$folder/* ]] && echo "\$subdir"
    done

    echo "Files in \$folder:"
    for file in "\${FOLDER_FILES[@]}"; do
        [[ \$file == \$folder/* ]] && echo "\$file"
    done
done
EOF

# Make the script executable
chmod +x generate_output_code.sh

# Run the script to generate the output file
./generate_output_code.sh

echo "Project setup complete. You can now run 'npm run dev' to start the development server."
