const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const NotificationService = require('./NotificationService');

class AdminService {
  /* =========================
     DASHBOARD
  ========================= */
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

  /* =========================
     USERS
  ========================= */
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

  /* =========================
     ANNOUNCEMENTS (FIXED)
  ========================= */
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

    // Notify users
    const where = {};
    if (
      !(
        targetAudience.includes('PLAYER') &&
        targetAudience.includes('COURT_OWNER')
      )
    ) {
      if (targetAudience.includes('PLAYER')) where.role = 'PLAYER';
      if (targetAudience.includes('COURT_OWNER')) where.role = 'COURT_OWNER';
    }

    const users = await prisma.user.findMany({
      where: { ...where, status: 'ACTIVE' },
      select: { id: true },
    });

    for (const user of users) {
      await NotificationService.create({
        receiverId: user.id,
        senderId: adminId,
        type: 'ADMIN_ANNOUNCEMENT',
        title,
        message,
        data: { announcementId: announcement.id },
      });
    }

    return announcement;
  }

  static async getAnnouncements(filters = {}) {
  const { limit = 20, page = 1 } = filters;
  const skip = (page - 1) * limit;

  const [announcements, total] = await Promise.all([
    prisma.announcement.findMany({
      skip,
      take: limit,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.announcement.count(),
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


  /* =========================
     REPORTS
  ========================= */
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
            select: { id: true, firstName: true, lastName: true, email: true },
          },
          reportedUser: {
            select: { id: true, firstName: true, lastName: true, email: true },
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


  static async resolveReport(reportId, adminId) {
    const report = await prisma.report.findUnique({
      where: { id: reportId },
    });

    if (!report) {
      throw new AppError('Report not found', 404);
    }

    if (report.status !== 'PENDING') {
      throw new AppError('Report already resolved', 400);
    }

    // Update report status
    const updatedReport = await prisma.report.update({
      where: { id: reportId },
      data: {
        status: 'RESOLVED',
        resolvedBy: adminId,
        resolvedAt: new Date(),
      },
    });

    // 🔔 Optional: notify reporter
    await NotificationService.create({
      receiverId: report.reporterId,
      senderId: adminId,
      type: 'REPORT_RESOLVED',
      title: 'Report Resolved',
      message: 'Your report has been reviewed and resolved by admin.',
      data: { reportId },
    });

    return updatedReport;
  }
}
module.exports = AdminService;
