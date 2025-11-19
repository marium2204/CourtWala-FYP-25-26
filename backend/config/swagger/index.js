const swaggerJsdoc = require('swagger-jsdoc');
const config = require('../app');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Sports Court Booking API',
      version: '1.0.0',
      description: 'A comprehensive court booking system API with multi-actor support (Players, Court Owners, and Admins)',
      contact: {
        name: 'API Support',
        email: 'sport@courtwala.com',
      },
    },
    servers: [
      {
        url: `${config.app.url}/api`,
        description: 'Development server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: false,
            },
            message: {
              type: 'string',
              example: 'Error message',
            },
            errors: {
              type: 'object',
              additionalProperties: true,
            },
          },
        },
        SuccessResponse: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: true,
            },
            message: {
              type: 'string',
              example: 'Operation successful',
            },
            data: {
              type: 'object',
              additionalProperties: true,
            },
          },
        },
        User: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              example: 'user123',
            },
            email: {
              type: 'string',
              example: 'user@example.com',
            },
            username: {
              type: 'string',
              example: 'johndoe',
            },
            firstName: {
              type: 'string',
              example: 'John',
            },
            lastName: {
              type: 'string',
              example: 'Doe',
            },
            role: {
              type: 'string',
              enum: ['PLAYER', 'COURT_OWNER', 'ADMIN'],
              example: 'PLAYER',
            },
            status: {
              type: 'string',
              enum: ['ACTIVE', 'INACTIVE', 'SUSPENDED'],
              example: 'ACTIVE',
            },
            profilePicture: {
              type: 'string',
              nullable: true,
              example: 'uploads/profile.jpg',
            },
          },
        },
        Court: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              example: 'court123',
            },
            name: {
              type: 'string',
              example: 'Central Court',
            },
            description: {
              type: 'string',
              example: 'A premium court facility',
            },
            address: {
              type: 'string',
              example: '123 Main St, City',
            },
            city: {
              type: 'string',
              example: 'New York',
            },
            state: {
              type: 'string',
              example: 'NY',
            },
            zipCode: {
              type: 'string',
              example: '10001',
            },
            pricePerHour: {
              type: 'number',
              example: 50.00,
            },
            amenities: {
              type: 'array',
              items: {
                type: 'string',
              },
              example: ['Parking', 'Locker Room', 'Showers'],
            },
            images: {
              type: 'array',
              items: {
                type: 'string',
              },
              example: ['uploads/court1.jpg'],
            },
            status: {
              type: 'string',
              enum: ['PENDING', 'APPROVED', 'REJECTED'],
              example: 'APPROVED',
            },
            ownerId: {
              type: 'string',
              example: 'owner123',
            },
          },
        },
        Booking: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              example: 'booking123',
            },
            courtId: {
              type: 'string',
              example: 'court123',
            },
            playerId: {
              type: 'string',
              example: 'player123',
            },
            date: {
              type: 'string',
              format: 'date',
              example: '2024-01-15',
            },
            startTime: {
              type: 'string',
              example: '10:00',
            },
            endTime: {
              type: 'string',
              example: '12:00',
            },
            status: {
              type: 'string',
              enum: ['PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'COMPLETED'],
              example: 'PENDING',
            },
            needsOpponent: {
              type: 'boolean',
              example: false,
            },
            totalPrice: {
              type: 'number',
              example: 100.00,
            },
          },
        },
      },
    },
    tags: [
      { name: 'Authentication', description: 'User authentication endpoints' },
      { name: 'Courts', description: 'Public court browsing endpoints' },
      { name: 'Admin', description: 'Admin management endpoints' },
      { name: 'Owner', description: 'Court owner endpoints' },
      { name: 'Player', description: 'Player endpoints' },
      { name: 'Notifications', description: 'Notification endpoints' },
    ],
  },
  apis: [
    './config/swagger/auth.js',
    './config/swagger/courts.js',
    './config/swagger/admin/*.js',
    './config/swagger/owner/*.js',
    './config/swagger/player/*.js',
    './config/swagger/notifications.js',
  ],
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;

