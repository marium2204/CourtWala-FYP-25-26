const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/AuthController');
const { authenticate } = require('../middleware/AuthMiddleware');
const {
  validateRegister,
  validateLogin,
  validatePasswordResetRequest,
  validatePasswordReset,
} = require('../validators/AuthValidator');
const { uploadSingle } = require('../utils/FileUpload');
const { asyncHandler } = require('../utils/ErrorHandler');

// Multer error handler wrapper
const handleFileUpload = (uploadMiddleware) => {
  return (req, res, next) => {
    uploadMiddleware(req, res, (err) => {
      if (err) {
        // Multer errors are passed to error handler
        return next(err);
      }
      next();
    });
  };
};

// Public routes
router.post('/register', handleFileUpload(uploadSingle('profilePicture')), validateRegister, AuthController.register);
router.post('/login', validateLogin, AuthController.login);
router.post('/forgot-password', validatePasswordResetRequest, AuthController.requestPasswordReset);
router.post('/reset-password', validatePasswordReset, AuthController.resetPassword);

// Protected routes
router.get('/me', authenticate, AuthController.me);

module.exports = router;

