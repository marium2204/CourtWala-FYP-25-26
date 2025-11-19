# CourtWala Backend Docker Setup Script for Windows
# Run this script in PowerShell: .\setup.ps1

$ErrorActionPreference = "Stop"

# Colors for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Green "========================================"
Write-ColorOutput Green "  CourtWala Backend Docker Setup"
Write-ColorOutput Green "========================================"
Write-Output ""

# Get the directory where the script is located
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $SCRIPT_DIR

# Check if Docker is installed
Write-ColorOutput Yellow "[1/6] Checking Docker installation..."
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not found"
    }
    Write-ColorOutput Green "✓ Docker is installed: $dockerVersion"
} catch {
    Write-ColorOutput Red "✗ Docker is not installed or not in PATH"
    Write-Output "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
    exit 1
}

# Check if Docker Compose is available
try {
    $composeVersion = docker compose version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose not found"
    }
    Write-ColorOutput Green "✓ Docker Compose is available"
} catch {
    Write-ColorOutput Red "✗ Docker Compose is not available"
    Write-Output "Please ensure Docker Desktop is installed and running"
    exit 1
}
Write-Output ""

# Check if Docker is running
Write-ColorOutput Yellow "[2/6] Checking if Docker is running..."
try {
    docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
    Write-ColorOutput Green "✓ Docker is running"
} catch {
    Write-ColorOutput Red "✗ Docker is not running"
    Write-Output "Please start Docker Desktop and try again"
    exit 1
}
Write-Output ""

# Check if .env.example exists, create if not
Write-ColorOutput Yellow "[3/6] Checking environment configuration..."
if (-Not (Test-Path ".env.example")) {
    Write-ColorOutput Yellow "⚠ .env.example not found. Creating default .env.example..."
    @"
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

# Database URL (automatically set by docker-compose.yml, but can be overridden)
# DATABASE_URL=mysql://courtwala_user:courtwala_password@db:3306/courtwala

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
"@ | Out-File -FilePath ".env.example" -Encoding utf8
    Write-ColorOutput Green "✓ Created .env.example file"
}

# Check if .env file exists, create from .env.example if not
if (-Not (Test-Path ".env")) {
    Write-ColorOutput Yellow "⚠ .env file not found. Creating from .env.example..."
    Copy-Item ".env.example" ".env"
    Write-ColorOutput Green "✓ Created .env file from .env.example"
    Write-ColorOutput Yellow "⚠ Please review and update .env file with your configuration"
} else {
    Write-ColorOutput Green "✓ .env file exists"
}
Write-Output ""

# Create uploads directory if it doesn't exist
Write-ColorOutput Yellow "[4/6] Creating necessary directories..."
if (-Not (Test-Path "uploads")) {
    New-Item -ItemType Directory -Path "uploads" | Out-Null
}
Write-ColorOutput Green "✓ Directories created"
Write-Output ""

# Stop existing containers if running
Write-ColorOutput Yellow "[5/6] Stopping existing containers (if any)..."
try {
    docker compose down 2>&1 | Out-Null
    Write-ColorOutput Green "✓ Cleaned up existing containers"
} catch {
    Write-ColorOutput Yellow "⚠ No existing containers to stop"
}
Write-Output ""

# Build and start containers
Write-ColorOutput Yellow "[6/6] Building and starting Docker containers..."
Write-Output "This may take a few minutes..."
try {
    docker compose build --no-cache
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed"
    }
    
    docker compose up -d
    if ($LASTEXITCODE -ne 0) {
        throw "Start failed"
    }
    Write-ColorOutput Green "✓ Containers started"
} catch {
    Write-ColorOutput Red "✗ Failed to start containers"
    Write-Output "Check logs with: docker compose logs"
    exit 1
}
Write-Output ""

# Wait for database to be ready
Write-ColorOutput Yellow "Waiting for database to be ready..."
$MAX_ATTEMPTS = 30
$ATTEMPT = 0
$DB_READY = $false

while ($ATTEMPT -lt $MAX_ATTEMPTS) {
    try {
        $result = docker compose exec -T db mysqladmin ping -h localhost -u root -prootpassword 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput Green "✓ Database is ready"
            $DB_READY = $true
            break
        }
    } catch {
        # Continue waiting
    }
    $ATTEMPT++
    Write-Output "Waiting for database... ($ATTEMPT/$MAX_ATTEMPTS)"
    Start-Sleep -Seconds 2
}

if (-Not $DB_READY) {
    Write-ColorOutput Red "✗ Database failed to start within expected time"
    Write-Output "Check logs with: docker compose logs db"
    exit 1
}
Write-Output ""

# Wait for backend to initialize
Write-ColorOutput Yellow "Waiting for backend to initialize..."
Write-Output "Migrations and seeding will run automatically in the container..."
Start-Sleep -Seconds 10

# Check if backend is healthy
$MAX_ATTEMPTS = 30
$ATTEMPT = 0
$BACKEND_READY = $false

while ($ATTEMPT -lt $MAX_ATTEMPTS) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-ColorOutput Green "✓ Backend is ready and healthy"
            $BACKEND_READY = $true
            break
        }
    } catch {
        # Continue waiting
    }
    $ATTEMPT++
    Write-Output "Waiting for backend... ($ATTEMPT/$MAX_ATTEMPTS)"
    Start-Sleep -Seconds 2
}

if (-Not $BACKEND_READY) {
    Write-ColorOutput Yellow "⚠ Backend may still be initializing. Check logs with: docker compose logs -f backend"
} else {
    Write-ColorOutput Green "✓ Setup completed successfully"
}
Write-Output ""

# Show status
Write-ColorOutput Green "========================================"
Write-ColorOutput Green "  Setup Complete!"
Write-ColorOutput Green "========================================"
Write-Output ""
Write-ColorOutput Green "Container Status:"
docker compose ps
Write-Output ""
Write-ColorOutput Green "Useful Commands:"
Write-Output "  View logs:        docker compose logs -f"
Write-Output "  Stop containers:  docker compose down"
Write-Output "  Start containers: docker compose up -d"
Write-Output "  Restart:          docker compose restart"
Write-Output ""
Write-ColorOutput Green "Backend is running at: http://localhost:3000"
Write-ColorOutput Green "API Docs: http://localhost:3000/api-docs"
Write-ColorOutput Green "Prisma Studio: http://localhost:5555"
Write-Output ""

