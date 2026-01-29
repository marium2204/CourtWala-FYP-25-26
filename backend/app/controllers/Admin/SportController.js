const prisma = require('../../../config/database');
const BaseController = require('../BaseController');
const { asyncHandler } = require('../../utils/ErrorHandler');

class SportController {
  static getActiveSports = asyncHandler(async (req, res) => {
    const sports = await prisma.sport.findMany({
      where: { isActive: true },
      orderBy: { name: 'asc' },
      select: {
        id: true,
        name: true,
      },
    });

    return BaseController.success(
      res,
      sports,
      'Sports retrieved successfully'
    );
  });
}

module.exports = SportController;
