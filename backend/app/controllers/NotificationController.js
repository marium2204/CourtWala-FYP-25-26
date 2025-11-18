const BaseController = require('./BaseController');
const NotificationService = require('../services/NotificationService');
const { asyncHandler } = require('../utils/ErrorHandler');

class NotificationController extends BaseController {
  /**
   * Get user notifications
   */
  static getAll = asyncHandler(async (req, res) => {
    const { isRead, type, page = 1, limit = 50 } = req.query;
    const result = await NotificationService.getUserNotifications(req.user.id, {
      isRead: isRead === 'true' ? true : isRead === 'false' ? false : undefined,
      type,
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Notifications retrieved successfully');
  });

  /**
   * Mark notification as read
   */
  static markAsRead = asyncHandler(async (req, res) => {
    await NotificationService.markAsRead(req.params.id, req.user.id);
    return BaseController.success(res, null, 'Notification marked as read');
  });

  /**
   * Mark all notifications as read
   */
  static markAllAsRead = asyncHandler(async (req, res) => {
    await NotificationService.markAllAsRead(req.user.id);
    return BaseController.success(res, null, 'All notifications marked as read');
  });

  /**
   * Get unread count
   */
  static getUnreadCount = asyncHandler(async (req, res) => {
    const count = await NotificationService.getUnreadCount(req.user.id);
    return BaseController.success(res, { count }, 'Unread count retrieved successfully');
  });
}

module.exports = NotificationController;

