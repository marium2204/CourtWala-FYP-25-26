const { body, validationResult } = require('express-validator');
const { AppError } = require('../utils/ErrorHandler');

const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new AppError('Validation failed', 422, errors.array());
  }
  next();
};

const validateSendMatchRequest = [
  body('receiverId').notEmpty().isString(),
  body('sport')
    .notEmpty()
    .isIn(['BADMINTON', 'FOOTBALL', 'PADEL', 'CRICKET']),
  body('skillLevel')
    .optional()
    .isIn(['BEGINNER', 'INTERMEDIATE', 'ADVANCED']),
  body('message').optional().isLength({ max: 500 }),
  handleValidationErrors,
];

module.exports = { validateSendMatchRequest };
