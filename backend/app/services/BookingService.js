const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const NotificationService = require('./NotificationService');
const moment = require('moment');

class BookingService {
  /**
   * Create booking request
   */
  static async create(data, playerId) {
    const { courtId, sport, date, startTime, endTime, findOpponent = false, paymentScreenshot, advanceAmountPaid, totalPrice, playersPerSide, matchType } = data;

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
        status: { in: ['PENDING', 'PENDING_APPROVAL', 'CONFIRMED'] },
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
        sport,
        date: new Date(bookingDate),
        startTime,
        endTime,
        needsOpponent: findOpponent,
        paymentScreenshot,
        advanceAmountPaid: parseFloat(advanceAmountPaid),
        totalPrice: parseFloat(totalPrice),
        playersPerSide: playersPerSide ? parseInt(playersPerSide) : null,
        matchType: matchType || null,
        status: 'PENDING_APPROVAL',
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

    if (matchType === 'DOUBLES') {
      await prisma.bookingParticipant.create({
        data: {
          bookingId: booking.id,
          playerId,
          team: 'TEAM_A',
        },
      });
    }

    await NotificationService.create({
      receiverId: court.ownerId,
      senderId: playerId,
      type: 'BOOKING_REQUESTED',
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
      participantId,
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
      ...(participantId && {
        OR: [
          { playerId: participantId }, 
          { opponentId: participantId },
          { participants: { some: { playerId: participantId } } }
        ],
      }),
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
          participants: {
            include: { player: { select: { id: true, firstName: true, lastName: true, profilePicture: true } } }
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
   * Get available matches logic
   */
  static async getAvailableMatches(filters = {}) {
    const { sport, limit = 20, page = 1 } = filters;
    const skip = (page - 1) * limit;

    const where = {
      status: 'CONFIRMED',
      needsOpponent: true,
      ...(sport && { sport }),
    };

    const [bookings, total] = await Promise.all([
      prisma.booking.findMany({
        where,
        skip,
        take: limit,
        orderBy: { date: 'asc' },
        include: {
          court: {
            select: { id: true, name: true, location: true, city: true },
          },
          player: {
            select: { id: true, firstName: true, lastName: true, profilePicture: true },
          },
          participants: {
            include: { player: { select: { id: true, firstName: true, lastName: true, profilePicture: true } } }
          },
        },
      }),
      prisma.booking.count({ where }),
    ]);

    return {
      bookings,
      pagination: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  /**
   * Join match logic
   */
  static async joinMatch(id, playerId, targetTeam = null) {
    const booking = await this.getById(id);

    if (booking.status !== 'CONFIRMED' || !booking.needsOpponent) {
      throw new AppError('This match is no longer available to join', 400);
    }
    if (booking.playerId === playerId) {
      throw new AppError('You cannot join your own match', 400);
    }

    if (booking.matchType === 'DOUBLES') {
      const participants = booking.participants || [];
      const teamACount = participants.filter(p => p.team === 'TEAM_A').length;
      const teamBCount = participants.filter(p => p.team === 'TEAM_B').length;

      if (participants.some(p => p.playerId === playerId)) {
        throw new AppError('You are already part of this match', 400);
      }

      if (participants.length >= 4) {
        throw new AppError('This match is already full', 400);
      }

      let assignedTeam = 'TEAM_B';
      if (targetTeam === 'TEAM_A') {
        if (teamACount >= 2) throw new AppError('Partner slot is already taken', 400);
        assignedTeam = 'TEAM_A';
      } else if (targetTeam === 'TEAM_B') {
        if (teamBCount >= 2) throw new AppError('Opponents slots are already full', 400);
        assignedTeam = 'TEAM_B';
      } else {
        if (teamBCount < 2) assignedTeam = 'TEAM_B';
        else assignedTeam = 'TEAM_A';
      }

      await prisma.bookingParticipant.create({
        data: { bookingId: id, playerId, team: assignedTeam }
      });

      const updatedCount = participants.length + 1;
      const needsOpponent = updatedCount < 4;

      const updatedBooking = await prisma.booking.update({
        where: { id },
        data: { needsOpponent },
        include: { player: true, opponent: true, court: true, participants: true },
      });

      await NotificationService.create({
        receiverId: booking.playerId,
        senderId: playerId,
        type: 'MATCH_ACCEPTED',
        title: 'Player Joined!',
        message: `A new player has joined your ${booking.sport} Doubles match!`,
        data: { bookingId: id },
      });

      return updatedBooking;

    } else {
      // SINGLES / TEAM logic
      const updatedBooking = await prisma.booking.update({
        where: { id },
        data: {
          opponentId: playerId,
          needsOpponent: false,
        },
        include: { player: true, opponent: true, court: true },
      });

      await NotificationService.create({
        receiverId: booking.playerId,
        senderId: playerId,
        type: 'MATCH_ACCEPTED',
        title: 'Match Found!',
        message: `${updatedBooking.opponent.firstName} has accepted your ${booking.sport} challenge for ${booking.startTime}`,
        data: { bookingId: id },
      });

      return updatedBooking;
    }
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
    location: true,
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
        participants: {
          include: { player: { select: { id: true, firstName: true, lastName: true, profilePicture: true } } }
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

    if (booking.status !== 'PENDING' && booking.status !== 'PENDING_APPROVAL') {
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
  static async reject(id, ownerId, reason) {
    const booking = await this.getById(id);

    if (booking.court.owner.id !== ownerId) {
      throw new AppError('You do not have permission to reject this booking', 403);
    }

    if (booking.status !== 'PENDING' && booking.status !== 'PENDING_APPROVAL') {
      throw new AppError('Booking cannot be rejected', 400);
    }

    return prisma.booking.update({
      where: { id },
      data: { 
        status: 'REJECTED',
        rejectionReason: reason
      },
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
    return this.getAll({ ...filters, participantId: playerId });
  }

  static async getOwnerBookings(ownerId, filters = {}) {
    return this.getAll({ ...filters, ownerId });
  }
}

module.exports = BookingService;
