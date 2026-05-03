const BaseController = require('../BaseController');
const CourtService = require('../../services/CourtService');
const NotificationService = require('../../services/NotificationService');
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
    const data = { ...req.body };

    // Note: We expect images to be uploaded to Cloudinary on the frontend 
    // and URLs passed in req.body.images as an array.


    if (data.amenities && typeof data.amenities === 'string') {
      try {
        data.amenities = JSON.parse(data.amenities);
      } catch {
        data.amenities = data.amenities
          .split(',')
          .map(item => item.trim())
          .filter(Boolean);
      }
    }

    if (data.sports && typeof data.sports === 'string') {
      try {
        data.sports = JSON.parse(data.sports);
      } catch {
        data.sports = [];
      }
    }

    const court = await CourtService.create(data, req.user.id);

    // 🔔 Notify owner: court pending approval
    await NotificationService.create({
      receiverId: req.user.id,
      type: 'COURT_PENDING',
      title: 'Court Sent for Review',
      message: 'Your court has been submitted and is pending admin approval.',
      data: { courtId: court.id },
    });

    return BaseController.success(res, court, 'Court created successfully', 201);
  });

  /**
   * Update court
   */
  static update = asyncHandler(async (req, res) => {
    const data = { ...req.body };


    if (data.amenities && typeof data.amenities === 'string') {
      try {
        data.amenities = JSON.parse(data.amenities);
      } catch {
        data.amenities = data.amenities
          .split(',')
          .map(item => item.trim())
          .filter(Boolean);
      }
    }

    if (data.sports && typeof data.sports === 'string') {
      try {
        data.sports = JSON.parse(data.sports);
      } catch {
        data.sports = [];
      }
    }

    // Get current court BEFORE update
    const existingCourt = await CourtService.getById(req.params.id);

    const result = await CourtService.update(
      req.params.id,
      data,
      req.user.id
    );

    // 🔔 Notify ONLY if ACTIVE → PENDING_APPROVAL
    if (existingCourt.status === 'ACTIVE') {
      await NotificationService.create({
        receiverId: req.user.id,
        type: 'COURT_PENDING',
        title: 'Court Sent for Review',
        message:
          'Your court was updated and is now pending admin approval.',
        data: { courtId: req.params.id },
      });
    }

    return BaseController.success(res, result, 'Court updated successfully');
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
      return BaseController.forbidden(
        res,
        'You do not have permission to view this court'
      );
    }
    return BaseController.success(res, court, 'Court retrieved successfully');
  });
}

module.exports = OwnerCourtController;
