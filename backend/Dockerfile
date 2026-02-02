# Use Node.js LTS
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install system dependencies needed by Prisma
RUN apk add --no-cache openssl libc6-compat bash

##railway
COPY backend/package*.json ./
RUN npm install
COPY backend/prisma ./prisma
RUN npx prisma generate
COPY backend ./

## local
# COPY package*.json ./
# COPY prisma ./prisma
# COPY . .

# Ensure uploads directory exists
RUN mkdir -p uploads

# Expose app port
EXPOSE 3000

# Start server (production-safe)
CMD ["npm", "start"]
