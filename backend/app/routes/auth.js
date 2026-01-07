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

// Multer error handler wrapper
const handleFileUpload = (uploadMiddleware) => {
  return (req, res, next) => {
    uploadMiddleware(req, res, (err) => {
      if (err) return next(err);
      next();
    });
  };
};

/* =========================
   PUBLIC ROUTES
========================= */

router.post(
  '/register',
  handleFileUpload(uploadSingle('profilePicture')),
  validateRegister,
  AuthController.register
);

router.post('/login', validateLogin, AuthController.login);

// 🔑 Google LOGIN (existing users)
router.post('/google', AuthController.googleLogin);

// 🔑 Google SIGNUP (role required)
router.post('/google/complete', AuthController.googleComplete);

router.post(
  '/forgot-password',
  validatePasswordResetRequest,
  AuthController.requestPasswordReset
);

router.post(
  '/reset-password',
  validatePasswordReset,
  AuthController.resetPassword
);

/* =========================
   PROTECTED ROUTES
========================= */

router.get('/me', authenticate, AuthController.me);

module.exports = router;
