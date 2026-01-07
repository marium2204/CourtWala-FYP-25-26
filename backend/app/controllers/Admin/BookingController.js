const BaseController = require('../BaseController');
const BookingService = require('../../services/BookingService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class AdminBookingController {
  /**
   * Get ALL bookings (Admin)
   */
  static getAll = asyncHandler(async (req, res) => {
    const {
      status,
      date,
      courtId,
      page = 1,
      limit = 20,
    } = req.query;

    const result = await BookingService.getAll({
      status,
      date,
      courtId,
      page: parseInt(page),
      limit: parseInt(limit),
    });

    return BaseController.success(
      res,
      result,
      'Bookings retrieved successfully'
    );
  });
}

module.exports = AdminBookingController;
