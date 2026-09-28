<!-- AUTO-GENERATED from AGENTS.md — do not edit directly.
     Run `bash scripts/sync-agent-rules.sh` to regenerate. -->

---
description: Project conventions for AI Website Clone Template
alwaysApply: true
---
<!-- BEGIN:astro-agent-rules -->
# Astro, not Next.js

This template uses Astro 7 (static SSG), not Next.js. If your prior session or training data assumes Next.js or an older Astro major (4/5/6) here, discard that assumption — clones are written for Astro 7 directly. Read the Astro docs and the types in `node_modules/astro/` before writing code. Key differences to remember:

- Pages live in `src/pages/*.astro`, not `src/app/*.tsx`. No App Router, no file-based route handlers.
- No React by default. Components are `.astro` files. If interactivity is required, prefer a `<script>` block in the `.astro` file over reaching for a UI framework.
- No `next/font`, `next/image`, `next/link`, `"use client"`, or any `next/*` import. Fonts come from Google Fonts via `<link>` in the layout. Images are plain `<img>` (or Astro's `<Image />` from `astro:assets` when needed).
- Build output goes to `dist/` (static HTML + assets). No `.next/` directory, no standalone server.
- Astro 7 specifics: keep `compressHTML: true` in `astro.config.mjs` (the `'jsx'` default glues words across line breaks), close every non-void element explicitly (no `<div />`, `<p set:html={...} />`, `<script ... />`), declare every imported package in `package.json`, and keep a single Vite version (`npm ls vite`). Full rules: "Astro 7 Target Rules" in `.claude/skills/clone-website/SKILL.md`.
<!-- END:astro-agent-rules -->

# Website Reverse-Engineer Template

## What This Is
A reusable template for reverse-engineering any website into a clean, modern Astro codebase using AI coding agents. The Astro + Tailwind v4 base is pre-scaffolded — just run `/clone-website <url1> [<url2> ...]`.

## Tech Stack
- **Framework:** Astro 7 (static SSG, Vite 8 + Rolldown, TypeScript strict, `compressHTML: true`)
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
- `npm run i18n:missing` — Multilingual projects: write missing translations (keys + source text, missing content files) to `docs/i18n/MISSING_TRANSLATIONS.md`
- `./LOOP.sh <url1> [<url2> ...]` — Run `/clone-website` for each URL in turn (prose pages into content collections), then write the missing-translations report

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

## Existing Project Adaptation
- If the repository already contains implemented pages, layouts, components, design tokens, or assets, adapt the new page to the current project instead of treating it as a fresh scaffold.
- Reuse existing shared elements first: layouts, header/footer, navigation, buttons, cards, icons, utility classes, content patterns, and style tokens. Create new components only when the current project has no suitable equivalent.
- When cloning a subpage into an existing site, preserve the site's established structure and route conventions, and integrate the subpage with the same visual language and reusable building blocks.
- Never delete or overwrite an existing route, another page's research/screenshots/assets, or shared tokens that other pages use without explicit approval. Each cloned page keeps its artifacts in `docs/research/<site-slug>/<page-slug>/` and `docs/design-references/<site-slug>/<page-slug>/`; page-only sections go in `src/components/<page-slug>/`, page-only assets in `public/images/<page-slug>/`.

## Multilingual Projects
Applies only when the cloned site is multilingual, `src/i18n/` already exists, or the user asks for it; single-language clones keep copy inline.
- Routing mirrors the target through Astro's `i18n` config (`locales`, `defaultLocale`, `routing.prefixDefaultLocale`); each locale has its own route file at the exact localized path, rendering one shared page component per translation group.
- UI copy goes through `useTranslations(Astro.currentLocale)` / `t("namespace.key")` from `src/i18n/index.ts`, with one `src/i18n/<locale>.ts` per locale; the default locale defines the key shape.
- Prose pages live in content collections: `src/content/<collection>/<entry>/<locale>.md`, with the target's exact URL in the `path` frontmatter field.
- Never machine-translate. Missing strings fall back to the default locale, missing content files mean no route; `npm run i18n:missing` lists both for human translation.
- Details: "Multilingual Sites" in `.claude/skills/clone-website/SKILL.md`.

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
  i18n/             # Multilingual only: index.ts (t(), routes) + <locale>.ts per locale
  content/          # Multilingual prose: <collection>/<entry>/<locale>.md
  content.config.ts # Content collection definitions (when src/content/ is used)
public/
  favicon.ico
  images/           # Downloaded images from target site
  videos/           # Downloaded videos from target site
  seo/              # Favicons, OG images, webmanifest
docs/
  research/         # Inspection output (design tokens, components, layout)
  design-references/ # Screenshots and visual references
  i18n/             # MISSING_TRANSLATIONS.md report (multilingual only)
scripts/            # Asset download scripts, i18n-missing.mjs
LOOP.sh             # Clone a list of URLs one by one
astro.config.mjs    # Astro + Tailwind v4 (Vite plugin) config
```

## MOST IMPORTANT NOTES
- When launching Claude Code agent teams, ALWAYS have each teammate work in their own worktree branch and merge everyone's work at the end, resolving any merge conflicts smartly since you are basically serving the orchestrator role and have full context to our goals, work given, work achieved, and desired outcomes.
- After editing `AGENTS.md`, run `bash scripts/sync-agent-rules.sh` to regenerate platform-specific instruction files.
- After editing `.claude/skills/clone-website/SKILL.md`, run `node scripts/sync-skills.mjs` to regenerate the skill for all platforms.

# Website Inspection Guide

## How to Reverse-Engineer Any Website

This guide outlines what to capture when inspecting a target website via Chrome MCP or browser DevTools.

## Phase 1: Visual Audit

### Screenshots to Capture
- [ ] Every distinct page — desktop, tablet, mobile
- [ ] Dark mode variants (if applicable)
- [ ] Light mode variants (if applicable)
- [ ] Key interaction states (hover, active, open menus, modals)
- [ ] Loading/skeleton states
- [ ] Empty states
- [ ] Error states

### Design Tokens to Extract
- [ ] **Colors** — background, text (primary/secondary/muted), accent, border, hover, error, success, warning
- [ ] **Typography** — font family, sizes (h1-h6, body, caption, label), weights, line heights, letter spacing
- [ ] **Spacing** — padding/margin patterns (look for a scale: 4px, 8px, 12px, 16px, 24px, 32px, etc.)
- [ ] **Border radius** — buttons, cards, avatars, inputs
- [ ] **Shadows/elevation** — card shadows, dropdown shadows, modal overlay
- [ ] **Breakpoints** — when does the layout shift? (inspect with DevTools responsive mode)
- [ ] **Icons** — which icon library? custom SVGs? sizes?
- [ ] **Avatars** — sizes, shapes, fallback behavior
- [ ] **Buttons** — all variants (primary, secondary, ghost, icon-only, danger)
- [ ] **Inputs** — text fields, textareas, selects, checkboxes, toggles

## Phase 2: Component Inventory

For each distinct UI component, document:
1. **Name** — what would you call this component?
2. **Structure** — what HTML elements / child components does it contain?
3. **Variants** — does it have different sizes, colors, or states?
4. **States** — default, hover, active, disabled, loading, error, empty
5. **Responsive behavior** — how does it change at different breakpoints?
6. **Interactions** — click, hover, focus, keyboard navigation
7. **Animations** — transitions, entrance/exit animations, micro-interactions

### Common Components to Look For
- Navigation (top bar, sidebar, bottom bar)
- Cards / list items
- Buttons and links
- Forms and inputs
- Modals and dialogs
- Dropdowns and menus
- Tabs and segmented controls
- Avatars and user badges
- Loading skeletons
- Toast notifications
- Tooltips and popovers

## Phase 3: Layout Architecture

- [ ] **Grid system** — CSS Grid? Flexbox? Fixed widths?
- [ ] **Column layout** — how many columns at each breakpoint?
- [ ] **Max-width** — main content area max-width
- [ ] **Sticky elements** — header, sidebar, floating buttons
- [ ] **Z-index layers** — navigation, modals, tooltips, overlays
- [ ] **Scroll behavior** — infinite scroll, pagination, virtual scrolling

## Phase 4: Technical Stack Analysis

- [ ] **Framework** — React? Vue? Angular? Check `__NEXT_DATA__`, `__NUXT__`, `ng-version`
- [ ] **CSS approach** — Tailwind (utility classes), CSS Modules, Styled Components, Emotion, vanilla CSS
- [ ] **State management** — Redux (check DevTools), React Query, Zustand, Pinia
- [ ] **API patterns** — REST, GraphQL (check network tab for `/graphql` requests)
- [ ] **Font loading** — Google Fonts, self-hosted, system fonts
- [ ] **Image strategy** — CDN, lazy loading, srcset, WebP/AVIF
- [ ] **Animation library** — Framer Motion, GSAP, CSS transitions only

## Phase 5: Documentation Output

After inspection, create these files in `docs/research/`:
1. `DESIGN_TOKENS.md` — All extracted colors, typography, spacing
2. `COMPONENT_INVENTORY.md` — Every component with structure notes
3. `LAYOUT_ARCHITECTURE.md` — Page layouts, grid system, responsive behavior
4. `INTERACTION_PATTERNS.md` — Animations, transitions, hover states
5. `TECH_STACK_ANALYSIS.md` — What the site uses and our chosen equivalents
