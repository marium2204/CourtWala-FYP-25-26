const BaseController = require('../BaseController');
const TournamentService = require('../../services/TournamentService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class TournamentController extends BaseController {
  /**
   * Get all tournaments
   */
  static getAll = asyncHandler(async (req, res) => {
    const { sport, skillLevel, status, page = 1, limit = 20 } = req.query;
    const result = await TournamentService.getAll({
      sport,
      skillLevel,
      status,
      page: parseInt(page),
      limit: parseInt(limit),
    });
    return BaseController.success(res, result, 'Tournaments retrieved successfully');
  });

  /**
   * Get tournament by ID
   */
  static getById = asyncHandler(async (req, res) => {
    const tournament = await TournamentService.getById(req.params.id);
    return BaseController.success(res, tournament, 'Tournament retrieved successfully');
  });

  /**
   * Join tournament
   */
  static join = asyncHandler(async (req, res) => {
    const tournament = await TournamentService.joinTournament(
      req.params.id,
      req.user.id
    );
    return BaseController.success(res, tournament, 'Successfully joined tournament');
  });

  /**
   * Leave tournament
   */
  static leave = asyncHandler(async (req, res) => {
    await TournamentService.leaveTournament(req.params.id, req.user.id);
    return BaseController.success(res, null, 'Successfully left tournament');
  });
}

module.exports = TournamentController;

