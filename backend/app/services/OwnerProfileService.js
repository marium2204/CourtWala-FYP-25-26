const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');

class OwnerProfileService {
  static async getProfile(ownerId) {
    return prisma.user.findUnique({
      where: { id: ownerId },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        email: true,
        phone: true,
        status: true,
        createdAt: true,
        courts: {
          select: {
            id: true,
            name: true,
            status: true,
          },
        },
      },
    });
  }

  /**
   * Update owner profile
   */
  static async updateProfile(ownerId, data) {
    const { firstName, lastName, phone } = data;

    return prisma.user.update({
      where: { id: ownerId },
      data: {
        firstName,
        lastName,
        phone,
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        email: true,
        phone: true,
        profilePicture: true,
      },
    });
  }
}

module.exports = OwnerProfileService;
