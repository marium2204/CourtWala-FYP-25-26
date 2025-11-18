# Supports Court Booking API

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

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

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

### 3. Set Up Database

```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations
npm run prisma:migrate

# (Optional) Seed database with sample data
npm run prisma:seed
```

### 4. Start the Server

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

- **Admin**: admin@courtwala.com / admin123
- **Court Owner**: owner@courtwala.com / owner123
- **Player**: player@courtwala.com / player123

## Development Principles

- **DRY (Don't Repeat Yourself)**: Reusable services and utilities
- **Separation of Concerns**: Controllers, Services, and Routes are separated
- **Loose Coupling**: Services are independent and can be easily tested
- **Consistent Responses**: Standardized response format across all endpoints

## License

ISC

