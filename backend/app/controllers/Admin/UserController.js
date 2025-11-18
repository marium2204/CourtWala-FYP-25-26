const BaseController = require('../BaseController');
const AdminService = require('../../services/AdminService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class AdminUserController extends BaseController {
  /**
   * Get all users
   */
  static getAll = asyncHandler(async (req, res) => {
    const { role, status, search, page = 1, limit = 20 } = req.query;
    const result = await AdminService.getUsers({
      role,
      status,
      search,
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Users retrieved successfully');
  });

  /**
   * Update user status
   */
  static updateStatus = asyncHandler(async (req, res) => {
    const { status } = req.body;
    const user = await AdminService.updateUserStatus(req.params.id, status);
    return BaseController.success(res, user, 'User status updated successfully');
  });

  /**
   * Approve court owner
   */
  static approveOwner = asyncHandler(async (req, res) => {
    const owner = await AdminService.approveCourtOwner(req.params.id);
    return BaseController.success(res, owner, 'Court owner approved successfully');
  });

  /**
   * Reject court owner
   */
  static rejectOwner = asyncHandler(async (req, res) => {
    const owner = await AdminService.rejectCourtOwner(req.params.id);
    return BaseController.success(res, owner, 'Court owner rejected successfully');
  });
}

module.exports = AdminUserController;

