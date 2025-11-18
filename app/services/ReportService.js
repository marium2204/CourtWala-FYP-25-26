const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');

class ReportService {
  /**
   * Create report
   */
  static async create(data, reporterId) {
    const { reportedUserId, reportedCourtId, type, message } = data;

    if (!reportedUserId && !reportedCourtId) {
      throw new AppError('Either reportedUserId or reportedCourtId is required', 400);
    }

    if (reportedUserId === reporterId) {
      throw new AppError('Cannot report yourself', 400);
    }

    // Verify reported user exists if provided
    if (reportedUserId) {
      const reportedUser = await prisma.user.findUnique({
        where: { id: reportedUserId },
      });
      if (!reportedUser) {
        throw new AppError('Reported user not found', 404);
      }
    }

    // Verify reported court exists if provided
    if (reportedCourtId) {
      const reportedCourt = await prisma.court.findUnique({
        where: { id: reportedCourtId },
      });
      if (!reportedCourt) {
        throw new AppError('Reported court not found', 404);
      }
    }

    return prisma.report.create({
      data: {
        reporterId,
        reportedUserId,
        reportedCourtId,
        type,
        message,
        status: 'PENDING',
      },
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
    });
  }

  /**
   * Get user's reports
   */
  static async getUserReports(userId, filters = {}) {
    const { status, limit = 20, page = 1 } = filters;
    const skip = (page - 1) * limit;

    const where = {
      reporterId: userId,
      ...(status && { status }),
    };

    const [reports, total] = await Promise.all([
      prisma.report.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          reportedUser: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
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
}

module.exports = ReportService;

