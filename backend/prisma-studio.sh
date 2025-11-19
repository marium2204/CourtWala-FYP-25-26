#!/bin/bash

# Script to start Prisma Studio in Docker container
# This makes Prisma Studio accessible from your host machine

echo "🚀 Starting Prisma Studio..."
echo "📊 Access it at: http://localhost:5555"
echo ""
echo "Press Ctrl+C to stop Prisma Studio"
echo ""

# Run Prisma Studio with hostname 0.0.0.0 to make it accessible from outside container
docker compose exec backend npx prisma studio --hostname 0.0.0.0 --port 5555

