const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const NotificationService = require('./NotificationService');

class MatchmakingService {
  /**
   * Search players
   */
  static async searchPlayers(filters = {}) {
    const {
      name,
      sport,
      skillLevel,
      excludeUserId,
      limit = 20,
      page = 1,
    } = filters;

    const skip = (page - 1) * limit;

    const where = {
      role: 'PLAYER',
      status: 'ACTIVE',
      ...(excludeUserId && { id: { not: excludeUserId } }),
      ...(name && {
        OR: [
          { firstName: { contains: name, mode: 'insensitive' } },
          { lastName: { contains: name, mode: 'insensitive' } },
          { username: { contains: name, mode: 'insensitive' } },
        ],
      }),
      ...(sport && { preferredSports: { has: sport } }),
      ...(skillLevel && { skillLevel }),
    };

    const [players, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: limit,
        select: {
          id: true,
          firstName: true,
          lastName: true,
          username: true,
          profilePicture: true,
          skillLevel: true,
          preferredSports: true,
        },
      }),
      prisma.user.count({ where }),
    ]);

    return {
      players,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Send match request
   */
  static async sendMatchRequest(data, senderId) {
    const { receiverId, bookingId, sport, skillLevel, message } = data;

    if (senderId === receiverId) {
      throw new AppError('Cannot send match request to yourself', 400);
    }

    // Check if receiver exists and is a player
    const receiver = await prisma.user.findUnique({
      where: { id: receiverId },
    });

    if (!receiver || receiver.role !== 'PLAYER') {
      throw new AppError('Invalid receiver', 404);
    }

    // Check if request already exists
    const existingRequest = await prisma.matchRequest.findFirst({
      where: {
        senderId,
        receiverId,
        status: 'PENDING',
      },
    });

    if (existingRequest) {
      throw new AppError('Match request already sent', 409);
    }

    // Create match request
    const matchRequest = await prisma.matchRequest.create({
      data: {
        senderId,
        receiverId,
        bookingId,
        sport,
        skillLevel,
        message,
        status: 'PENDING',
      },
      include: {
        sender: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePicture: true,
          },
        },
        receiver: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePicture: true,
          },
        },
      },
    });

    // Notify receiver
    await NotificationService.create({
      receiverId,
      senderId,
      type: 'MATCH_REQUEST',
      title: 'New Match Request',
      message: `${matchRequest.sender.firstName} ${matchRequest.sender.lastName} wants to play with you`,
      data: { matchRequestId: matchRequest.id },
    });

    return matchRequest;
  }

  /**
   * Get match requests
   */
  static async getMatchRequests(userId, type = 'received') {
    const where =
      type === 'sent'
        ? { senderId: userId }
        : { receiverId: userId };

    return prisma.matchRequest.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        sender: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePicture: true,
            skillLevel: true,
          },
        },
        receiver: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePicture: true,
            skillLevel: true,
          },
        },
      },
    });
  }

  /**
   * Accept match request
   */
  static async acceptMatchRequest(requestId, receiverId) {
    const matchRequest = await prisma.matchRequest.findUnique({
      where: { id: requestId },
      include: {
        sender: true,
        receiver: true,
      },
    });

    if (!matchRequest) {
      throw new AppError('Match request not found', 404);
    }

    if (matchRequest.receiverId !== receiverId) {
      throw new AppError('You do not have permission to accept this request', 403);
    }

    if (matchRequest.status !== 'PENDING') {
      throw new AppError('Match request cannot be accepted', 400);
    }

    // Update match request
    const updatedRequest = await prisma.matchRequest.update({
      where: { id: requestId },
      data: { status: 'ACCEPTED' },
    });

    // If there's a booking, update it with opponent
    if (matchRequest.bookingId) {
      await prisma.booking.update({
        where: { id: matchRequest.bookingId },
        data: { opponentId: matchRequest.senderId },
      });
    }

    // Notify sender
    await NotificationService.create({
      receiverId: matchRequest.senderId,
      senderId: receiverId,
      type: 'MATCH_ACCEPTED',
      title: 'Match Request Accepted',
      message: `${matchRequest.receiver.firstName} ${matchRequest.receiver.lastName} accepted your match request`,
      data: { matchRequestId: requestId },
    });

    return updatedRequest;
  }

  /**
   * Reject match request
   */
  static async rejectMatchRequest(requestId, receiverId) {
    const matchRequest = await prisma.matchRequest.findUnique({
      where: { id: requestId },
      include: {
        sender: true,
        receiver: true,
      },
    });

    if (!matchRequest) {
      throw new AppError('Match request not found', 404);
    }

    if (matchRequest.receiverId !== receiverId) {
      throw new AppError('You do not have permission to reject this request', 403);
    }

    if (matchRequest.status !== 'PENDING') {
      throw new AppError('Match request cannot be rejected', 400);
    }

    const updatedRequest = await prisma.matchRequest.update({
      where: { id: requestId },
      data: { status: 'REJECTED' },
    });

    // Notify sender
    await NotificationService.create({
      receiverId: matchRequest.senderId,
      senderId: receiverId,
      type: 'MATCH_REJECTED',
      title: 'Match Request Rejected',
      message: `${matchRequest.receiver.firstName} ${matchRequest.receiver.lastName} rejected your match request`,
      data: { matchRequestId: requestId },
    });

    return updatedRequest;
  }
}

module.exports = MatchmakingService;

