const BaseController = require('../BaseController');
const CourtService = require('../../services/CourtService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class OwnerCourtController extends BaseController {
  /**
   * Get owner's courts
   */
  static getMyCourts = asyncHandler(async (req, res) => {
    const { status, page = 1, limit = 20 } = req.query;
    const result = await CourtService.getOwnerCourts(req.user.id, {
      status,
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Courts retrieved successfully');
  });

  /**
   * Create court
   */
  static create = asyncHandler(async (req, res) => {
    const court = await CourtService.create(req.body, req.user.id);
    return BaseController.success(res, court, 'Court created successfully', 201);
  });

  /**
   * Update court
   */
  static update = asyncHandler(async (req, res) => {
    const court = await CourtService.update(req.params.id, req.body, req.user.id);
    return BaseController.success(res, court, 'Court updated successfully');
  });

  /**
   * Delete court
   */
  static delete = asyncHandler(async (req, res) => {
    await CourtService.delete(req.params.id, req.user.id);
    return BaseController.success(res, null, 'Court deleted successfully');
  });

  /**
   * Get court by ID
   */
  static getById = asyncHandler(async (req, res) => {
    const court = await CourtService.getById(req.params.id);
    if (court.ownerId !== req.user.id && req.user.role !== 'ADMIN') {
      return BaseController.forbidden(res, 'You do not have permission to view this court');
    }
    return BaseController.success(res, court, 'Court retrieved successfully');
  });
}

module.exports = OwnerCourtController;

