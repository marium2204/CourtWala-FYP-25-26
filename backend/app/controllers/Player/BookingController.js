const BaseController = require('../BaseController');
const BookingService = require('../../services/BookingService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class BookingController extends BaseController {
  /**
   * Create booking request
   */
  static create = asyncHandler(async (req, res) => {
    const booking = await BookingService.create(req.body, req.user.id);
    return BaseController.success(res, booking, 'Booking request created successfully', 201);
  });

  /**
   * Get player's bookings
   */
  static getMyBookings = asyncHandler(async (req, res) => {
    const { status, date, page = 1, limit = 20 } = req.query;
    const result = await BookingService.getPlayerBookings(req.user.id, {
      status,
      date,
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Bookings retrieved successfully');
  });

  /**
   * Get booking by ID
   */
  static getById = asyncHandler(async (req, res) => {
    const booking = await BookingService.getById(req.params.id);
    // Check if user owns this booking
    if (booking.playerId !== req.user.id && req.user.role !== 'ADMIN') {
      return BaseController.forbidden(res, 'You do not have permission to view this booking');
    }
    return BaseController.success(res, booking, 'Booking retrieved successfully');
  });

  /**
   * Cancel booking
   */
  static cancel = asyncHandler(async (req, res) => {
    const booking = await BookingService.cancel(req.params.id, req.user.id, req.user.role);
    return BaseController.success(res, booking, 'Booking cancelled successfully');
  });
}

module.exports = BookingController;

