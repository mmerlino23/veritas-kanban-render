FROM node:22-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@9

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY shared/package.json ./shared/
COPY server/package.json ./server/
COPY web/package.json ./web/

# Install dependencies
RUN pnpm install --frozen-lockfile=false

# Copy source code
COPY . .

# Build in order: shared -> server -> web
RUN pnpm --filter @veritas-kanban/shared build && \
    pnpm --filter @veritas-kanban/server build && \
    pnpm --filter @veritas-kanban/web build

# Create data directory
RUN mkdir -p /app/.veritas-data

ENV NODE_ENV=production
ENV VERITAS_AUTH_ENABLED=false
ENV VERITAS_DATA_DIR=/app/.veritas-data
ENV PORT=3000

EXPOSE 3000

CMD ["node", "server/dist/index.js"]
