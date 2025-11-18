const BaseController = require('./BaseController');
const CourtService = require('../services/CourtService');
const { asyncHandler } = require('../utils/ErrorHandler');

class CourtController extends BaseController {
  /**
   * Get all courts (browsing)
   */
  static getAll = asyncHandler(async (req, res) => {
    const {
      sport,
      location,
      minPrice,
      maxPrice,
      search,
      page = 1,
      limit = 20,
    } = req.query;

    const result = await CourtService.getAll({
      sport,
      location,
      minPrice: minPrice ? parseFloat(minPrice) : undefined,
      maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
      search,
      status: 'ACTIVE',
      page: parseInt(page),
      limit: parseInt(limit),
    });

    return BaseController.success(res, result, 'Courts retrieved successfully');
  });

  /**
   * Get court by ID
   */
  static getById = asyncHandler(async (req, res) => {
    const court = await CourtService.getById(req.params.id);
    return BaseController.success(res, court, 'Court retrieved successfully');
  });
}

module.exports = CourtController;

