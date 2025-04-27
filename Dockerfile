# Build stage
FROM node:20-alpine AS builder

WORKDIR /build

COPY package*.json ./
# Install only production dependencies
RUN npm install --omit=dev

# App stage
FROM node:20-alpine AS app

WORKDIR /app

# Copy only node_modules from builder
COPY --from=builder /build/node_modules ./node_modules/

# Copy application files
COPY . .

# Create statCalcData folder if it doesn't exist
RUN mkdir -p statCalcData && \
    chown node:node statCalcData

# Declare statCalcData as a volume
VOLUME /app/statCalcData

# Install tini for better signal handling
RUN apk update && \
    apk add --no-cache tini && \
    rm -rf /var/cache/apk/*

# Set node user for better security
USER node

# Set tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default command
CMD ["node", "app.js"]
