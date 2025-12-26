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

    const bookingDate = moment(date).format('YYYY-MM-DD');

    const conflictingBooking = await prisma.booking.findFirst({
      where: {
        courtId,
        date: new Date(bookingDate),
        status: { in: ['PENDING', 'CONFIRMED'] },
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
          select: {
            id: true,
            name: true,
            pricePerHour: true, // ✅ IMPORTANT
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

    await NotificationService.create({
      receiverId: court.ownerId,
      senderId: playerId,
      type: 'BOOKING_REQUEST',
      title: 'New Booking Request',
      message: `You have a new booking request for ${court.name}`,
      data: { bookingId: booking.id },
    });

    return booking;
  }

  /**
   * Get all bookings (used by player & owner)
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
        court: { ownerId },
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
              pricePerHour: true, // ✅ FIX THAT SOLVES "PKR null"
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
          select: {
            id: true,
            name: true,
            pricePerHour: true,
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

    if (booking.court.owner.id !== ownerId) {
      throw new AppError('You do not have permission to approve this booking', 403);
    }

    if (booking.status !== 'PENDING') {
      throw new AppError('Booking cannot be approved', 400);
    }

    const updatedBooking = await prisma.booking.update({
      where: { id },
      data: { status: 'CONFIRMED' },
      include: {
        court: true,
        player: true,
      },
    });

    await NotificationService.create({
      receiverId: booking.player.id,
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

    if (booking.court.owner.id !== ownerId) {
      throw new AppError('You do not have permission to reject this booking', 403);
    }

    if (booking.status !== 'PENDING') {
      throw new AppError('Booking cannot be rejected', 400);
    }

    return prisma.booking.update({
      where: { id },
      data: { status: 'REJECTED' },
    });
  }

  /**
   * Cancel booking
   */
  static async cancel(id, userId, userRole) {
    const booking = await this.getById(id);

    const canCancel =
      booking.player.id === userId ||
      booking.court.owner.id === userId ||
      userRole === 'ADMIN';

    if (!canCancel) {
      throw new AppError('You do not have permission to cancel this booking', 403);
    }

    if (!['PENDING', 'CONFIRMED'].includes(booking.status)) {
      throw new AppError('Booking cannot be cancelled', 400);
    }

    return prisma.booking.update({
      where: { id },
      data: { status: 'CANCELLED' },
    });
  }

  static async getPlayerBookings(playerId, filters = {}) {
    return this.getAll({ ...filters, playerId });
  }

  static async getOwnerBookings(ownerId, filters = {}) {
    return this.getAll({ ...filters, ownerId });
  }
}

module.exports = BookingService;
