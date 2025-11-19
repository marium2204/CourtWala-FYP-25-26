#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CourtWala Backend Docker Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port is in use
port_in_use() {
    local port=$1
    if command_exists ss; then
        ss -tuln 2>/dev/null | grep -q ":$port " && return 0
        ss -tuln 2>/dev/null | grep -q ":$port$" && return 0
    elif command_exists netstat; then
        netstat -tuln 2>/dev/null | grep -q ":$port " && return 0
        netstat -tuln 2>/dev/null | grep -q ":$port$" && return 0
    elif command_exists lsof; then
        lsof -i :$port >/dev/null 2>&1 && return 0
    fi
    # Fallback: try to bind to the port
    (timeout 1 bash -c "echo >/dev/tcp/127.0.0.1/$port" 2>/dev/null) && return 0
    return 1
}

# Function to check if containers are already running
containers_running() {
    # Check if any of our containers are running using docker ps
    local running_containers=$(docker ps --format '{{.Names}}' 2>/dev/null || true)
    if echo "$running_containers" | grep -qE "courtwala_(backend|db|prisma_studio)"; then
        return 0
    fi
    # Alternative check using docker-compose ps - look for "Up" status
    local compose_output=$($DOCKER_COMPOSE ps 2>/dev/null || true)
    if echo "$compose_output" | grep -qE "courtwala_(backend|db|prisma_studio).*Up"; then
        return 0
    fi
    return 1
}

# Determine docker-compose command (support both docker-compose and docker compose)
if command_exists docker-compose; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE=""
fi

# Check if Docker is installed
echo -e "${YELLOW}[1/7] Checking Docker installation...${NC}"
if ! command_exists docker; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

if [ -z "$DOCKER_COMPOSE" ]; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✓ Docker and Docker Compose are installed (using: $DOCKER_COMPOSE)${NC}"
echo ""

# Check if .env.example exists, create if not
echo -e "${YELLOW}[2/7] Checking environment configuration...${NC}"
if [ ! -f .env.example ]; then
    echo -e "${YELLOW}⚠ .env.example not found. Creating default .env.example...${NC}"
    cat > .env.example << 'ENVEOF'
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
ENVEOF
    echo -e "${GREEN}✓ Created .env.example file${NC}"
fi

# Check if .env file exists, create from .env.example if not
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠ .env file not found. Creating from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file from .env.example${NC}"
    echo -e "${YELLOW}⚠ Please review and update .env file with your configuration${NC}"
else
    echo -e "${GREEN}✓ .env file exists${NC}"
fi

# Load environment variables from .env file
if [ -f .env ]; then
    set -a
    source .env 2>/dev/null || true
    set +a
fi
echo ""

# Check if containers are already running
DB_PORT=${DB_PORT:-3307}
APP_PORT=${PORT:-3000}
PRISMA_STUDIO_PORT=${PRISMA_STUDIO_PORT:-5555}

if containers_running; then
    echo -e "${YELLOW}[3/7] Checking for port conflicts...${NC}"
    echo -e "${GREEN}✓ Containers are already running - skipping port conflict check${NC}"
    echo -e "${YELLOW}  (Ports are in use by existing containers)${NC}"
    echo ""
else
    # Check for port conflicts only if containers are not running
    echo -e "${YELLOW}[3/7] Checking for port conflicts...${NC}"
    
    if port_in_use $DB_PORT; then
        echo -e "${RED}✗ Port $DB_PORT is already in use${NC}"
        echo -e "${YELLOW}  Please set a different DB_PORT in your .env file${NC}"
        echo -e "${YELLOW}  Example: DB_PORT=3308${NC}"
        exit 1
    fi

    if port_in_use $APP_PORT; then
        echo -e "${RED}✗ Port $APP_PORT is already in use${NC}"
        echo -e "${YELLOW}  Please set a different PORT in your .env file${NC}"
        echo -e "${YELLOW}  Example: PORT=3001${NC}"
        exit 1
    fi

    if port_in_use $PRISMA_STUDIO_PORT; then
        echo -e "${RED}✗ Port $PRISMA_STUDIO_PORT (Prisma Studio) is already in use${NC}"
        echo -e "${YELLOW}  Please set a different PRISMA_STUDIO_PORT in your .env file${NC}"
        echo -e "${YELLOW}  Example: PRISMA_STUDIO_PORT=5556${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Ports $DB_PORT (DB), $APP_PORT (App), and $PRISMA_STUDIO_PORT (Prisma Studio) are available${NC}"
    echo ""
fi

