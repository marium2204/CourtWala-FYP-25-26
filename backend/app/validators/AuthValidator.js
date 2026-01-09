const { body, validationResult } = require('express-validator');
const { AppError } = require('../utils/ErrorHandler');

/* =========================
   COMMON ERROR HANDLER
========================= */
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

/* =========================
   REGISTER
========================= */
const validateRegister = [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address'),

  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),

  body('firstName')
    .notEmpty()
    .withMessage('First name is required'),

  body('lastName')
    .notEmpty()
    .withMessage('Last name is required'),

  body('phone')
    .optional()
    .matches(/^03\d{9}$/)
    .withMessage('Phone must start with 03 and contain 11 digits'),

  body('role')
    .optional()
    .isIn(['PLAYER', 'COURT_OWNER'])
    .withMessage('Invalid role'),

  handleValidationErrors,
];

/* =========================
   LOGIN
========================= */
const validateLogin = [
  body('emailOrUsername')
    .notEmpty()
    .withMessage('Email or username is required'),

  body('password')
    .notEmpty()
    .withMessage('Password is required'),

  handleValidationErrors,
];

/* =========================
   PASSWORD RESET REQUEST
========================= */
const validatePasswordResetRequest = [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address'),

  handleValidationErrors,
];

/* =========================
   PASSWORD RESET
========================= */
const validatePasswordReset = [
  body('token')
    .notEmpty()
    .withMessage('Reset token is required'),

  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),

  handleValidationErrors,
];

module.exports = {
  validateRegister,
  validateLogin,
  validatePasswordResetRequest,
  validatePasswordReset,
};
