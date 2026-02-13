# Ask Finnie / CDS Query UI — for in-network deployment (can reach SAP)
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

# Application
COPY server ./server
COPY public ./public

# Optional: copy CDS views into image (or mount at runtime)
# COPY ../zanalytics-cds ./cds-views
# Default: no CDS views in image; set CDS_SOURCE_PATH when running if you mount a volume

EXPOSE 4000

ENV NODE_ENV=production
ENV PORT=4000

CMD ["node", "server/index.js"]
