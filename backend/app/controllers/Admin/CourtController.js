const BaseController = require('../BaseController');
const CourtService = require('../../services/CourtService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class AdminCourtController extends BaseController {
  /**
   * Get all courts (ADMIN)
   * Summary list + mapurl
   */
  static getAll = asyncHandler(async (req, res) => {
    const { status, sport, page = 1, limit = 20 } = req.query;

    const result = await CourtService.getAllAdmin({
      status,
      sport,
      page: parseInt(page),
      limit: parseInt(limit),
    });

    return BaseController.success(
      res,
      result,
      'Courts retrieved successfully'
    );
  });

  /**
   * Get court by ID (FULL DETAILS)
   */
  static getById = asyncHandler(async (req, res) => {
    const court = await CourtService.getAdminCourtById(req.params.id);
    return BaseController.success(res, court, 'Court retrieved successfully');
  });

  /**
   * Update court status (approve / reject)
   */
  static updateStatus = asyncHandler(async (req, res) => {
    const { status } = req.body;

    const court = await CourtService.updateCourtStatus(
      req.params.id,
      status
    );

    return BaseController.success(
      res,
      court,
      'Court status updated successfully'
    );
  });
}

module.exports = AdminCourtController;
