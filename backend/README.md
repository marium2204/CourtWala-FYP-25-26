# Sports Court Booking API

A comprehensive court booking system built with Express.js, Prisma ORM, and MySQL.

## Features

- **Multi-actor System**: Players, Court Owners, and Admins
- **Court Management**: Browse, create, and manage courts
- **Booking System**: Request, approve, and manage bookings
- **Matchmaking**: Find and connect with other players
- **Tournaments**: Join and manage tournaments
- **Notifications**: Real-time notifications for all activities
- **Role-based Access Control**: Secure API with JWT authentication

## Tech Stack

- **Node.js** with Express.js
- **Prisma ORM** with MySQL
- **JWT** for authentication
- **bcryptjs** for password hashing
- **express-validator** for request validation
- **Socket.io** for real-time notifications (ready for implementation)
- **Swagger/OpenAPI** for API documentation

## Project Structure

```
backend/
├── app/
│   ├── controllers/      # Request handlers
│   │   ├── Player/       # Player-specific controllers
│   │   ├── Owner/        # Court owner controllers
│   │   └── Admin/        # Admin controllers
│   ├── services/         # Business logic layer
│   ├── routes/           # Route definitions
│   ├── middleware/       # Custom middleware
│   ├── validators/       # Request validators
│   └── utils/            # Utility functions
├── config/               # Configuration files
├── prisma/               # Prisma schema and migrations
└── server.js             # Application entry point
```

## Setup Instructions

### 🐳 Docker Setup (Recommended)

The easiest way to get started is using Docker. This will automatically set up the database, run migrations, seed data, configure auto-reload for development, and set up auto-start on boot.

#### Prerequisites

- Docker and Docker Compose installed
- Ports 3000 (API) and 3307 (MySQL) available (or configure different ports in `.env`)

#### Quick Start

1. **Run the setup script**:
   ```bash
   ./setup.sh
   ```

   Or if you need sudo for systemd setup:
   ```bash
   sudo ./setup.sh
   ```

   The script will:
   - Check Docker installation
   - Create `.env` file from `.env.example` (if needed)
   - Check for port conflicts
   - Build and start Docker containers
   - Run database migrations automatically
   - Seed the database with default users
   - Set up auto-start on system boot

2. **Access the application**:
   - **API Server**: `http://localhost:3000`
   - **API Documentation (Swagger UI)**: `http://localhost:3000/api-docs`
   - **Health Check**: `http://localhost:3000/health`
   - **Prisma Studio**: `http://localhost:5555` (see Database Access section)

#### Docker Services

The Docker setup includes:

- **Backend Service** (`courtwala_backend`): Node.js Express API
  - Port: `3000` (configurable via `PORT` in `.env`)
  - Auto-reload enabled in development mode
  - Prisma Studio port: `5555`

- **Database Service** (`courtwala_db`): MySQL 8.0
  - Port: `3307` (configurable via `DB_PORT` in `.env`)
  - Internal port: `3306` (used by backend container)
  - Data persisted in Docker volume

#### Docker Commands

```bash
# View logs (all services)
docker compose logs -f

# View logs (specific service)
docker compose logs -f backend
docker compose logs -f db

# Stop containers
docker compose down

# Start containers
docker compose up -d

# Restart containers
docker compose restart

# Restart specific service
docker compose restart backend

# Rebuild and restart
docker compose up -d --build

# Force recreate containers
docker compose up -d --force-recreate

# View running containers
docker compose ps

# Execute command in container
docker compose exec backend <command>
docker compose exec db <command>
```

#### Development Features

**Auto-Reload (Hot Reload)**
- Enabled automatically when `NODE_ENV=development` in `.env`
- Uses `nodemon` to watch for file changes
- Automatically restarts server when you edit files in:
  - `app/` directory
  - `config/` directory
  - `server.js`
  - `package.json`

**To enable/disable auto-reload:**
```bash
# Development mode (auto-reload enabled)
NODE_ENV=development

# Production mode (no auto-reload)
NODE_ENV=production
```

#### Database Access

**Prisma Studio (Web UI)**
```bash
# Start Prisma Studio
./prisma-studio.sh

# Or manually
docker compose exec -d backend sh -c "npx prisma studio --hostname 0.0.0.0 --port 5555"

# Access at: http://localhost:5555
```

**Direct Database Access (MySQL Client)**
```
Host: localhost
Port: 3307
Username: root
Password: rootpassword (or DB_ROOT_PASSWORD from .env)
Database: courtwala (or DB_NAME from .env)
```

**Application Database User**
```
Host: localhost
Port: 3307
Username: courtwala_user (or DB_USER from .env)
Password: courtwala_password (or DB_PASSWORD from .env)
Database: courtwala
```

**Connection String Format:**
```
mysql://username:password@localhost:3307/database_name
```

#### Environment Variables

Key environment variables for Docker setup (in `.env`):

```env
# Application
NODE_ENV=development          # development or production
PORT=3000                     # API server port
APP_URL=http://localhost:3000

# Database (Docker)
DB_ROOT_PASSWORD=rootpassword
DB_NAME=courtwala
DB_USER=courtwala_user
DB_PASSWORD=courtwala_password
DB_PORT=3307                  # External MySQL port (avoids conflict with host MySQL)

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# Note: DATABASE_URL is automatically set by docker-compose.yml
# It points to db:3306 (internal Docker network)
```

#### Auto-Start on Boot

The setup script automatically configures a systemd service that starts the containers on system boot. To manage it manually:

```bash
# Check status
sudo systemctl status courtwala-backend

# Start service
sudo systemctl start courtwala-backend

# Stop service
sudo systemctl stop courtwala-backend

# Restart service
sudo systemctl restart courtwala-backend

# Disable auto-start
sudo systemctl disable courtwala-backend

# Enable auto-start
sudo systemctl enable courtwala-backend
```

