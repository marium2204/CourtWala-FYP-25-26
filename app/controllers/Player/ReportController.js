const BaseController = require('../BaseController');
const ReportService = require('../../services/ReportService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class ReportController extends BaseController {
  /**
   * Create report
   */
  static create = asyncHandler(async (req, res) => {
    const report = await ReportService.create(req.body, req.user.id);
    return BaseController.success(res, report, 'Report submitted successfully', 201);
  });

  /**
   * Get user's reports
   */
  static getMyReports = asyncHandler(async (req, res) => {
    const { status, page = 1, limit = 20 } = req.query;
    const result = await ReportService.getUserReports(req.user.id, {
      status,
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Reports retrieved successfully');
  });
}

module.exports = ReportController;

