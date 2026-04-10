const BaseController = require('../BaseController');
const BankDetailService = require('../../services/BankDetailService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class BankDetailController extends BaseController {
  
  static create = asyncHandler(async (req, res) => {
    const detail = await BankDetailService.create(req.user.id, req.body);
    return BaseController.success(res, detail, 'Bank detail added successfully', 201);
  });

  static getMyBankDetails = asyncHandler(async (req, res) => {
    const details = await BankDetailService.getByOwner(req.user.id);
    return BaseController.success(res, details, 'Bank details retrieved successfully');
  });

  static getActiveByCourt = asyncHandler(async (req, res) => {
    const bankDetails = await BankDetailService.getActiveByCourt(req.params.courtId);
    return BaseController.success(res, { bankDetails }, 'Active bank details retrieved');
  });

  static update = asyncHandler(async (req, res) => {
    const detail = await BankDetailService.update(req.params.id, req.user.id, req.body);
    return BaseController.success(res, detail, 'Bank detail updated successfully');
  });

  static delete = asyncHandler(async (req, res) => {
    await BankDetailService.delete(req.params.id, req.user.id);
    return BaseController.success(res, null, 'Bank detail deleted successfully');
  });
}

module.exports = BankDetailController;
