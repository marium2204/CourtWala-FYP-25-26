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
      page: Number(page),
      limit: Number(limit),
    });

    return BaseController.success(
      res,
      result,
      'Bookings retrieved successfully'
    );
  });

  /**
   * ✅ GET booking by ID (Admin)
   * THIS WAS MISSING — THIS IS THE CRASH FIX
   */
  static getById = asyncHandler(async (req, res) => {
    const booking = await BookingService.getById(req.params.id);

    return BaseController.success(
      res,
      booking,
      'Booking retrieved successfully'
    );
  });
}

module.exports = AdminBookingController;
