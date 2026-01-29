const { body, validationResult } = require('express-validator');
const { AppError } = require('../utils/ErrorHandler');

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
   CREATE COURT VALIDATION
========================= */
const validateCreateCourt = [
  body('name')
    .trim()
    .notEmpty().withMessage('Court name is required')
    .isLength({ min: 3, max: 100 })
    .withMessage('Court name must be between 3 and 100 characters'),

  body('address')
    .trim()
    .notEmpty().withMessage('Address is required')
    .isLength({ min: 3, max: 200 })
    .withMessage('Address must be between 3 and 200 characters'),

  body('city')
    .trim()
    .notEmpty().withMessage('City is required')
    .isLength({ min: 2, max: 100 })
    .withMessage('City must be between 2 and 100 characters'),

  body('state')
    .trim()
    .notEmpty().withMessage('State is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('State must be between 2 and 50 characters'),

  body('zipCode')
    .trim()
    .notEmpty().withMessage('Zip code is required')
    .matches(/^\d{5}(-\d{4})?$/)
    .withMessage('Zip code must be a valid format (e.g., 10001 or 10001-1234)'),

  // 🔥 MULTI-SPORT (REPLACES `sport`)
  body('sports')
    .notEmpty().withMessage('At least one sport is required')
    .customSanitizer((value) => {
      if (typeof value === 'string') {
        try {
          return JSON.parse(value);
        } catch {
          return [];
        }
      }
      return value;
    })
    .isArray({ min: 1 })
    .withMessage('Sports must be a non-empty array'),

  body('pricePerHour')
    .notEmpty().withMessage('Price per hour is required')
    .customSanitizer((value) =>
      typeof value === 'string' ? value.trim() : value
    )
    .isFloat({ min: 0 })
    .withMessage('Price per hour must be a positive number'),

  body('amenities')
    .optional()
    .customSanitizer((value) => {
      if (typeof value === 'string') {
        try {
          return JSON.parse(value);
        } catch {
          return value
            .split(',')
            .map((item) => item.trim())
            .filter(Boolean);
        }
      }
      return value;
    })
    .isArray()
    .withMessage('Amenities must be an array'),

  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),

  handleValidationErrors,
];

/* =========================
   UPDATE COURT VALIDATION
========================= */
const validateUpdateCourt = [
  body('name')
    .optional()
    .trim()
    .notEmpty().withMessage('Court name cannot be empty')
    .isLength({ min: 3, max: 100 })
    .withMessage('Court name must be between 3 and 100 characters'),

  body('address')
    .optional()
    .trim()
    .notEmpty().withMessage('Address cannot be empty')
    .isLength({ min: 3, max: 200 })
    .withMessage('Address must be between 3 and 200 characters'),

  body('city')
    .optional()
    .trim()
    .notEmpty().withMessage('City cannot be empty')
    .isLength({ min: 2, max: 100 })
    .withMessage('City must be between 2 and 100 characters'),

  body('state')
    .optional()
    .trim()
    .notEmpty().withMessage('State cannot be empty')
    .isLength({ min: 2, max: 50 })
    .withMessage('State must be between 2 and 50 characters'),

  body('zipCode')
    .optional()
    .trim()
    .notEmpty().withMessage('Zip code cannot be empty')
    .matches(/^\d{5}(-\d{4})?$/)
    .withMessage('Zip code must be a valid format'),

  // 🔥 MULTI-SPORT UPDATE
  body('sports')
    .optional()
    .customSanitizer((value) => {
      if (typeof value === 'string') {
        try {
          return JSON.parse(value);
        } catch {
          return [];
        }
      }
      return value;
    })
    .isArray()
    .withMessage('Sports must be an array'),

  body('pricePerHour')
    .optional()
    .customSanitizer((value) =>
      typeof value === 'string' ? value.trim() : value
    )
    .isFloat({ min: 0 })
    .withMessage('Price per hour must be a positive number'),

  body('amenities')
    .optional()
    .customSanitizer((value) => {
      if (typeof value === 'string') {
        try {
          return JSON.parse(value);
        } catch {
          return value
            .split(',')
            .map((item) => item.trim())
            .filter(Boolean);
        }
      }
      return value;
    })
    .isArray()
    .withMessage('Amenities must be an array'),

  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),

  handleValidationErrors,
];

module.exports = {
  validateCreateCourt,
  validateUpdateCourt,
};
