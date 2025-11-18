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

const validateCreateReport = [
  body('type')
    .notEmpty()
    .withMessage('Report type is required')
    .isIn(['USER', 'COURT', 'BOOKING', 'OTHER'])
    .withMessage('Invalid report type'),
  body('message')
    .trim()
    .notEmpty()
    .withMessage('Message is required')
    .isLength({ min: 10, max: 1000 })
    .withMessage('Message must be between 10 and 1000 characters'),
  body('reportedUserId')
    .optional()
    .notEmpty()
    .withMessage('Reported user ID cannot be empty'),
  body('reportedCourtId')
    .optional()
    .notEmpty()
    .withMessage('Reported court ID cannot be empty'),
  body()
    .custom((value) => {
      if (!value.reportedUserId && !value.reportedCourtId) {
        throw new Error('Either reportedUserId or reportedCourtId is required');
      }
      return true;
    }),
  handleValidationErrors,
];

module.exports = {
  validateCreateReport,
};

