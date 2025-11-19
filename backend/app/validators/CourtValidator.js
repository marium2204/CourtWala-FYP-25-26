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
    .isFloat({ min: 0 })
    .withMessage('Price per hour must be a positive number'),
  body('amenities')
    .optional()
    .isArray()
    .withMessage('Amenities must be an array'),
  body('images')
    .optional()
    .isArray()
    .withMessage('Images must be an array'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),
  handleValidationErrors,
];

module.exports = {
  validateCreateCourt,
};

