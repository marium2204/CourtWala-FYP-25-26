const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const AuthService = require('./AuthService');

class ProfileService {
  // =========================
  // GET PROFILE
  // =========================
  static async getProfile(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        playerSports: {
          include: {
            sport: {
              select: { name: true },
            },
          },
        },
      },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    const sports = user.playerSports.map((ps) => ({
      sport: ps.sport.name,
      skillLevel: ps.skillLevel,
    }));

    return {
      id: user.id,
      email: user.email,
      username: user.username,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      profilePicture: user.profilePicture,
      role: user.role,
      status: user.status,
      sports,
      profileComplete: sports.length > 0,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }

  // =========================
  // UPDATE BASIC PROFILE
  // =========================
  static async updateProfile(userId, data) {
    const { firstName, lastName, phone, profilePicture } = data;

    return prisma.user.update({
      where: { id: userId },
      data: {
        firstName,
        lastName,
        phone,
        profilePicture,
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        phone: true,
        profilePicture: true,
      },
    });
  }

  // =========================
  // UPDATE SPORTS & SKILLS
  // =========================
  static async updateSports(userId, sports) {
    if (!Array.isArray(sports)) {
      throw new AppError('Sports must be an array', 400);
    }

    // Clear existing sports
    await prisma.playerSport.deleteMany({
      where: { playerId: userId },
    });

    for (const item of sports) {
      const { sport, skillLevel } = item;

      if (!sport || !skillLevel) {
        throw new AppError('Sport and skillLevel are required', 400);
      }

      const sportRecord = await prisma.sport.findUnique({
        where: { name: sport },
      });

      if (!sportRecord) {
        throw new AppError(`Sport "${sport}" not found`, 400);
      }

      await prisma.playerSport.create({
        data: {
          playerId: userId,
          sportId: sportRecord.id,
          skillLevel,
        },
      });
    }

    return { message: 'Sports updated successfully' };
  }

  // =========================
  // CHANGE PASSWORD
  // =========================
  static async changePassword(userId, currentPassword, newPassword) {
    const user = await prisma.user.findUnique({ where: { id: userId } });

    if (!user) throw new AppError('User not found', 404);

    const isValid = await AuthService.comparePassword(
      currentPassword,
      user.password
    );

    if (!isValid) {
      throw new AppError('Current password is incorrect', 400);
    }

    const hashed = await AuthService.hashPassword(newPassword);

    await prisma.user.update({
      where: { id: userId },
      data: { password: hashed },
    });

    return { message: 'Password changed successfully' };
  }
}

module.exports = ProfileService;
