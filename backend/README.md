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

The easiest way to get started is using Docker. This will automatically set up the database, run migrations, seed data, configure auto-reload for development, and start Prisma Studio.

#### Prerequisites

- Docker Desktop installed ([Download for Windows](https://www.docker.com/products/docker-desktop/) | [Download for Linux](https://docs.docker.com/engine/install/))
- Docker Compose (included with Docker Desktop on Windows/Mac, or install separately on Linux)
- Ports 3000 (API), 3307 (MySQL), and 5555 (Prisma Studio) available (or configure different ports in `.env`)

---

### 🐧 Linux Setup

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
   - Create `.env.example` file if it doesn't exist
   - Create `.env` file from `.env.example` (if `.env` doesn't exist)
   - Check for port conflicts (skips if containers are already running)
   - Build and start Docker containers (backend, database, and Prisma Studio)
   - Run database migrations automatically
   - Seed the database with default users
   - Start Prisma Studio automatically
   - Set up auto-start on system boot (systemd service)

2. **Access the application**:
   - **API Server**: `http://localhost:3000`
   - **API Documentation (Swagger UI)**: `http://localhost:3000/api-docs`
   - **Health Check**: `http://localhost:3000/health`
   - **Prisma Studio**: `http://localhost:5555` (see Database Access section)

---

### 🪟 Windows Setup

#### Quick Start (Automated)

**Option 1: Use the setup script (Recommended)**

1. **Open PowerShell** (Run as Administrator if needed)

2. **Run the setup script**:
   ```powershell
   .\setup.ps1
   ```

   The script will:
   - Check Docker installation and if Docker Desktop is running
   - Create `.env.example` file if it doesn't exist
   - Create `.env` file from `.env.example` (if `.env` doesn't exist)
   - Build and start Docker containers (backend, database, and Prisma Studio)
   - Wait for services to be ready
   - Display status and access URLs

3. **Access the application**:
   - **API Server**: `http://localhost:3000`
   - **API Documentation (Swagger UI)**: `http://localhost:3000/api-docs`
   - **Health Check**: `http://localhost:3000/health`
   - **Prisma Studio**: `http://localhost:5555`

**Note**: If you get an execution policy error, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Manual Setup

1. **Create environment file** (if `.env` doesn't exist):
   
   If `.env.example` exists, copy it:
   ```powershell
   Copy-Item .env.example .env
   ```
   
   Or create `.env` manually with the following content:
   ```env
   # Application Configuration
   NODE_ENV=development
   PORT=3000
   APP_NAME=Supports Court Booking
   APP_URL=http://localhost:3000

   # Database Configuration (Docker)
   DB_ROOT_PASSWORD=rootpassword
   DB_NAME=courtwala
   DB_USER=courtwala_user
   DB_PASSWORD=courtwala_password
   DB_PORT=3307

   # JWT Configuration
   JWT_SECRET=your-secret-key-change-in-production
   JWT_EXPIRES_IN=7d
   JWT_REFRESH_EXPIRES_IN=30d

   # Bcrypt Configuration
   BCRYPT_SALT_ROUNDS=10

   # File Upload Configuration
   MAX_FILE_SIZE=5242880
   UPLOAD_PATH=uploads

   # Email Configuration (Optional)
   EMAIL_HOST=
   EMAIL_PORT=587
   EMAIL_SECURE=false
   EMAIL_USER=
   EMAIL_PASSWORD=
   EMAIL_FROM=noreply@courtwala.com

   # Prisma Studio Configuration
   PRISMA_STUDIO_PORT=5555
   ```

2. **Start Docker Desktop** (if not already running)

3. **Build and start containers**:
   ```powershell
   # Navigate to project directory
   cd path\to\backend

   # Build and start all services
   docker compose up -d --build
   ```

4. **Wait for services to be ready** (check logs):
   ```powershell
   # View all logs
   docker compose logs -f

   # Or check specific service
   docker compose logs -f backend
   docker compose logs -f db
   docker compose logs -f prisma-studio
   ```

5. **Access the application**:
   - **API Server**: `http://localhost:3000`
   - **API Documentation (Swagger UI)**: `http://localhost:3000/api-docs`
   - **Health Check**: `http://localhost:3000/health`
   - **Prisma Studio**: `http://localhost:5555`

#### Windows Docker Commands (PowerShell)

```powershell
# View logs (all services)
docker compose logs -f

# View logs (specific service)
docker compose logs -f backend
docker compose logs -f db
docker compose logs -f prisma-studio

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
docker compose exec prisma-studio <command>
```

#### Windows Auto-Start on Boot

To start containers automatically on Windows boot:

1. **Using Docker Desktop**:
   - Open Docker Desktop
   - Go to Settings → General
   - Enable "Start Docker Desktop when you log in"

2. **Using Task Scheduler** (Advanced):
   - Open Task Scheduler
   - Create a new task that runs on system startup
   - Action: Start a program
   - Program: `docker`
   - Arguments: `compose -f "C:\path\to\backend\docker-compose.yml" up -d`
   - Start in: `C:\path\to\backend`

---

#### Docker Services

The Docker setup includes:

- **Backend Service** (`courtwala_backend`): Node.js Express API
  - Port: `3000` (configurable via `PORT` in `.env`)
  - Auto-reload enabled in development mode
  - Swagger hot reload enabled in development mode

- **Database Service** (`courtwala_db`): MySQL 8.0
  - Port: `3307` (configurable via `DB_PORT` in `.env`)
  - Internal port: `3306` (used by backend and Prisma Studio containers)
  - Data persisted in Docker volume

- **Prisma Studio Service** (`courtwala_prisma_studio`): Database GUI
  - Port: `5555` (configurable via `PRISMA_STUDIO_PORT` in `.env`)
  - Automatically starts with the application
  - Provides web-based database management interface
  - Accessible at `http://localhost:5555`

#### Linux Docker Commands

```bash
# View logs (all services)
docker compose logs -f

# View logs (specific service)
docker compose logs -f backend
docker compose logs -f db
docker compose logs -f prisma-studio

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
docker compose exec prisma-studio <command>
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

**Swagger Hot Reload**
- Enabled automatically in development mode
- Swagger documentation automatically reloads when you modify Swagger configuration files
- Watches all files in `config/swagger/` directory
- No need to restart the server when updating API documentation

**To enable/disable auto-reload:**
```bash
# Development mode (auto-reload enabled)
NODE_ENV=development

# Production mode (no auto-reload)
NODE_ENV=production
```

#### Database Access

**Prisma Studio (Web UI)**
Prisma Studio is automatically started with the application and runs continuously as a separate Docker service.

- **Access**: `http://localhost:5555`
- **Port**: Configurable via `PRISMA_STUDIO_PORT` in `.env` (default: `5555`)
- **Status**: Automatically restarts if stopped
- **No manual start required**: Runs automatically when containers are started

**Manual Management** (if needed):
```bash
# Restart Prisma Studio service
docker compose restart prisma-studio

# View Prisma Studio logs
docker compose logs -f prisma-studio

# Stop Prisma Studio (if needed)
docker compose stop prisma-studio

# Start Prisma Studio (if stopped)
docker compose start prisma-studio
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

The setup script automatically creates a `.env.example` file if it doesn't exist, and creates a `.env` file from `.env.example` if `.env` doesn't exist.

Key environment variables for Docker setup (in `.env`):

```env
# Application
NODE_ENV=development          # development or production
PORT=3000                     # API server port
APP_URL=http://localhost:3000
APP_NAME=Supports Court Booking

# Database (Docker)
DB_ROOT_PASSWORD=rootpassword
DB_NAME=courtwala
DB_USER=courtwala_user
DB_PASSWORD=courtwala_password
DB_PORT=3307                  # External MySQL port (avoids conflict with host MySQL)

# JWT
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# Bcrypt
BCRYPT_SALT_ROUNDS=10

# File Upload
MAX_FILE_SIZE=5242880
UPLOAD_PATH=uploads

# Email (Optional)
EMAIL_HOST=
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=
EMAIL_PASSWORD=
EMAIL_FROM=noreply@courtwala.com

# Prisma Studio
PRISMA_STUDIO_PORT=5555      # Prisma Studio web UI port

# Note: DATABASE_URL is automatically set by docker-compose.yml
# It points to db:3306 (internal Docker network)
```

#### Linux Auto-Start on Boot

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

---

#### Troubleshooting

**Port Already in Use:**

**Linux:**
```bash
# Check what's using the port
ss -tuln | grep 3000
ss -tuln | grep 3307
ss -tuln | grep 5555

# Or using netstat
netstat -tuln | grep 3000
netstat -tuln | grep 3307
netstat -tuln | grep 5555

# Change ports in .env file
PORT=3001
DB_PORT=3308
PRISMA_STUDIO_PORT=5556

# Note: If containers are already running, the setup script will skip port conflict checks
```

**Windows:**
```powershell
# Check what's using the port
netstat -ano | findstr :3000
netstat -ano | findstr :3307
netstat -ano | findstr :5555

# To find process name by PID (replace <PID> with the number from above)
tasklist | findstr <PID>

# Change ports in .env file
PORT=3001
DB_PORT=3308
PRISMA_STUDIO_PORT=5556
```

**Container Won't Start:**

**Linux/Windows:**
```bash
# PowerShell (Windows) or Bash (Linux)
# Check logs
docker compose logs backend

# Check container status
docker compose ps

# Rebuild containers
docker compose up -d --build --force-recreate
```

**Database Connection Issues:**

**Linux/Windows:**
```bash
# PowerShell (Windows) or Bash (Linux)
# Check database is healthy
docker compose ps db

# Check database logs
docker compose logs db

# Test database connection
docker compose exec db mysqladmin ping -h localhost -u root -prootpassword
```

**Auto-reload Not Working:**

**Linux/Windows:**
```bash
# PowerShell (Windows) or Bash (Linux)
# Verify NODE_ENV is set to development
docker compose exec backend sh -c 'echo $NODE_ENV'

# Check if nodemon is running (Linux)
docker compose exec backend ps aux | grep nodemon

# Check if nodemon is running (Windows PowerShell)
docker compose exec backend sh -c 'ps aux | grep nodemon'

# Restart backend
docker compose restart backend
```

**Prisma Studio Not Accessible:**

**Linux/Windows:**
```bash
# PowerShell (Windows) or Bash (Linux)
# Check Prisma Studio container status
docker compose ps prisma-studio

# View Prisma Studio logs
docker compose logs prisma-studio

# Restart Prisma Studio
docker compose restart prisma-studio

# Recreate Prisma Studio container
docker compose up -d --force-recreate prisma-studio
```

**Windows-Specific Issues:**

**Docker Desktop not starting:**
- Ensure WSL 2 is installed and updated (Windows 10/11)
- Check Windows Features: Enable "Virtual Machine Platform" and "Windows Subsystem for Linux"
- Restart Docker Desktop
- Check Docker Desktop logs: Settings → Troubleshoot → View logs

**Permission errors:**
- Run PowerShell as Administrator if needed
- Check Docker Desktop settings → Resources → File Sharing
- Ensure project directory is shared in Docker Desktop

**Port conflicts on Windows:**
- Check if Hyper-V or other virtualization software is using ports
- Disable Windows features that might conflict (IIS, etc.)
- Use different ports in `.env` file

### 📦 Manual Setup (Without Docker)

This setup works on both Linux and Windows (requires Node.js and MySQL installed locally).

#### Prerequisites

- **Node.js** (v18 or higher) - [Download](https://nodejs.org/)
- **MySQL** (8.0 or higher) - [Download for Windows](https://dev.mysql.com/downloads/mysql/) | [Install on Linux](https://dev.mysql.com/doc/mysql-installation-excerpt/8.0/en/linux-installation.html)
- **npm** (comes with Node.js)

#### 1. Install Dependencies

**Linux/Windows:**
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
APP_NAME=Supports Court Booking

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# Bcrypt
BCRYPT_SALT_ROUNDS=10

# File Upload
MAX_FILE_SIZE=5242880
UPLOAD_PATH=uploads

# Email (Optional)
EMAIL_HOST=
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=
EMAIL_PASSWORD=
EMAIL_FROM=noreply@courtwala.com
```

#### 3. Set Up Database

**Linux/Windows:**
```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations
npm run prisma:migrate

# (Optional) Seed database with sample data
npm run prisma:seed
```

#### 4. Start the Server

**Linux/Windows:**
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

#### 5. Start Prisma Studio (Optional)

**Linux/Windows:**
```bash
# In a separate terminal
npm run prisma:studio
```

Once the server is running, you can access:
- **API Server**: `http://localhost:3000`
- **API Documentation (Swagger UI)**: `http://localhost:3000/api-docs`
- **Health Check**: `http://localhost:3000/health`
- **Prisma Studio**: `http://localhost:5555` (if started manually)

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
- **Hot Reload**: Automatically reloads when Swagger configuration files change (development mode)
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
- `docker-compose.yml` - Multi-container orchestration (backend + database + Prisma Studio)
- `docker-entrypoint.sh` - Container startup script (handles migrations, seeding)
- `setup.sh` - Automated setup script for Linux/Mac
- `setup.ps1` - Automated setup script for Windows (PowerShell)
- `.env.example` - Environment variables template (automatically created by setup scripts)
- `.dockerignore` - Files excluded from Docker build context

**Note**: Prisma Studio now runs automatically as a Docker service. The `prisma-studio.sh` script is no longer needed but kept for reference.

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

