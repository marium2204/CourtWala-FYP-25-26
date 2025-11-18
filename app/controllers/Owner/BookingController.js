const BaseController = require('../BaseController');
const BookingService = require('../../services/BookingService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class OwnerBookingController extends BaseController {
  /**
   * Get owner's bookings
   */
  static getMyBookings = asyncHandler(async (req, res) => {
    const { status, date, courtId, page = 1, limit = 20 } = req.query;
    const result = await BookingService.getOwnerBookings(req.user.id, {
      status,
      date,
      courtId,
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
    if (booking.court.ownerId !== req.user.id && req.user.role !== 'ADMIN') {
      return BaseController.forbidden(res, 'You do not have permission to view this booking');
    }
    return BaseController.success(res, booking, 'Booking retrieved successfully');
  });

  /**
   * Approve booking
   */
  static approve = asyncHandler(async (req, res) => {
    const booking = await BookingService.approve(req.params.id, req.user.id);
    return BaseController.success(res, booking, 'Booking approved successfully');
  });

  /**
   * Reject booking
   */
  static reject = asyncHandler(async (req, res) => {
    const booking = await BookingService.reject(req.params.id, req.user.id);
    return BaseController.success(res, booking, 'Booking rejected successfully');
  });

  /**
   * Cancel booking
   */
  static cancel = asyncHandler(async (req, res) => {
    const booking = await BookingService.cancel(req.params.id, req.user.id, req.user.role);
    return BaseController.success(res, booking, 'Booking cancelled successfully');
  });

  /**
   * Get booking statistics
   */
  static getStats = asyncHandler(async (req, res) => {
    const stats = await BookingService.getOwnerBookingStats(req.user.id);
    return BaseController.success(res, stats, 'Statistics retrieved successfully');
  });
}

module.exports = OwnerBookingController;

