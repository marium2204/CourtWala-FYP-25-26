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

/**
 * Validate send match request
 * ✔ Supports Prisma CUID
 * ✔ Supports UUID (future-safe)
 */
const validateSendMatchRequest = [
  body('receiverId')
    .notEmpty()
    .withMessage('Receiver ID is required')
    .isString()
    .withMessage('Receiver ID must be a string')
    .isLength({ min: 10, max: 50 })
    .withMessage('Receiver ID must be a valid ID'),

  body('bookingId')
    .optional()
    .isString()
    .withMessage('Booking ID must be a string')
    .isLength({ min: 10, max: 50 })
    .withMessage('Booking ID must be a valid ID'),

  body('sport')
    .trim()
    .notEmpty()
    .withMessage('Sport is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('Sport must be between 2 and 50 characters'),

  body('skillLevel')
    .optional()
    .isIn(['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'PROFESSIONAL'])
    .withMessage(
      'Skill level must be one of: BEGINNER, INTERMEDIATE, ADVANCED, PROFESSIONAL'
    ),

  body('message')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Message must not exceed 500 characters'),

  handleValidationErrors,
];

module.exports = {
  validateSendMatchRequest,
};
