/**
 * Standardized Response Handler
 * Provides consistent API response format
 */
class ResponseHandler {
  /**
   * Success response
   */
  static success(res, data = null, message = 'Success', statusCode = 200) {
    return res.status(statusCode).json({
      success: true,
      message,
      data,
    });
  }

  /**
   * Error response
   */
  static error(res, message = 'An error occurred', statusCode = 400, errors = null) {
    return res.status(statusCode).json({
      success: false,
      message,
      errors,
    });
  }

  /**
   * Validation error response
   */
  static validationError(res, errors) {
    return res.status(422).json({
      success: false,
      message: 'Validation failed',
      errors,
    });
  }

  /**
   * Unauthorized response
   */
  static unauthorized(res, message = 'Unauthorized') {
    return res.status(401).json({
      success: false,
      message,
    });
  }

  /**
   * Forbidden response
   */
  static forbidden(res, message = 'Forbidden') {
    return res.status(403).json({
      success: false,
      message,
    });
  }

  /**
   * Not found response
   */
  static notFound(res, message = 'Resource not found') {
    return res.status(404).json({
      success: false,
      message,
    });
  }

  /**
   * Server error response
   */
  static serverError(res, message = 'Internal server error', error = null) {
    if (process.env.NODE_ENV === 'development' && error) {
      console.error(error);
    }
    return res.status(500).json({
      success: false,
      message,
      ...(process.env.NODE_ENV === 'development' && { error: error?.message }),
    });
  }
}

module.exports = ResponseHandler;

