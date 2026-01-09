const BaseController = require('../BaseController');
const ProfileService = require('../../services/ProfileService');

// Safe async handler
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

class ProfileController extends BaseController {
  static getProfile = asyncHandler(async (req, res) => {
    const profile = await ProfileService.getProfile(req.user.id);
    return BaseController.success(res, profile, 'Profile retrieved successfully');
  });

  static updateProfile = asyncHandler(async (req, res) => {
    const profile = await ProfileService.updateProfile(req.user.id, req.body);
    return BaseController.success(res, profile, 'Profile updated successfully');
  });

  static updateSports = asyncHandler(async (req, res) => {
    const result = await ProfileService.updateSports(
      req.user.id,
      req.body.sports
    );
    return BaseController.success(res, result, 'Sports updated successfully');
  });

  static changePassword = asyncHandler(async (req, res) => {
    const { currentPassword, newPassword } = req.body;
    await ProfileService.changePassword(
      req.user.id,
      currentPassword,
      newPassword
    );
    return BaseController.success(res, null, 'Password changed successfully');
  });
}

module.exports = ProfileController;
