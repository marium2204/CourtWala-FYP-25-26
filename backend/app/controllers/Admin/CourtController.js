const BaseController = require('../BaseController');
const CourtService = require('../../services/CourtService');
const NotificationService = require('../../services/NotificationService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class AdminCourtController extends BaseController {
  static getAll = asyncHandler(async (req, res) => {
    const { status, sport, page = 1, limit = 20 } = req.query;

    const result = await CourtService.getAllAdmin({
      status,
      sport,
      page: parseInt(page),
      limit: parseInt(limit),
    });

    return BaseController.success(res, result, 'Courts retrieved successfully');
  });

  static getById = asyncHandler(async (req, res) => {
    const court = await CourtService.getAdminCourtById(req.params.id);
    return BaseController.success(res, court, 'Court retrieved successfully');
  });

  /**
   * Update court status + notify owner
   */
  static updateStatus = asyncHandler(async (req, res) => {
    console.log('🔥 AdminCourtController.updateStatus HIT');

    const court = await CourtService.updateCourtStatus(
      req.params.id,
      req.body.status
    );

    // =========================
    // NOTIFICATION BY FINAL STATUS
    // =========================
    const statusNotificationMap = {
      ACTIVE: {
        type: 'COURT_APPROVED',
        title: 'Court Approved',
        message: 'Your court has been approved and is now live.',
      },
      INACTIVE: {
        type: 'COURT_INACTIVATED',
        title: 'Court Inactivated',
        message:
          'Your court has been temporarily inactivated and cannot accept bookings.',
      },
      REJECTED: {
        type: 'COURT_REJECTED',
        title: 'Court Rejected',
        message: 'Your court submission was rejected by admin.',
      },
    };

    const notif = statusNotificationMap[court.status];

    if (notif) {
      await NotificationService.create({
        receiverId: court.ownerId,
        senderId: req.user.id,
        type: notif.type,
        title: notif.title,
        message: notif.message,
        data: { courtId: court.id },
      });
    }

    return BaseController.success(
      res,
      court,
      'Court status updated successfully'
    );
  });
}

module.exports = AdminCourtController;
