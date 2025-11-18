const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
require('dotenv').config();

const { globalErrorHandler } = require('./app/utils/ErrorHandler');
const config = require('./config/app');
const swaggerSpec = require('./config/swagger');

const app = express();
const PORT = config.app.port;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Swagger Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Supports Court Booking API Documentation',
}));

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/auth', require('./app/routes/auth'));
app.use('/api/courts', require('./app/routes/courts'));
app.use('/api/player', require('./app/routes/player'));
app.use('/api/owner', require('./app/routes/owner'));
app.use('/api/admin', require('./app/routes/admin'));
app.use('/api/notifications', require('./app/routes/notifications'));

// Serve uploaded files
app.use('/uploads', express.static('uploads'));

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// Global error handler
app.use(globalErrorHandler);

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`📦 Environment: ${config.app.env}`);
  console.log(`📚 API Documentation: ${config.app.url}/api-docs`);
});
