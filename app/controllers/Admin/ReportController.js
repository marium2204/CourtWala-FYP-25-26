const BaseController = require('../BaseController');
const AdminService = require('../../services/AdminService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class AdminReportController extends BaseController {
  /**
   * Get all reports
   */
  static getAll = asyncHandler(async (req, res) => {
    const { status, type, page = 1, limit = 20 } = req.query;
    const result = await AdminService.getReports({
      status,
      type,
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Reports retrieved successfully');
  });

  /**
   * Resolve report
   */
  static resolve = asyncHandler(async (req, res) => {
    const report = await AdminService.resolveReport(req.params.id, req.user.id);
    return BaseController.success(res, report, 'Report resolved successfully');
  });
}

module.exports = AdminReportController;

