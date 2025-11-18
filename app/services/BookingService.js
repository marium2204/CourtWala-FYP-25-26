const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const NotificationService = require('./NotificationService');
const moment = require('moment');

class BookingService {
  /**
   * Create booking request
   */
  static async create(data, playerId) {
    const { courtId, date, startTime, endTime, needsOpponent = false } = data;

    // Check if court exists and is active
    const court = await prisma.court.findUnique({
      where: { id: courtId },
      include: { owner: true },
    });

    if (!court) {
      throw new AppError('Court not found', 404);
    }

    if (court.status !== 'ACTIVE') {
      throw new AppError('Court is not available for booking', 400);
    }

    // Check for conflicting bookings
    const bookingDate = moment(date).format('YYYY-MM-DD');
    const conflictingBooking = await prisma.booking.findFirst({
      where: {
        courtId,
        date: new Date(bookingDate),
        status: {
          in: ['PENDING', 'CONFIRMED'],
        },
        OR: [
          {
            AND: [
              { startTime: { lte: startTime } },
              { endTime: { gt: startTime } },
            ],
          },
          {
            AND: [
              { startTime: { lt: endTime } },
              { endTime: { gte: endTime } },
            ],
          },
          {
            AND: [
              { startTime: { gte: startTime } },
              { endTime: { lte: endTime } },
            ],
          },
        ],
      },
    });

    if (conflictingBooking) {
      throw new AppError('Time slot is already booked', 409);
    }

    // Create booking
    const booking = await prisma.booking.create({
      data: {
        courtId,
        playerId,
        date: new Date(bookingDate),
        startTime,
        endTime,
        needsOpponent,
        status: 'PENDING',
      },
      include: {
        court: {
          include: {
            owner: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                email: true,
              },
            },
          },
        },
        player: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    });

    // Notify court owner
    await NotificationService.create({
      receiverId: court.ownerId,
      senderId: playerId,
      type: 'BOOKING_APPROVED',
      title: 'New Booking Request',
      message: `You have a new booking request for ${court.name}`,
      data: { bookingId: booking.id },
    });

    return booking;
  }

  /**
   * Get all bookings with filters
   */
  static async getAll(filters = {}) {
    const {
      playerId,
      ownerId,
      courtId,
      status,
      date,
      limit = 20,
      page = 1,
    } = filters;

    const skip = (page - 1) * limit;

    const where = {
      ...(playerId && { playerId }),
      ...(courtId && { courtId }),
      ...(status && { status }),
      ...(date && { date: new Date(date) }),
      ...(ownerId && {
        court: {
          ownerId,
        },
      }),
    };

    const [bookings, total] = await Promise.all([
      prisma.booking.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          court: {
            select: {
              id: true,
              name: true,
              location: true,
              sport: true,
            },
          },
          player: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
              profilePicture: true,
            },
          },
          opponent: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePicture: true,
            },
          },
        },
      }),
      prisma.booking.count({ where }),
    ]);

    return {
      bookings,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get booking by ID
   */
  static async getById(id) {
    const booking = await prisma.booking.findUnique({
      where: { id },
      include: {
        court: {
          include: {
            owner: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                email: true,
                phone: true,
              },
            },
          },
        },
        player: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            profilePicture: true,
          },
        },
        opponent: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePicture: true,
          },
        },
      },
    });

    if (!booking) {
      throw new AppError('Booking not found', 404);
    }

    return booking;
  }

  /**
   * Approve booking (Owner)
   */
  static async approve(id, ownerId) {
    const booking = await this.getById(id);

    if (booking.court.ownerId !== ownerId) {
      throw new AppError('You do not have permission to approve this booking', 403);
    }

    if (booking.status !== 'PENDING') {
      throw new AppError('Booking cannot be approved', 400);
    }

    const updatedBooking = await prisma.booking.update({
      where: { id },
      data: { status: 'CONFIRMED' },
      include: {
        player: true,
        court: true,
      },
    });

    // Notify player
    await NotificationService.create({
      receiverId: booking.playerId,
      senderId: ownerId,
      type: 'BOOKING_APPROVED',
      title: 'Booking Approved',
      message: `Your booking for ${booking.court.name} has been approved`,
      data: { bookingId: id },
    });

    return updatedBooking;
  }

  /**
   * Reject booking (Owner)
   */
  static async reject(id, ownerId) {
    const booking = await this.getById(id);

    if (booking.court.ownerId !== ownerId) {
      throw new AppError('You do not have permission to reject this booking', 403);
    }

    if (booking.status !== 'PENDING') {
      throw new AppError('Booking cannot be rejected', 400);
    }

    const updatedBooking = await prisma.booking.update({
      where: { id },
      data: { status: 'REJECTED' },
      include: {
        player: true,
        court: true,
      },
    });

    // Notify player
    await NotificationService.create({
      receiverId: booking.playerId,
      senderId: ownerId,
      type: 'BOOKING_REJECTED',
      title: 'Booking Rejected',
      message: `Your booking for ${booking.court.name} has been rejected`,
      data: { bookingId: id },
    });

    return updatedBooking;
  }

  /**
   * Cancel booking
   */
  static async cancel(id, userId, userRole) {
    const booking = await this.getById(id);

    // Check permissions
    const canCancel =
      booking.playerId === userId ||
      booking.court.ownerId === userId ||
      userRole === 'ADMIN';

    if (!canCancel) {
      throw new AppError('You do not have permission to cancel this booking', 403);
    }

    if (!['PENDING', 'CONFIRMED'].includes(booking.status)) {
      throw new AppError('Booking cannot be cancelled', 400);
    }

    const updatedBooking = await prisma.booking.update({
      where: { id },
      data: { status: 'CANCELLED' },
      include: {
        player: true,
        court: {
          include: {
            owner: true,
          },
        },
      },
    });

    // Notify both parties
    const notifyUserId = booking.playerId === userId ? booking.court.ownerId : booking.playerId;
    await NotificationService.create({
      receiverId: notifyUserId,
      senderId: userId,
      type: 'BOOKING_CANCELLED',
      title: 'Booking Cancelled',
      message: `Booking for ${booking.court.name} has been cancelled`,
      data: { bookingId: id },
    });

    return updatedBooking;
  }

  /**
   * Get player bookings
   */
  static async getPlayerBookings(playerId, filters = {}) {
    return this.getAll({ ...filters, playerId });
  }

  /**
   * Get owner bookings
   */
  static async getOwnerBookings(ownerId, filters = {}) {
    return this.getAll({ ...filters, ownerId });
  }

  /**
   * Get booking statistics for owner
   */
  static async getOwnerBookingStats(ownerId) {
    const courts = await prisma.court.findMany({
      where: { ownerId },
      select: { id: true },
    });

    const courtIds = courts.map((c) => c.id);

    const [total, pending, confirmed, cancelled, completed] = await Promise.all([
      prisma.booking.count({
        where: { courtId: { in: courtIds } },
      }),
      prisma.booking.count({
        where: { courtId: { in: courtIds }, status: 'PENDING' },
      }),
      prisma.booking.count({
        where: { courtId: { in: courtIds }, status: 'CONFIRMED' },
      }),
      prisma.booking.count({
        where: { courtId: { in: courtIds }, status: 'CANCELLED' },
      }),
      prisma.booking.count({
        where: { courtId: { in: courtIds }, status: 'COMPLETED' },
      }),
    ]);

    return {
      total,
      pending,
      confirmed,
      cancelled,
      completed,
    };
  }
}

module.exports = BookingService;

