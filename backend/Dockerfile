# Use Node.js LTS
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies needed for Prisma and native modules
RUN apk add --no-cache openssl libc6-compat bash

# Copy package files first (for caching npm install)
COPY package*.json ./

# Install all dependencies (including dev)
RUN npm ci

# Copy Prisma schema and generate client
COPY prisma ./prisma
RUN npx prisma generate

# Copy application source code
COPY . .

# Create uploads folder
RUN mkdir -p uploads

# Expose app port
EXPOSE 3000

# Default command for development
CMD ["npm", "run", "dev"]
