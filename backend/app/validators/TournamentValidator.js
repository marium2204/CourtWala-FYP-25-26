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
 * Validate create tournament
 */
const validateCreateTournament = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Tournament name is required')
    .isLength({ min: 3, max: 100 })
    .withMessage('Tournament name must be between 3 and 100 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),
  body('sport')
    .trim()
    .notEmpty()
    .withMessage('Sport is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('Sport must be between 2 and 50 characters'),
  body('skillLevel')
    .optional()
    .isIn(['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'PROFESSIONAL'])
    .withMessage('Skill level must be one of: BEGINNER, INTERMEDIATE, ADVANCED, PROFESSIONAL'),
  body('startDate')
    .notEmpty()
    .withMessage('Start date is required')
    .isISO8601()
    .withMessage('Start date must be a valid ISO 8601 date')
    .custom((value) => {
      if (new Date(value) < new Date()) {
        throw new Error('Start date cannot be in the past');
      }
      return true;
    }),
  body('endDate')
    .notEmpty()
    .withMessage('End date is required')
    .isISO8601()
    .withMessage('End date must be a valid ISO 8601 date')
    .custom((value, { req }) => {
      if (req.body.startDate && new Date(value) < new Date(req.body.startDate)) {
        throw new Error('End date must be after start date');
      }
      return true;
    }),
  body('maxParticipants')
    .notEmpty()
    .withMessage('Max participants is required')
    .isInt({ min: 2 })
    .withMessage('Max participants must be at least 2'),
  handleValidationErrors,
];

/**
 * Validate update tournament
 */
const validateUpdateTournament = [
  body('name')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Tournament name cannot be empty')
    .isLength({ min: 3, max: 100 })
    .withMessage('Tournament name must be between 3 and 100 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),
  body('sport')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Sport cannot be empty')
    .isLength({ min: 2, max: 50 })
    .withMessage('Sport must be between 2 and 50 characters'),
  body('skillLevel')
    .optional()
    .isIn(['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'PROFESSIONAL'])
    .withMessage('Skill level must be one of: BEGINNER, INTERMEDIATE, ADVANCED, PROFESSIONAL'),
  body('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid ISO 8601 date')
    .custom((value) => {
      if (new Date(value) < new Date()) {
        throw new Error('Start date cannot be in the past');
      }
      return true;
    }),
  body('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid ISO 8601 date')
    .custom((value, { req }) => {
      const startDate = req.body.startDate || value;
      if (startDate && new Date(value) < new Date(startDate)) {
        throw new Error('End date must be after start date');
      }
      return true;
    }),
  body('maxParticipants')
    .optional()
    .isInt({ min: 2 })
    .withMessage('Max participants must be at least 2'),
  body('status')
    .optional()
    .isIn(['UPCOMING', 'ONGOING', 'COMPLETED', 'CANCELLED'])
    .withMessage('Status must be one of: UPCOMING, ONGOING, COMPLETED, CANCELLED'),
  handleValidationErrors,
];

module.exports = {
  validateCreateTournament,
  validateUpdateTournament,
};

