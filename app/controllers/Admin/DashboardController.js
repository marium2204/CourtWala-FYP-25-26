const BaseController = require('../BaseController');
const AdminService = require('../../services/AdminService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class AdminDashboardController extends BaseController {
  /**
   * Get dashboard statistics
   */
  static getStats = asyncHandler(async (req, res) => {
    const stats = await AdminService.getDashboardStats();
    return BaseController.success(res, stats, 'Dashboard statistics retrieved successfully');
  });
}

module.exports = AdminDashboardController;

