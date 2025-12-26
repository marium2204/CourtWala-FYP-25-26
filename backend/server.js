const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const { globalErrorHandler } = require('./app/utils/ErrorHandler');
const config = require('./config/app');

const app = express();
const PORT = config.app.port;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Function to load swagger spec
let swaggerSpec = null;
function loadSwaggerSpec() {
  // Clear require cache to force reload
  const swaggerPath = path.join(__dirname, 'config', 'swagger', 'index.js');
  delete require.cache[require.resolve('./config/swagger')];
  swaggerSpec = require('./config/swagger');
  return swaggerSpec;
}

// Load initial swagger spec
loadSwaggerSpec();

// Swagger Documentation with hot reload support
const swaggerOptions = {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Sports Court Booking API Documentation',
};

// Create a middleware function that reloads spec in development
const swaggerSetupMiddleware = (req, res, next) => {
  // Reload swagger spec on each request in development mode
  if (config.app.env === 'development') {
    try {
      const spec = loadSwaggerSpec();
      return swaggerUi.setup(spec, swaggerOptions)(req, res, next);
    } catch (error) {
      console.error('Error reloading Swagger spec:', error);
      // Fallback to cached spec if reload fails
      return swaggerUi.setup(swaggerSpec, swaggerOptions)(req, res, next);
    }
  } else {
    // Production mode - use cached spec
    return swaggerUi.setup(swaggerSpec, swaggerOptions)(req, res, next);
  }
};

app.use('/api-docs', swaggerUi.serve, swaggerSetupMiddleware);

// Watch for changes in swagger files (development mode only)
if (config.app.env === 'development') {
  try {
    const chokidar = require('chokidar');
    const swaggerDir = path.join(__dirname, 'config', 'swagger');
    
    // Watch all swagger files
    const watcher = chokidar.watch([
      path.join(swaggerDir, '**/*.js'),
      path.join(__dirname, 'config', 'app.js'), // Also watch app.js for config changes
    ], {
      ignored: /node_modules/,
      persistent: true,
      ignoreInitial: true,
    });

    watcher.on('change', (filePath) => {
      console.log(`📝 Swagger file changed: ${path.relative(__dirname, filePath)}`);
      console.log('🔄 Reloading Swagger documentation...');
      try {
        loadSwaggerSpec();
        console.log('✅ Swagger documentation reloaded successfully');
      } catch (error) {
        console.error('❌ Error reloading Swagger spec:', error.message);
      }
    });

    console.log('👀 Watching Swagger files for changes...');
  } catch (error) {
    // chokidar not available, fallback to fs.watch
    console.log('⚠️  chokidar not available, using fs.watch for Swagger hot reload');
    const swaggerDir = path.join(__dirname, 'config', 'swagger');
    
    const watchSwaggerFiles = (dir) => {
      fs.readdir(dir, { withFileTypes: true }, (err, entries) => {
        if (err) return;
        
        entries.forEach(entry => {
          const fullPath = path.join(dir, entry.name);
          if (entry.isDirectory()) {
            watchSwaggerFiles(fullPath);
          } else if (entry.name.endsWith('.js')) {
            fs.watchFile(fullPath, { interval: 1000 }, (curr, prev) => {
              if (curr.mtime !== prev.mtime) {
                console.log(`📝 Swagger file changed: ${path.relative(__dirname, fullPath)}`);
                console.log('🔄 Reloading Swagger documentation...');
                try {
                  loadSwaggerSpec();
                  console.log('✅ Swagger documentation reloaded successfully');
                } catch (error) {
                  console.error('❌ Error reloading Swagger spec:', error.message);
                }
              }
            });
          }
        });
      });
    };
    
    watchSwaggerFiles(swaggerDir);
    // Also watch app.js
    fs.watchFile(path.join(__dirname, 'config', 'app.js'), { interval: 1000 }, (curr, prev) => {
      if (curr.mtime !== prev.mtime) {
        console.log('📝 Config file changed, reloading Swagger documentation...');
        try {
          loadSwaggerSpec();
          console.log('✅ Swagger documentation reloaded successfully');
        } catch (error) {
          console.error('❌ Error reloading Swagger spec:', error.message);
        }
      }
    });
  }
}

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
const chatRoutes = require('./app/routes/chat');
app.use('/api/chat', chatRoutes);
const slotRoutes = require('./app/routes/slots');
app.use('/api', slotRoutes);






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

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`📦 Environment: ${config.app.env}`);
  console.log(`📚 API Documentation: ${config.app.url}/api-docs`);
});

