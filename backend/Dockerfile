# Use Node.js LTS
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install system dependencies needed by Prisma
RUN apk add --no-cache openssl libc6-compat bash

# Copy package files
COPY backend/package*.json ./
RUN npm install

# Copy Prisma schema and generate client
COPY prisma ./prisma
RUN npx prisma generate

# Copy backend source code
COPY . .

# Expose app port
EXPOSE 3000

# Start server
CMD ["npm", "start"]
