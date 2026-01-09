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
      ...(sport || skillLevel
        ? {
            playerSports: {
              some: {
                ...(sport && {
                  sport: { name: sport },
                }),
                ...(skillLevel && { skillLevel }),
              },
            },
          }
        : {}),
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
          playerSports: {
            include: {
              sport: {
                select: { name: true },
              },
            },
          },
        },
      }),
      prisma.user.count({ where }),
    ]);

    const formattedPlayers = players.map((p) => ({
      id: p.id,
      firstName: p.firstName,
      lastName: p.lastName,
      username: p.username,
      profilePicture: p.profilePicture,
      sports: p.playerSports.map((ps) => ({
        sport: ps.sport.name,
        skillLevel: ps.skillLevel,
      })),
    }));

    return {
      players: formattedPlayers,
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

    const receiver = await prisma.user.findUnique({
      where: { id: receiverId },
    });

    if (!receiver || receiver.role !== 'PLAYER') {
      throw new AppError('Invalid receiver', 404);
    }

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

    await NotificationService.create({
      receiverId,
      senderId,
      type: 'MATCH_REQUEST',
      title: 'New Match Request',
      message: `${matchRequest.sender.firstName} wants to play ${sport}`,
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
  }

  static async acceptMatchRequest(requestId, receiverId) {
    const matchRequest = await prisma.matchRequest.findUnique({
      where: { id: requestId },
      include: { sender: true, receiver: true },
    });

    if (!matchRequest || matchRequest.receiverId !== receiverId) {
      throw new AppError('Invalid request', 403);
    }

    return prisma.matchRequest.update({
      where: { id: requestId },
      data: { status: 'ACCEPTED' },
    });
  }

  static async rejectMatchRequest(requestId, receiverId) {
    const matchRequest = await prisma.matchRequest.findUnique({
      where: { id: requestId },
      include: { sender: true, receiver: true },
    });

    if (!matchRequest || matchRequest.receiverId !== receiverId) {
      throw new AppError('Invalid request', 403);
    }

    return prisma.matchRequest.update({
      where: { id: requestId },
      data: { status: 'REJECTED' },
    });
  }
}

module.exports = MatchmakingService;
