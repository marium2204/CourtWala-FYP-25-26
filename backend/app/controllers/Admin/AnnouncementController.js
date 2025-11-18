const BaseController = require('../BaseController');
const AdminService = require('../../services/AdminService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class AdminAnnouncementController extends BaseController {
  /**
   * Create announcement
   */
  static create = asyncHandler(async (req, res) => {
    const announcement = await AdminService.createAnnouncement(req.body, req.user.id);
    return BaseController.success(res, announcement, 'Announcement created successfully', 201);
  });

  /**
   * Get all announcements
   */
  static getAll = asyncHandler(async (req, res) => {
    const { isActive, page = 1, limit = 20 } = req.query;
    const result = await AdminService.getAnnouncements({
      isActive: isActive === 'true',
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Announcements retrieved successfully');
  });
}

module.exports = AdminAnnouncementController;

