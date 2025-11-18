const ResponseHandler = require('../utils/ResponseHandler');
const { asyncHandler } = require('../utils/ErrorHandler');

/**
 * Base Controller with common methods
 * All controllers should extend this for consistency
 */
class BaseController {
  /**
   * Success response wrapper
   */
  static success(res, data = null, message = 'Success', statusCode = 200) {
    return ResponseHandler.success(res, data, message, statusCode);
  }

  /**
   * Error response wrapper
   */
  static error(res, message = 'An error occurred', statusCode = 400, errors = null) {
    return ResponseHandler.error(res, message, statusCode, errors);
  }

  /**
   * Async handler wrapper for controllers
   */
  static asyncHandler(fn) {
    return asyncHandler(fn);
  }
}

module.exports = BaseController;

