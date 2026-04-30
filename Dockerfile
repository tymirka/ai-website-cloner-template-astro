# ============================================
# Multi-stage build for Astro static SSG
# ============================================
# Builds the site with Node, then serves /dist with nginx.

# IMPORTANT: Node.js Version Maintenance
# Defaults to Node.js 24.14.1-slim to match the repo's Node 24 baseline.
# Update the NODE_VERSION ARG when the project's Node baseline changes.
ARG NODE_VERSION=24.14.1-slim
ARG NGINX_VERSION=alpine

# ============================================
# Stage 1: Install dependencies
# ============================================
FROM node:${NODE_VERSION} AS dependencies

WORKDIR /app

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* .npmrc* ./

RUN --mount=type=cache,target=/root/.npm \
  --mount=type=cache,target=/usr/local/share/.cache/yarn \
  --mount=type=cache,target=/root/.local/share/pnpm/store \
  if [ -f package-lock.json ]; then \
  npm ci --no-audit --no-fund; \
  elif [ -f yarn.lock ]; then \
  corepack enable yarn && yarn install --frozen-lockfile --production=false; \
  elif [ -f pnpm-lock.yaml ]; then \
  corepack enable pnpm && pnpm install --frozen-lockfile; \
  else \
  echo "No lockfile found." && exit 1; \
  fi

# ============================================
# Stage 2: Build Astro static site → /app/dist
# ============================================
FROM node:${NODE_VERSION} AS builder

WORKDIR /app

COPY --from=dependencies /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production

RUN if [ -f package-lock.json ]; then \
  npm run build; \
  elif [ -f yarn.lock ]; then \
  corepack enable yarn && yarn build; \
  elif [ -f pnpm-lock.yaml ]; then \
  corepack enable pnpm && pnpm build; \
  else \
  echo "No lockfile found." && exit 1; \
  fi

# ============================================
# Stage 3: Serve static output with nginx
# ============================================
FROM nginx:${NGINX_VERSION} AS runner

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
