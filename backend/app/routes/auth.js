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


/* =========================
   PUBLIC ROUTES
========================= */

router.post(
  '/register',
  validateRegister,
  AuthController.register
);

router.post(
  '/login',
  validateLogin,
  AuthController.login
);

// 🔑 Google LOGIN (existing users)
router.post(
  '/google',
  AuthController.googleLogin
);

// 🔑 Google SIGNUP (role required)
router.post(
  '/google/complete',
  AuthController.googleComplete
);

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

router.get(
  '/me',
  authenticate,
  AuthController.me
);

module.exports = router;