#### Troubleshooting

**Port Already in Use:**
```bash
# Check what's using the port
ss -tuln | grep 3000
ss -tuln | grep 3307

# Change ports in .env file
PORT=3001
DB_PORT=3308
```

**Container Won't Start:**
```bash
# Check logs
docker compose logs backend

# Check container status
docker compose ps

# Rebuild containers
docker compose up -d --build --force-recreate
```

**Database Connection Issues:**
```bash
# Check database is healthy
docker compose ps db

# Check database logs
docker compose logs db

# Test database connection
docker compose exec db mysqladmin ping -h localhost -u root -prootpassword
```

**Auto-reload Not Working:**
```bash
# Verify NODE_ENV is set to development
docker compose exec backend sh -c 'echo $NODE_ENV'

# Check if nodemon is running
docker compose exec backend ps aux | grep nodemon

# Restart backend
docker compose restart backend
```

### 📦 Manual Setup (Without Docker)

#### 1. Install Dependencies

```bash
npm install
```

#### 2. Configure Environment Variables

Create a `.env` file in the root directory:

```env
# Database
DATABASE_URL="mysql://user:password@localhost:3306/courtwala"

# Application
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

# Bcrypt
BCRYPT_SALT_ROUNDS=10

# File Upload
MAX_FILE_SIZE=5242880
UPLOAD_PATH=uploads
```

#### 3. Set Up Database

```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations
npm run prisma:migrate

# (Optional) Seed database with sample data
npm run prisma:seed
```

#### 4. Start the Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

Once the server is running, you can access:
- **API Server**: `http://localhost:3000`
- **API Documentation (Swagger UI)**: `http://localhost:3000/api-docs`
- **Health Check**: `http://localhost:3000/health`

## API Documentation (Swagger)

This project includes comprehensive API documentation using Swagger/OpenAPI 3.0.0.

### Accessing Swagger UI

After starting the server, navigate to:
```
http://localhost:3000/api-docs
```

The Swagger UI provides an interactive interface to:
- Browse all available API endpoints
- View request/response schemas
- Test API endpoints directly from the browser
- Understand authentication requirements

### API Documentation Features

- **OpenAPI 3.0.0 Specification**: Modern API documentation standard
- **Interactive Testing**: Try out endpoints with real requests
- **Authentication Support**: JWT Bearer token authentication built-in
- **Comprehensive Coverage**: All endpoints documented including:
  - Authentication endpoints
  - Public court browsing
  - Player-specific endpoints (bookings, matchmaking, tournaments, profile)
  - Court owner endpoints (dashboard, courts, bookings)
  - Admin endpoints (users, courts, tournaments, reports, announcements)
  - Notifications endpoints

### Using Swagger UI for Testing

1. **Authenticate First**: 
   - Use the `/api/auth/login` endpoint to get a JWT token
   - Click the "Authorize" button at the top of the Swagger UI
   - Enter your token in the format: `Bearer <your-token>`
   - Click "Authorize" to authenticate for all protected endpoints

2. **Test Endpoints**:
   - Click on any endpoint to expand it
   - Click "Try it out" to enable editing
   - Fill in the required parameters
   - Click "Execute" to send the request
   - View the response below

### API Base URL

All API endpoints are prefixed with `/api`:
- Base URL: `http://localhost:3000/api`
- Example: `http://localhost:3000/api/auth/login`

### Authentication

Most endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

The Swagger UI handles this automatically after you authorize using the "Authorize" button.

## API Endpoints

> **📚 For detailed API documentation with request/response schemas, examples, and interactive testing, visit the [Swagger UI](#api-documentation-swagger) at `http://localhost:3000/api-docs`**

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password
- `GET /api/auth/me` - Get current user

### Public Routes
- `GET /api/courts` - Browse all courts
- `GET /api/courts/:id` - Get court details

### Player Routes (`/api/player`)
- Profile management
- Create and manage bookings
- Search players and send match requests
- Join tournaments

### Court Owner Routes (`/api/owner`)
- Dashboard statistics
- Court management (CRUD)
- Booking management (approve/reject/cancel)

### Admin Routes (`/api/admin`)
- Dashboard statistics
- User management
- Court approval
- Report management
- Announcements
- Tournament management

### Notifications (`/api/notifications`)
- Get all notifications
- Mark as read
- Get unread count

## Default Users (from seed)

These users are automatically created when you run the setup:

- **Admin**: admin@courtwala.com / admin123
- **Court Owner**: owner@courtwala.com / owner123
- **Player**: player@courtwala.com / player123

> **Note**: These are default credentials for development. Change them in production!

## Development Principles

- **DRY (Don't Repeat Yourself)**: Reusable services and utilities
- **Separation of Concerns**: Controllers, Services, and Routes are separated
- **Loose Coupling**: Services are independent and can be easily tested
- **Consistent Responses**: Standardized response format across all endpoints

## Docker Files Overview

- `Dockerfile` - Backend application container definition
- `docker-compose.yml` - Multi-container orchestration (backend + database)
- `docker-entrypoint.sh` - Container startup script (handles migrations, seeding)
- `setup.sh` - Automated setup script for Docker environment
- `prisma-studio.sh` - Helper script to start Prisma Studio
- `.dockerignore` - Files excluded from Docker build context

## Production Deployment

For production deployment:

1. Set `NODE_ENV=production` in `.env`
2. Use strong passwords for database credentials
3. Set a secure `JWT_SECRET`
4. Remove or comment out source code volume mounts in `docker-compose.yml`
5. Use environment-specific configuration
6. Set up proper backup strategy for database volumes
7. Configure reverse proxy (nginx/traefik) for SSL/TLS
8. Set up monitoring and logging

## License

ISC

