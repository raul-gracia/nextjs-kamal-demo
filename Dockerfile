# Dockerfile for Next.js 15 with standalone output
# Optimized multi-stage build for production deployment with Kamal
# Based on Next.js official recommendations

# =============================================================================
# Stage 1: Dependencies
# =============================================================================
FROM node:20-alpine AS deps

# Install libc6-compat for Alpine compatibility with some npm packages
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy package files for dependency installation
COPY package.json package-lock.json* yarn.lock* pnpm-lock.yaml* ./

# Copy Prisma files needed for postinstall (prisma generate)
COPY prisma ./prisma
COPY prisma.config.ts ./

# Dummy DATABASE_URL for prisma generate (not used at runtime)
ENV DATABASE_URL="postgresql://user:pass@localhost:5432/db"

# Install dependencies based on the available lock file
# Use --ignore-scripts to skip postinstall (prisma generate) - we'll run it in builder stage
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile --ignore-scripts; \
  elif [ -f package-lock.json ]; then npm ci --ignore-scripts; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i --frozen-lockfile --ignore-scripts; \
  else echo "No lockfile found." && exit 1; \
  fi

# =============================================================================
# Stage 2: Builder
# =============================================================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Disable Next.js telemetry during build
ENV NEXT_TELEMETRY_DISABLED=1

# Build arguments for environment variables needed at build time
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Dummy DATABASE_URL for prisma generate (not used at runtime)
ENV DATABASE_URL="postgresql://user:pass@localhost:5432/db"

# Generate Prisma client (needed for Next.js build)
RUN npx prisma generate

# Build the application
# Note: Ensure next.config.js has output: 'standalone'
RUN \
  if [ -f yarn.lock ]; then yarn build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm build; \
  else npm run build; \
  fi

# =============================================================================
# Stage 3: Production Runner
# =============================================================================
FROM node:20-alpine AS runner

WORKDIR /app

# Set production environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create non-root user for security (OWASP recommendation)
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Install prisma CLI for database migrations
RUN npm install -g prisma@7.0.1

# Copy necessary files from builder
# Public assets (if any)
COPY --from=builder /app/public ./public

# Standalone output directory
# This contains the minimal server and dependencies
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./

# Static files generated during build
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Copy Prisma schema and config for migrations
COPY --from=builder --chown=nextjs:nodejs /app/prisma ./prisma
COPY --from=builder --chown=nextjs:nodejs /app/prisma.config.ts ./prisma.config.ts

# Switch to non-root user
USER nextjs

# Expose the application port
EXPOSE 3000

# Set the port environment variable
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Health check for Docker (kamal-proxy uses its own health checks)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

# Start the application using the standalone server
CMD ["node", "server.js"]
