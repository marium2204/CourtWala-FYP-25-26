const BaseController = require('../BaseController');
const OwnerProfileService = require('../../services/OwnerProfileService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class OwnerProfileController extends BaseController {
  static getProfile = asyncHandler(async (req, res) => {
    const profile = await OwnerProfileService.getProfile(req.user.id);
    return BaseController.success(res, profile, 'Owner profile fetched successfully');
  });

  /**
   * Update logged-in owner profile
   */
  static updateProfile = asyncHandler(async (req, res) => {
    const updated = await OwnerProfileService.updateProfile(req.user.id, req.body);
    return BaseController.success(res, updated, 'Owner profile updated successfully');
  });
}

module.exports = OwnerProfileController;
