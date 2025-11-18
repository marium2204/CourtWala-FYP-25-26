const BaseController = require('../BaseController');
const ProfileService = require('../../services/ProfileService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class ProfileController extends BaseController {
  /**
   * Get profile
   */
  static getProfile = asyncHandler(async (req, res) => {
    const profile = await ProfileService.getProfile(req.user.id);
    return BaseController.success(res, profile, 'Profile retrieved successfully');
  });

  /**
   * Update profile
   */
  static updateProfile = asyncHandler(async (req, res) => {
    const profile = await ProfileService.updateProfile(req.user.id, req.body);
    return BaseController.success(res, profile, 'Profile updated successfully');
  });

  /**
   * Change password
   */
  static changePassword = asyncHandler(async (req, res) => {
    const { currentPassword, newPassword } = req.body;
    await ProfileService.changePassword(req.user.id, currentPassword, newPassword);
    return BaseController.success(res, null, 'Password changed successfully');
  });
}

module.exports = ProfileController;

