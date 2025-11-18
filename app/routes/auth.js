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

// Public routes
router.post('/register', validateRegister, AuthController.register);
router.post('/login', validateLogin, AuthController.login);
router.post('/forgot-password', validatePasswordResetRequest, AuthController.requestPasswordReset);
router.post('/reset-password', validatePasswordReset, AuthController.resetPassword);

// Protected routes
router.get('/me', authenticate, AuthController.me);

module.exports = router;

