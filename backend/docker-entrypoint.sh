#!/bin/sh
set -e

echo "🚀 Starting CourtWala Backend..."

# Wait a moment for database to be fully ready
echo "⏳ Waiting for database to be ready..."
sleep 3

# Run migrations with retry logic
echo "📦 Running database migrations..."
RETRIES=10
while [ $RETRIES -gt 0 ]; do
    if npx prisma migrate deploy; then
        echo "✅ Migrations completed successfully!"
        break
    else
        RETRIES=$((RETRIES - 1))
        if [ $RETRIES -eq 0 ]; then
            echo "⚠️  Migrations may have already been applied or failed"
            break
        fi
        echo "   Migration failed, retrying... ($RETRIES retries left)"
        sleep 3
    fi
done

# Seed database (will skip if already seeded due to upsert in seed.js)
echo "🌱 Seeding database..."
npm run seed || echo "⚠️  Seeding completed or skipped"

# Start the application
echo "🎯 Starting application server..."
if [ "$NODE_ENV" = "development" ]; then
    echo "🛠 Development mode: Using nodemon for auto-reload"
    exec npm run dev
else
    echo "🚀 Production mode: Using node"
    exec node server.js
fi
