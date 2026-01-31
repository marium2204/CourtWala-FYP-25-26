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
  /* =========================
   USERS (ADMIN – FULL DATA)
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
      include: {
        _count: {
          select: {
            courts: true,          // OWNER
            bookings: true,        // PLAYER (bookings made)
            courtReviews: true,         // PLAYER reviews
          },
        },
        courts: {
          select: {
            _count: {
              select: {
                bookings: true,    // OWNER (bookings received)
              },
            },
          },
        },
      },
    }),
    prisma.user.count({ where }),
  ]);

  const normalizedUsers = users.map((u) => {
  const bookingsReceived =
    u.courts?.reduce(
      (sum, c) => sum + (c._count?.bookings || 0),
      0
    ) || 0;

  return {
    id: u.id,

    // ✅ Flutter expects these
    firstName: u.firstName,
    lastName: u.lastName,
    email: u.email,
    role: u.role,              // KEEP original enum
    status: u.status,
    createdAt: u.createdAt,    // 🔑 IMPORTANT

    stats: {
      courtsOwned: u.role === 'COURT_OWNER' ? u._count.courts : 0,
      bookingsMade: u.role === 'PLAYER' ? u._count.bookings : 0,
      bookingsReceived:
        u.role === 'COURT_OWNER' ? bookingsReceived : 0,
    },
  };
});

  return {
    users: normalizedUsers,
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    },
  };
}

/* =========================
   UPDATE USER STATUS
========================= */
static async updateUserStatus(userId, status) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) {
    throw new AppError('User not found', 404);
  }

  // 🔒 Safety rule: admin accounts cannot be blocked/suspended
  if (user.role === 'ADMIN' && status !== 'ACTIVE') {
    throw new AppError(
      'Admin accounts cannot be suspended or blocked',
      403
    );
  }

  const updatedUser = await prisma.user.update({
    where: { id: userId },
    data: { status },
  });

  // 🔔 Optional: notify user
  if (status !== 'ACTIVE') {
    await NotificationService.create({
      receiverId: userId,
      senderId: null,
      type: 'ADMIN_ANNOUNCEMENT',
      title: 'Account Status Updated',
      message: `Your account status has been changed to ${status}.`,
      data: { status },
    });
  }

  return updatedUser;
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


/* =========================
   COURT OWNER APPROVAL
========================= */
static async approveCourtOwner(ownerId, adminId) {
  const owner = await prisma.user.findUnique({
    where: { id: ownerId },
  });

  if (!owner || owner.role !== 'COURT_OWNER') {
    throw new AppError('Court owner not found', 404);
  }

  const updatedOwner = await prisma.user.update({
    where: { id: ownerId },
    data: {
      status: 'ACTIVE',
    },
  });

  // 🔔 Notify owner
  await NotificationService.create({
    receiverId: ownerId,
    senderId: adminId,
    type: 'OWNER_APPROVED',
    title: 'Court Owner Approved',
    message: 'Your court owner account has been approved by admin.',
  });

  return updatedOwner;
}

/* =========================
   COURT OWNER REJECTION
========================= */
static async rejectCourtOwner(ownerId, adminId, reason = 'Rejected by admin') {
  const owner = await prisma.user.findUnique({
    where: { id: ownerId },
  });

  if (!owner || owner.role !== 'COURT_OWNER') {
    throw new AppError('Court owner not found', 404);
  }

  const updatedOwner = await prisma.user.update({
    where: { id: ownerId },
    data: {
      status: 'BLOCKED',
    },
  });

  // 🔔 Notify owner
  await NotificationService.create({
    receiverId: ownerId,
    senderId: adminId,
    type: 'OWNER_REJECTED',
    title: 'Court Owner Rejected',
    message: reason,
  });

  return updatedOwner;
}
}

module.exports = AdminService;
