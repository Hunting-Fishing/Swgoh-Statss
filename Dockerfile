FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy only package files and install deps
COPY package*.json ./
RUN npm install --omit=dev

# Copy source code
COPY . .

# Build the statCalcData/gameData.json file
RUN npm run build

FROM node:20-alpine AS app
WORKDIR /app

# Copy built app (including generated gameData.json)
COPY --from=builder /app /app

RUN chown -R node:node /app/statCalcData
VOLUME /app/statCalcData

RUN apk update && \
  apk add --no-cache tini && \
  rm -rf /var/cache/apk/*

USER node

ENTRYPOINT ["/sbin/tini", "--"]
CMD [ "node", "app.js" ]
