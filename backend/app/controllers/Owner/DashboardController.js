const BaseController = require('../BaseController');
const OwnerDashboardService = require('../../services/OwnerDashboardService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class OwnerDashboardController extends BaseController {
  /**
   * Get dashboard statistics
   */
  static getStats = asyncHandler(async (req, res) => {
    const stats = await OwnerDashboardService.getDashboardStats(req.user.id);
    return BaseController.success(res, stats, 'Dashboard statistics retrieved successfully');
  });
}

module.exports = OwnerDashboardController;

