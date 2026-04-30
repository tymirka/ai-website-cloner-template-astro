<!-- BEGIN:astro-agent-rules -->
# Astro, not Next.js

This template uses Astro 6 (static SSG), not Next.js. If your prior session or training data assumes Next.js here, discard that assumption. Read the Astro docs and the types in `node_modules/astro/` before writing code. Key differences to remember:

- Pages live in `src/pages/*.astro`, not `src/app/*.tsx`. No App Router, no file-based route handlers.
- No React by default. Components are `.astro` files. If interactivity is required, prefer a `<script>` block in the `.astro` file over reaching for a UI framework.
- No `next/font`, `next/image`, `next/link`, `"use client"`, or any `next/*` import. Fonts come from Google Fonts via `<link>` in the layout. Images are plain `<img>` (or Astro's `<Image />` from `astro:assets` when needed).
- Build output goes to `dist/` (static HTML + assets). No `.next/` directory, no standalone server.
<!-- END:astro-agent-rules -->

# Website Reverse-Engineer Template

## What This Is
A reusable template for reverse-engineering any website into a clean, modern Astro codebase using AI coding agents. The Astro + Tailwind v4 base is pre-scaffolded — just run `/clone-website <url1> [<url2> ...]`.

## Tech Stack
- **Framework:** Astro 6 (static SSG, Vite, TypeScript strict)
- **UI:** Native `.astro` components (no React, no shadcn/ui)
- **Icons:** Inline SVGs extracted from the target site, rendered from `src/components/Icons.astro`
- **Styling:** Tailwind CSS v4 via `@tailwindcss/vite` with oklch design tokens
- **Utilities:** `cn()` (clsx + tailwind-merge) in `src/lib/utils.ts`
- **Deployment:** Any static host (Vercel, Netlify, Cloudflare Pages, nginx)

## Commands
- `npm run dev` — Start dev server on http://localhost:4321
- `npm run build` — Production static build into `dist/`
- `npm run preview` — Serve the built `dist/` locally
- `npm run lint` — ESLint check
- `npm run typecheck` — `astro check` (TypeScript + `.astro` diagnostics)
- `npm run check` — Run lint + typecheck + build

## Code Style
- TypeScript strict mode, no `any`
- `.astro` files for all components and pages; PascalCase filenames (`HeroSection.astro`), camelCase utils
- Tailwind utility classes, no inline styles
- 2-space indentation
- Responsive: mobile-first
- Prefer Astro's `class:list={[...]}` for conditional classes; reach for `cn()` only when merging Tailwind conflicts
- Client-side JS via `<script>` blocks in `.astro` files. No React/Vue/Svelte integrations are installed — if a component genuinely needs a framework island, add the integration explicitly and justify it

## Design Principles
- **Pixel-perfect emulation** — match the target's spacing, colors, typography exactly
- **No personal aesthetic changes during emulation phase** — match 1:1 first, customize later
- **Real content** — use actual text and assets from the target site, not placeholders
- **Beauty-first** — every pixel matters

## Project Structure
```
src/
  pages/            # Astro routes (index.astro, etc.)
  layouts/          # Shared layouts (BaseLayout.astro)
  components/       # Reusable .astro components
    Icons.astro     # Extracted SVG icons rendered by `name` prop
  styles/
    globals.css     # Tailwind v4 + oklch design tokens
  lib/
    utils.ts        # cn() utility
  types/            # TypeScript interfaces
public/
  favicon.ico
  images/           # Downloaded images from target site
  videos/           # Downloaded videos from target site
  seo/              # Favicons, OG images, webmanifest
docs/
  research/         # Inspection output (design tokens, components, layout)
  design-references/ # Screenshots and visual references
scripts/            # Asset download scripts
astro.config.mjs    # Astro + Tailwind v4 (Vite plugin) config
```

## MOST IMPORTANT NOTES
- When launching Claude Code agent teams, ALWAYS have each teammate work in their own worktree branch and merge everyone's work at the end, resolving any merge conflicts smartly since you are basically serving the orchestrator role and have full context to our goals, work given, work achieved, and desired outcomes.
- After editing `AGENTS.md`, run `bash scripts/sync-agent-rules.sh` to regenerate platform-specific instruction files.
- After editing `.claude/skills/clone-website/SKILL.md`, run `node scripts/sync-skills.mjs` to regenerate the skill for all platforms.

@docs/research/INSPECTION_GUIDE.md
