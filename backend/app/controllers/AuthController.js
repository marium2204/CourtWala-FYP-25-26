const BaseController = require('./BaseController');
const AuthService = require('../services/AuthService');
const { asyncHandler } = require('../utils/ErrorHandler');
const { getFileUrl } = require('../utils/FileUpload');

class AuthController extends BaseController {
  /**
   * Register new user
   */
  static register = asyncHandler(async (req, res) => {
    // Process file upload if present
    const data = { ...req.body };
    if (req.file) {
      data.profilePicture = getFileUrl(req.file.filename);
    }
    const result = await AuthService.register(data);
    return BaseController.success(res, result, 'Registration successful', 201);
  });

  /**
   * Login user
   */
  static login = asyncHandler(async (req, res) => {
    const { emailOrUsername, password } = req.body;
    const result = await AuthService.login(emailOrUsername, password);
    return BaseController.success(res, result, 'Login successful');
  });

  /**
   * Request password reset
   */
  static requestPasswordReset = asyncHandler(async (req, res) => {
    const { email } = req.body;
    await AuthService.generatePasswordResetToken(email);
    return BaseController.success(res, null, 'Password reset email sent');
  });

  /**
   * Reset password
   */
  static resetPassword = asyncHandler(async (req, res) => {
    const { token, password } = req.body;
    await AuthService.resetPassword(token, password);
    return BaseController.success(res, null, 'Password reset successful');
  });

  /**
   * Get current user
   */
  static me = asyncHandler(async (req, res) => {
    return BaseController.success(res, req.user, 'User retrieved successfully');
  });
}

module.exports = AuthController;

