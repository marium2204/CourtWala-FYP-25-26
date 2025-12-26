const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');

class ReportService {
  /**
   * Create report
   */
  static async create(data, reporterId) {
  const {
    reportedUserId,
    reportedCourtId,
    reportedBookingId,
    type,
    message,
  } = data;

  if (!reportedUserId && !reportedCourtId && !reportedBookingId) {
    throw new AppError(
      'One of reportedUserId, reportedCourtId, or reportedBookingId is required',
      400
    );
  }

  if (reportedUserId === reporterId) {
    throw new AppError('Cannot report yourself', 400);
  }

  if (reportedBookingId) {
    const booking = await prisma.booking.findUnique({
      where: { id: reportedBookingId },
    });
    if (!booking) throw new AppError('Booking not found', 404);
  }

  return prisma.report.create({
    data: {
      reporterId,
      reportedUserId,
      reportedCourtId,
      reportedBookingId,
      type,
      message,
      status: 'PENDING',
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

