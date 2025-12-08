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

const validateCreateCourt = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Court name is required')
    .isLength({ min: 3, max: 100 })
    .withMessage('Court name must be between 3 and 100 characters'),
  body('address')
    .trim()
    .notEmpty()
    .withMessage('Address is required')
    .isLength({ min: 3, max: 200 })
    .withMessage('Address must be between 3 and 200 characters'),
  body('city')
    .trim()
    .notEmpty()
    .withMessage('City is required')
    .isLength({ min: 2, max: 100 })
    .withMessage('City must be between 2 and 100 characters'),
  body('state')
    .trim()
    .notEmpty()
    .withMessage('State is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('State must be between 2 and 50 characters'),
  body('zipCode')
    .trim()
    .notEmpty()
    .withMessage('Zip code is required')
    .matches(/^\d{5}(-\d{4})?$/)
    .withMessage('Zip code must be a valid format (e.g., 10001 or 10001-1234)'),
  body('sport')
    .trim()
    .notEmpty()
    .withMessage('Sport is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('Sport must be between 2 and 50 characters'),
  body('pricePerHour')
    .notEmpty()
    .withMessage('Price per hour is required')
    .customSanitizer((value) => {
      // Trim if it's a string (from multipart/form-data)
      if (typeof value === 'string') {
        return value.trim();
      }
      return value;
    })
    .isFloat({ min: 0 })
    .withMessage('Price per hour must be a positive number'),
  body('amenities')
    .optional()
    .customSanitizer((value) => {
      // Handle string arrays from multipart/form-data
      if (typeof value === 'string') {
        try {
          return JSON.parse(value);
        } catch {
          // If not JSON, treat as comma-separated
          return value.split(',').map(item => item.trim()).filter(item => item);
        }
      }
      return value;
    })
    .isArray()
    .withMessage('Amenities must be an array'),
  body('images')
    .optional()
    .customSanitizer((value) => {
      // Images are handled by multer, so this is just for validation
      // If it's an array of file objects from multer, return as is
      if (Array.isArray(value)) {
        return value;
      }
      // If it's a string (from form data), try to parse
      if (typeof value === 'string') {
        try {
          return JSON.parse(value);
        } catch {
          return [];
        }
      }
      return value;
    }),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),
  handleValidationErrors,
];

const validateUpdateCourt = [
  body('name')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Court name cannot be empty')
    .isLength({ min: 3, max: 100 })
    .withMessage('Court name must be between 3 and 100 characters'),
  body('address')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Address cannot be empty')
    .isLength({ min: 3, max: 200 })
    .withMessage('Address must be between 3 and 200 characters'),
  body('city')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('City cannot be empty')
    .isLength({ min: 2, max: 100 })
    .withMessage('City must be between 2 and 100 characters'),
  body('state')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('State cannot be empty')
    .isLength({ min: 2, max: 50 })
    .withMessage('State must be between 2 and 50 characters'),
  body('zipCode')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Zip code cannot be empty')
    .matches(/^\d{5}(-\d{4})?$/)
    .withMessage('Zip code must be a valid format (e.g., 10001 or 10001-1234)'),
  body('sport')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Sport cannot be empty')
    .isLength({ min: 2, max: 50 })
    .withMessage('Sport must be between 2 and 50 characters'),
  body('pricePerHour')
    .optional()
    .customSanitizer((value) => {
      // Trim if it's a string (from multipart/form-data)
      if (typeof value === 'string') {
        return value.trim();
      }
      return value;
    })
    .isFloat({ min: 0 })
    .withMessage('Price per hour must be a positive number'),
  body('amenities')
    .optional()
    .customSanitizer((value) => {
      // Handle string arrays from multipart/form-data
      if (typeof value === 'string') {
        try {
          return JSON.parse(value);
        } catch {
          // If not JSON, treat as comma-separated
          return value.split(',').map(item => item.trim()).filter(item => item);
        }
      }
      return value;
    })
    .isArray()
    .withMessage('Amenities must be an array'),
  body('images')
    .optional()
    .customSanitizer((value) => {
      // Images are handled by multer, so this is just for validation
      if (Array.isArray(value)) {
        return value;
      }
      if (typeof value === 'string') {
        try {
          return JSON.parse(value);
        } catch {
          return [];
        }
      }
      return value;
    }),
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

