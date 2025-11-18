/**
 * Centralized Error Handler
 */
class AppError extends Error {
  constructor(message, statusCode = 400, errors = null) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Async error handler wrapper
 */
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

/**
 * Global error handler middleware
 */
const globalErrorHandler = (err, req, res, next) => {
  const ResponseHandler = require('./ResponseHandler');

  // JSON parsing errors (Express JSON parser)
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      success: false,
      message: 'Invalid JSON in request body',
      error: err.message,
    });
  }

  // Prisma errors
  if (err.code === 'P2002') {
    return ResponseHandler.error(res, 'Duplicate entry. This record already exists.', 409);
  }

  if (err.code === 'P2025') {
    return ResponseHandler.notFound(res, 'Record not found');
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return ResponseHandler.unauthorized(res, 'Invalid token');
  }

  if (err.name === 'TokenExpiredError') {
    return ResponseHandler.unauthorized(res, 'Token expired');
  }

  // Validation errors
  if (err.name === 'ValidationError' || err.errors) {
    return ResponseHandler.validationError(res, err.errors);
  }

  // Custom AppError
  if (err.isOperational) {
    return ResponseHandler.error(res, err.message, err.statusCode, err.errors);
  }

  // Default server error
  return ResponseHandler.serverError(res, err.message, err);
};

module.exports = {
  AppError,
  asyncHandler,
  globalErrorHandler,
};