# Create uploads directory if it doesn't exist
echo -e "${YELLOW}[4/7] Creating necessary directories...${NC}"
mkdir -p uploads
chmod 755 uploads
echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Stop existing containers if running
echo -e "${YELLOW}[5/7] Stopping existing containers (if any)...${NC}"
if containers_running; then
    echo -e "${YELLOW}  Stopping running containers...${NC}"
    $DOCKER_COMPOSE down 2>/dev/null || true
    echo -e "${GREEN}✓ Stopped existing containers${NC}"
else
    echo -e "${GREEN}✓ No containers running${NC}"
fi
echo ""

# Build and start containers
echo -e "${YELLOW}[6/7] Building and starting Docker containers...${NC}"
$DOCKER_COMPOSE build --no-cache
$DOCKER_COMPOSE up -d
echo -e "${GREEN}✓ Containers started${NC}"
echo ""

# Wait for database to be ready
echo -e "${YELLOW}Waiting for database to be ready...${NC}"
MAX_ATTEMPTS=30
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if $DOCKER_COMPOSE exec -T db mysqladmin ping -h localhost -u root -prootpassword >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Database is ready${NC}"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo "Waiting for database... ($ATTEMPT/$MAX_ATTEMPTS)"
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo -e "${RED}✗ Database failed to start within expected time${NC}"
    exit 1
fi
echo ""

# Wait for backend to initialize (migrations and seeding happen automatically)
echo -e "${YELLOW}Waiting for backend to initialize...${NC}"
echo "Migrations and seeding will run automatically in the container..."
sleep 10

# Check if backend is healthy
MAX_ATTEMPTS=30
ATTEMPT=0
BACKEND_READY=false

# Try using curl if available, otherwise check container logs
if command_exists curl; then
    while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
        if curl -f http://localhost:${PORT:-3000}/health >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Backend is ready and healthy${NC}"
            BACKEND_READY=true
            break
        fi
        ATTEMPT=$((ATTEMPT + 1))
        echo "Waiting for backend... ($ATTEMPT/$MAX_ATTEMPTS)"
        sleep 2
    done
else
    # Fallback: check if container is running
    echo "Checking backend container status..."
    sleep 5
    if $DOCKER_COMPOSE ps backend | grep -q "Up"; then
        echo -e "${GREEN}✓ Backend container is running${NC}"
        BACKEND_READY=true
    fi
fi

if [ "$BACKEND_READY" = false ]; then
    echo -e "${YELLOW}⚠ Backend may still be initializing. Check logs with: $DOCKER_COMPOSE logs -f backend${NC}"
else
    echo -e "${GREEN}✓ Database setup completed${NC}"
fi
echo ""

# Setup systemd service for auto-start
echo -e "${YELLOW}[BONUS] Setting up auto-start on boot...${NC}"
SERVICE_FILE="/etc/systemd/system/courtwala-backend.service"

if [ -w /etc/systemd/system ] || sudo test -w /etc/systemd/system 2>/dev/null; then
    # Determine docker-compose command and create appropriate systemd service
    if command_exists docker-compose; then
        DOCKER_COMPOSE_CMD=$(which docker-compose)
        sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=CourtWala Backend Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$SCRIPT_DIR
ExecStart=$DOCKER_COMPOSE_CMD up -d
ExecStop=$DOCKER_COMPOSE_CMD down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
    else
        # Use docker compose (plugin version)
        DOCKER_CMD=$(which docker)
        sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=CourtWala Backend Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$SCRIPT_DIR
ExecStart=$DOCKER_CMD compose up -d
ExecStop=$DOCKER_CMD compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
    fi

    sudo systemctl daemon-reload
    sudo systemctl enable courtwala-backend.service
    echo -e "${GREEN}✓ Auto-start service enabled${NC}"
    echo -e "${GREEN}  Service will start automatically on system boot${NC}"
    echo -e "${GREEN}  To manage: sudo systemctl start/stop/restart courtwala-backend${NC}"
else
    echo -e "${YELLOW}⚠ Cannot write to /etc/systemd/system (need sudo)${NC}"
    echo -e "${YELLOW}  Skipping auto-start setup. Run with sudo to enable auto-start.${NC}"
fi
echo ""

# Show status
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Container Status:${NC}"
$DOCKER_COMPOSE ps
echo ""
echo -e "${GREEN}Useful Commands:${NC}"
echo "  View logs:        $DOCKER_COMPOSE logs -f"
echo "  Stop containers: $DOCKER_COMPOSE down"
echo "  Start containers: $DOCKER_COMPOSE up -d"
echo "  Restart:          $DOCKER_COMPOSE restart"
echo ""
echo -e "${GREEN}Backend is running at: http://localhost:${PORT:-3000}${NC}"
echo -e "${GREEN}API Docs: http://localhost:${PORT:-3000}/api-docs${NC}"
echo -e "${GREEN}Prisma Studio: http://localhost:${PRISMA_STUDIO_PORT:-5555}${NC}"
echo ""

