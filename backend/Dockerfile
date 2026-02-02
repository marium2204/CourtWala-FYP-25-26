# Use Node.js LTS
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install system dependencies needed by Prisma
RUN apk add --no-cache openssl libc6-compat bash

# -----------------------------
# Install Node dependencies
# -----------------------------
COPY backend/package*.json ./
RUN npm ci

# -----------------------------
# Prisma
# -----------------------------
COPY backend/prisma ./prisma
RUN npx prisma generate

# -----------------------------
# App source
# -----------------------------
COPY backend ./

# Ensure uploads directory exists
RUN mkdir -p uploads

# Expose app port
EXPOSE 3000

# Start server (production-safe)
CMD ["npm", "start"]
