# Biletify web paneli — Next.js 16 / React 19
#
# Çok aşamalı derleme: son imajda ne kaynak kod ne de devDependencies kalır.
#
#   docker build -t biletfy-panel .
#   docker run -p 3000:3000 biletfy-panel

# --- 1) Bağımlılıklar ---
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# --- 2) Derleme ---
FROM node:22-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Derleme sırasında gömülen public değişkenler (yoksa demo veriyle çalışır).
ARG NEXT_PUBLIC_SUPABASE_URL=""
ARG NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=""
ENV NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL \
    NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=$NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY \
    NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# --- 3) Çalıştırma ---
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME=0.0.0.0

# Root olarak çalıştırma.
RUN addgroup -g 1001 -S nodejs && adduser -u 1001 -S nextjs -G nodejs

# standalone çıktısı server.js ve gereken minimum node_modules'ü içerir.
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3000/').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "server.js"]
