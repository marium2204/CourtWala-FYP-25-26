const BaseController = require('../BaseController');
const TournamentService = require('../../services/TournamentService');
const { asyncHandler } = require('../../utils/ErrorHandler');

class AdminTournamentController {
  static getAll = asyncHandler(async (req, res) => {
    const { sport, skillLevel, status, page = 1, limit = 20 } = req.query;

    const result = await TournamentService.getAll({
      sport,
      skillLevel,
      status,
      page: Number(page),
      limit: Number(limit),
    });

    return BaseController.success(
      res,
      result,
      'Tournaments retrieved successfully'
    );
  });
}

module.exports = AdminTournamentController;
