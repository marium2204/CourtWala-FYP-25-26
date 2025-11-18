const prisma = require('../../config/database');

class OwnerDashboardService {
  /**
   * Get owner dashboard statistics
   */
  static async getDashboardStats(ownerId) {
    const [totalCourts, totalBookings, pendingBookings, confirmedBookings, cancelledBookings] =
      await Promise.all([
        prisma.court.count({ where: { ownerId } }),
        prisma.booking.count({
          where: {
            court: { ownerId },
          },
        }),
        prisma.booking.count({
          where: {
            court: { ownerId },
            status: 'PENDING',
          },
        }),
        prisma.booking.count({
          where: {
            court: { ownerId },
            status: 'CONFIRMED',
          },
        }),
        prisma.booking.count({
          where: {
            court: { ownerId },
            status: 'CANCELLED',
          },
        }),
      ]);

    // Get recent bookings
    const recentBookings = await prisma.booking.findMany({
      where: {
        court: { ownerId },
      },
      take: 10,
      orderBy: { createdAt: 'desc' },
      include: {
        court: {
          select: {
            id: true,
            name: true,
          },
        },
        player: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePicture: true,
          },
        },
      },
    });

    // Get weekly booking trends (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const weeklyBookings = await prisma.booking.groupBy({
      by: ['date'],
      where: {
        court: { ownerId },
        createdAt: {
          gte: sevenDaysAgo,
        },
      },
      _count: {
        id: true,
      },
    });

    return {
      totalCourts,
      totalBookings,
      pendingBookings,
      confirmedBookings,
      cancelledBookings,
      recentBookings,
      weeklyTrends: weeklyBookings,
    };
  }
}

module.exports = OwnerDashboardService;

