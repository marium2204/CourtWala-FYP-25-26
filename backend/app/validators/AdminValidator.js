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
 * Validate update user status
 */
const validateUpdateUserStatus = [
  body('status')
    .notEmpty()
    .withMessage('Status is required')
    .isIn(['ACTIVE', 'BLOCKED', 'SUSPENDED'])
    .withMessage('Status must be one of: ACTIVE, BLOCKED, SUSPENDED'),
  handleValidationErrors,
];

/**
 * Validate update court status
 * Note: APPROVED is accepted but will be normalized to ACTIVE by the service
 */
const validateUpdateCourtStatus = [
  body('status')
    .notEmpty()
    .withMessage('Status is required')
    .isIn(['ACTIVE', 'INACTIVE', 'REJECTED', 'APPROVED'])
    .withMessage('Status must be one of: ACTIVE, INACTIVE, REJECTED, APPROVED (APPROVED maps to ACTIVE)'),
  handleValidationErrors,
];

/**
 * Validate create announcement
 */
const validateCreateAnnouncement = [
  body('title')
    .trim()
    .notEmpty()
    .withMessage('Title is required')
    .isLength({ min: 3, max: 200 })
    .withMessage('Title must be between 3 and 200 characters'),
  body('message')
    .trim()
    .notEmpty()
    .withMessage('Message is required')
    .isLength({ min: 10, max: 2000 })
    .withMessage('Message must be between 10 and 2000 characters'),
  body('targetAudience')
    .isArray({ min: 1 })
    .withMessage('Target audience must be a non-empty array')
    .custom((value) => {
      const validRoles = ['PLAYER', 'COURT_OWNER'];
      const invalidRoles = value.filter((role) => !validRoles.includes(role));
      if (invalidRoles.length > 0) {
        throw new Error(`Invalid roles: ${invalidRoles.join(', ')}. Valid roles are: ${validRoles.join(', ')}`);
      }
      return true;
    }),
  body('scheduledAt')
    .optional()
    .isISO8601()
    .withMessage('Scheduled date must be a valid ISO 8601 date')
    .custom((value) => {
      if (new Date(value) < new Date()) {
        throw new Error('Scheduled date cannot be in the past');
      }
      return true;
    }),
  handleValidationErrors,
];

module.exports = {
  validateUpdateUserStatus,
  validateUpdateCourtStatus,
  validateCreateAnnouncement,
};

