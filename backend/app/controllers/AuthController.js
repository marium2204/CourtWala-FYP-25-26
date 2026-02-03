const BaseController = require('./BaseController');
const AuthService = require('../services/AuthService');
const ProfileService = require('../services/ProfileService');


// Safe async handler wrapper (prevents undefined handlers)
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

class AuthController extends BaseController {
  /* =========================
     REGISTER (EMAIL)
  ========================= */
  static register = asyncHandler(async (req, res) => {
    const data = { ...req.body };


    const result = await AuthService.register(data);
    return BaseController.success(
      res,
      result,
      'Registration successful',
      201
    );
  });

  /* =========================
     LOGIN (EMAIL)
  ========================= */
  static login = asyncHandler(async (req, res) => {
    const { emailOrUsername, password } = req.body;
    const result = await AuthService.login(emailOrUsername, password);
    return BaseController.success(res, result, 'Login successful');
  });

  /* =========================
     GOOGLE LOGIN (EXISTING USER)
  ========================= */
  static googleLogin = asyncHandler(async (req, res) => {
    const { idToken } = req.body;

    if (!idToken) {
      return BaseController.error(res, 'ID token is required', 400);
    }

    const result = await AuthService.googleLogin(idToken);
    return BaseController.success(res, result, 'Google login successful');
  });

  /* =========================
     GOOGLE SIGNUP (ROLE REQUIRED)
  ========================= */
  static googleComplete = asyncHandler(async (req, res) => {
    const { idToken, role } = req.body;

    if (!idToken) {
      return BaseController.error(res, 'ID token is required', 400);
    }

    if (!role || !['PLAYER', 'COURT_OWNER'].includes(role)) {
      return BaseController.error(res, 'Invalid role', 400);
    }

    const result = await AuthService.googleComplete(idToken, role);
    return BaseController.success(
      res,
      result,
      'Google signup completed',
      201
    );
  });

  /* =========================
   PASSWORD RESET (OTP)
========================= */
static requestPasswordReset = asyncHandler(async (req, res) => {
  const { email } = req.body;
  await AuthService.sendResetOtp(email);
  return BaseController.success(res, null, 'OTP sent to email');
});

static resetPassword = asyncHandler(async (req, res) => {
  const { email, otp, password } = req.body;
  await AuthService.resetPasswordWithOtp(email, otp, password);
  return BaseController.success(res, null, 'Password reset successful');
});

  /* =========================
     CURRENT USER
  ========================= */
  static me = asyncHandler(async (req, res) => {
  const user = await ProfileService.getProfile(req.user.id);
  return BaseController.success(res, user, 'User retrieved successfully');
});

}

module.exports = AuthController;
