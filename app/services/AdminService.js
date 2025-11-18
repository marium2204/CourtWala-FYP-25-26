const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const NotificationService = require('./NotificationService');

class AdminService {
  /**
   * Get dashboard statistics
   */
  static async getDashboardStats() {
    const [
      totalPlayers,
      totalOwners,
      totalCourts,
      totalBookings,
      pendingOwners,
      pendingCourts,
    ] = await Promise.all([
      prisma.user.count({ where: { role: 'PLAYER' } }),
      prisma.user.count({ where: { role: 'COURT_OWNER' } }),
      prisma.court.count(),
      prisma.booking.count(),
      prisma.user.count({
        where: { role: 'COURT_OWNER', status: 'PENDING_APPROVAL' },
      }),
      prisma.court.count({ where: { status: 'PENDING_APPROVAL' } }),
    ]);

    return {
      totalPlayers,
      totalOwners,
      totalCourts,
      totalBookings,
      pendingOwners,
      pendingCourts,
    };
  }

  /**
   * Get all users with filters
   */
  static async getUsers(filters = {}) {
    const { role, status, search, limit = 20, page = 1 } = filters;
    const skip = (page - 1) * limit;

    const where = {
      ...(role && { role }),
      ...(status && { status }),
      ...(search && {
        OR: [
          { email: { contains: search, mode: 'insensitive' } },
          { firstName: { contains: search, mode: 'insensitive' } },
          { lastName: { contains: search, mode: 'insensitive' } },
          { username: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          email: true,
          username: true,
          firstName: true,
          lastName: true,
          role: true,
          status: true,
          createdAt: true,
        },
      }),
      prisma.user.count({ where }),
    ]);

    return {
      users,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Update user status
   */
  static async updateUserStatus(userId, status) {
    if (!['ACTIVE', 'BLOCKED', 'SUSPENDED'].includes(status)) {
      throw new AppError('Invalid status', 400);
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: { status },
    });

    // Notify user if blocked or suspended
    if (status === 'BLOCKED' || status === 'SUSPENDED') {
      await NotificationService.create({
        receiverId: userId,
        type: 'ADMIN_ANNOUNCEMENT',
        title: 'Account Status Update',
        message: `Your account has been ${status.toLowerCase()}`,
      });
    }

    return updatedUser;
  }

  /**
   * Approve court owner
   */
  static async approveCourtOwner(ownerId) {
    const owner = await prisma.user.findUnique({
      where: { id: ownerId },
    });

    if (!owner || owner.role !== 'COURT_OWNER') {
      throw new AppError('Invalid court owner', 404);
    }

    const updatedOwner = await prisma.user.update({
      where: { id: ownerId },
      data: { status: 'ACTIVE' },
    });

    await NotificationService.create({
      receiverId: ownerId,
      type: 'OWNER_APPROVED',
      title: 'Account Approved',
      message: 'Your court owner account has been approved',
    });

    return updatedOwner;
  }

  /**
   * Reject court owner
   */
  static async rejectCourtOwner(ownerId) {
    const owner = await prisma.user.findUnique({
      where: { id: ownerId },
    });

    if (!owner || owner.role !== 'COURT_OWNER') {
      throw new AppError('Invalid court owner', 404);
    }

    const updatedOwner = await prisma.user.update({
      where: { id: ownerId },
      data: { status: 'REJECTED' },
    });

    await NotificationService.create({
      receiverId: ownerId,
      type: 'OWNER_REJECTED',
      title: 'Account Rejected',
      message: 'Your court owner account has been rejected',
    });

    return updatedOwner;
  }

  /**
   * Get all reports
   */
  static async getReports(filters = {}) {
    const { status, type, limit = 20, page = 1 } = filters;
    const skip = (page - 1) * limit;

    const where = {
      ...(status && { status }),
      ...(type && { type }),
    };

    const [reports, total] = await Promise.all([
      prisma.report.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          reporter: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
          reportedUser: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
        },
      }),
      prisma.report.count({ where }),
    ]);

    return {
      reports,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Resolve report
   */
  static async resolveReport(reportId, adminId) {
    const report = await prisma.report.findUnique({
      where: { id: reportId },
    });

    if (!report) {
      throw new AppError('Report not found', 404);
    }

    const updatedReport = await prisma.report.update({
      where: { id: reportId },
      data: {
        status: 'RESOLVED',
        resolvedBy: adminId,
        resolvedAt: new Date(),
      },
    });

    await NotificationService.create({
      receiverId: report.reporterId,
      type: 'REPORT_RESOLVED',
      title: 'Report Resolved',
      message: 'Your report has been resolved',
      data: { reportId },
    });

    return updatedReport;
  }

  /**
   * Create announcement
   */
  static async createAnnouncement(data, adminId) {
    const { title, message, targetAudience, scheduledAt } = data;

    const announcement = await prisma.announcement.create({
      data: {
        title,
        message,
        targetAudience,
        scheduledAt: scheduledAt ? new Date(scheduledAt) : null,
        createdBy: adminId,
        isActive: true,
      },
    });

    // Send notifications to target audience
    const where = {};
    if (targetAudience.includes('PLAYER') && targetAudience.includes('COURT_OWNER')) {
      // All users
    } else if (targetAudience.includes('PLAYER')) {
      where.role = 'PLAYER';
    } else if (targetAudience.includes('COURT_OWNER')) {
      where.role = 'COURT_OWNER';
    }

    const users = await prisma.user.findMany({
      where: {
        ...where,
        status: 'ACTIVE',
      },
      select: { id: true },
    });

    // Create notifications for all users
    const notifications = users.map((user) => ({
      receiverId: user.id,
      senderId: adminId,
      type: 'ADMIN_ANNOUNCEMENT',
      title,
      message,
      data: { announcementId: announcement.id },
    }));

    // Batch create notifications
    for (const notification of notifications) {
      await NotificationService.create(notification);
    }

    return announcement;
  }

  /**
   * Get all announcements
   */
  static async getAnnouncements(filters = {}) {
    const { isActive, limit = 20, page = 1 } = filters;
    const skip = (page - 1) * limit;

    const where = {
      ...(isActive !== undefined && { isActive }),
    };

    const [announcements, total] = await Promise.all([
      prisma.announcement.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.announcement.count({ where }),
    ]);

    return {
      announcements,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}

module.exports = AdminService;

