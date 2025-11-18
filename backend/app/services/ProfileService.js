const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const AuthService = require('./AuthService');

class ProfileService {
  /**
   * Get user profile
   */
  static async getProfile(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        username: true,
        firstName: true,
        lastName: true,
        phone: true,
        profilePicture: true,
        role: true,
        status: true,
        skillLevel: true,
        preferredSports: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    return user;
  }

  /**
   * Update profile
   */
  static async updateProfile(userId, data) {
    const {
      firstName,
      lastName,
      phone,
      skillLevel,
      preferredSports,
      profilePicture,
    } = data;

    const updateData = {};
    if (firstName) updateData.firstName = firstName;
    if (lastName) updateData.lastName = lastName;
    if (phone !== undefined) updateData.phone = phone;
    if (skillLevel !== undefined) updateData.skillLevel = skillLevel;
    if (preferredSports) updateData.preferredSports = preferredSports;
    if (profilePicture) updateData.profilePicture = profilePicture;

    return prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        email: true,
        username: true,
        firstName: true,
        lastName: true,
        phone: true,
        profilePicture: true,
        role: true,
        status: true,
        skillLevel: true,
        preferredSports: true,
      },
    });
  }

  /**
   * Change password
   */
  static async changePassword(userId, currentPassword, newPassword) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    const isPasswordValid = await AuthService.comparePassword(
      currentPassword,
      user.password
    );

    if (!isPasswordValid) {
      throw new AppError('Current password is incorrect', 400);
    }

    const hashedPassword = await AuthService.hashPassword(newPassword);

    await prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });

    return { message: 'Password changed successfully' };
  }
}

module.exports = ProfileService;

