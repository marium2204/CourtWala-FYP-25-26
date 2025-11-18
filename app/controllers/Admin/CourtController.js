const BaseController = require('../BaseController');
const CourtService = require('../../services/CourtService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class AdminCourtController extends BaseController {
  /**
   * Get all courts
   */
  static getAll = asyncHandler(async (req, res) => {
    const { status, sport, page = 1, limit = 20 } = req.query;
    const result = await CourtService.getAll({
      status,
      sport,
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Courts retrieved successfully');
  });

  /**
   * Update court status (approve/reject)
   */
  static updateStatus = asyncHandler(async (req, res) => {
    const { status } = req.body;
    const court = await CourtService.updateCourtStatus(req.params.id, status);
    return BaseController.success(res, court, 'Court status updated successfully');
  });
}

module.exports = AdminCourtController;

