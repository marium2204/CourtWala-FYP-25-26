const BaseController = require('../BaseController');
const MatchmakingService = require('../../services/MatchmakingService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class MatchmakingController extends BaseController {
  /**
   * Search players
   */
  static searchPlayers = asyncHandler(async (req, res) => {
    const { name, sport, skillLevel, page = 1, limit = 20 } = req.query;
    const result = await MatchmakingService.searchPlayers({
      name,
      sport,
      skillLevel,
      excludeUserId: req.user.id,
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Players retrieved successfully');
  });

  /**
   * Send match request
   */
  static sendMatchRequest = asyncHandler(async (req, res) => {
    const matchRequest = await MatchmakingService.sendMatchRequest(
      req.body,
      req.user.id
    );
    return BaseController.success(res, matchRequest, 'Match request sent successfully', 201);
  });

  /**
   * Get match requests
   */
  static getMatchRequests = asyncHandler(async (req, res) => {
    const { type = 'received' } = req.query;
    const requests = await MatchmakingService.getMatchRequests(req.user.id, type);
    return BaseController.success(res, requests, 'Match requests retrieved successfully');
  });

  /**
   * Accept match request
   */
  static acceptMatchRequest = asyncHandler(async (req, res) => {
    const request = await MatchmakingService.acceptMatchRequest(
      req.params.id,
      req.user.id
    );
    return BaseController.success(res, request, 'Match request accepted successfully');
  });

  /**
   * Reject match request
   */
  static rejectMatchRequest = asyncHandler(async (req, res) => {
    const request = await MatchmakingService.rejectMatchRequest(
      req.params.id,
      req.user.id
    );
    return BaseController.success(res, request, 'Match request rejected successfully');
  });
}

module.exports = MatchmakingController;

