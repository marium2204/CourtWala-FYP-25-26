const express = require('express');
const cors = require('cors');

const path = require('path');

require('dotenv').config();

const { globalErrorHandler } = require('./app/utils/ErrorHandler');
const config = require('./config/app');

const app = express();
const PORT = process.env.PORT || config.app.port || 3000;


// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


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
app.use('/api/sports', require('./app/routes/sport'));
const chatRoutes = require('./app/routes/chat');
app.use('/api/chat', chatRoutes);
app.use('/api/community', require('./app/routes/community'));
const slotRoutes = require('./app/routes/slots');
app.use('/api', slotRoutes);
app.use('/api', require('./app/routes/testemail'));




// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// Global error handler
app.use(globalErrorHandler);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`📦 Environment: ${config.app.env}`);
});

