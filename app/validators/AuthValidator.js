const { body, validationResult } = require('express-validator');
const { AppError } = require('../utils/ErrorHandler');

/**
 * Validation result handler
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().reduce((acc, error) => {
      acc[error.path] = error.msg;
      return acc;
    }, {});
    throw new AppError('Validation failed', 422, formattedErrors);
  }
  next();
};

/**
 * Register validation rules
 */
const validateRegister = [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, and one number'),
  body('firstName')
    .trim()
    .notEmpty()
    .withMessage('First name is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('First name must be between 2 and 50 characters'),
  body('lastName')
    .trim()
    .notEmpty()
    .withMessage('Last name is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('Last name must be between 2 and 50 characters'),
  body('username')
    .optional()
    .trim()
    .isLength({ min: 3, max: 30 })
    .withMessage('Username must be between 3 and 30 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  body('phone')
    .optional()
    .isMobilePhone()
    .withMessage('Please provide a valid phone number'),
  body('role')
    .optional()
    .isIn(['PLAYER', 'COURT_OWNER'])
    .withMessage('Invalid role'),
  handleValidationErrors,
];

/**
 * Login validation rules
 */
const validateLogin = [
  body('emailOrUsername')
    .trim()
    .notEmpty()
    .withMessage('Email or username is required'),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  handleValidationErrors,
];

/**
 * Password reset request validation
 */
const validatePasswordResetRequest = [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  handleValidationErrors,
];

/**
 * Password reset validation
 */
const validatePasswordReset = [
  body('token')
    .notEmpty()
    .withMessage('Reset token is required'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, and one number'),
  handleValidationErrors,
];

module.exports = {
  validateRegister,
  validateLogin,
  validatePasswordResetRequest,
  validatePasswordReset,
};

