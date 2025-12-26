const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');
const NotificationService = require('./NotificationService');

class TournamentService {
  /**
   * Get all tournaments with filters
   */
 static async getAll(filters = {}) {
  const {
    sport,
    skillLevel,
    status,
    limit = 20,
    page = 1,
  } = filters;

  const skip = (page - 1) * limit;

  const where = {
    ...(sport && { sport }),
    ...(skillLevel && { skillLevel }),
    ...(status && { status }),
  };

  const [tournaments, total] = await Promise.all([
    prisma.tournament.findMany({
      where,
      skip,
      take: limit,
      orderBy: { startDate: 'asc' },

      // ✅ THIS IS THE IMPORTANT PART
      select: {
        id: true,
        name: true,
        description: true,
        sport: true,
        skillLevel: true,
        status: true,
        startDate: true,
        endDate: true,
        maxParticipants: true,
        currentParticipants: true,

        participants: {
          select: {
            playerId: true, // needed to check "joined"
          },
        },

        _count: {
          select: {
            participants: true,
          },
        },
      },
    }),

    prisma.tournament.count({ where }),
  ]);

  return {
    tournaments,
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    },
  };
}


  /**
   * Get tournament by ID
   */
  static async getById(id) {
    const tournament = await prisma.tournament.findUnique({
      where: { id },
      include: {
        participants: {
          include: {
            player: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                profilePicture: true,
                skillLevel: true,
              },
            },
          },
        },
        _count: {
          select: {
            participants: true,
          },
        },
      },
    });

    if (!tournament) {
      throw new AppError('Tournament not found', 404);
    }

    return tournament;
  }

  /**
   * Create tournament (Admin only)
   */
  static async create(data) {
    const {
      name,
      description,
      sport,
      skillLevel,
      startDate,
      endDate,
      maxParticipants,
    } = data;

    // Validate required fields
    if (!name || !name.trim()) {
      throw new AppError('Tournament name is required', 400);
    }

    if (!sport || !sport.trim()) {
      throw new AppError('Sport is required', 400);
    }

    if (!startDate) {
      throw new AppError('Start date is required', 400);
    }

    if (!endDate) {
      throw new AppError('End date is required', 400);
    }

    if (!maxParticipants || maxParticipants < 2) {
      throw new AppError('Max participants must be at least 2', 400);
    }

    if (new Date(startDate) < new Date()) {
      throw new AppError('Start date cannot be in the past', 400);
    }

    if (new Date(endDate) < new Date(startDate)) {
      throw new AppError('End date must be after start date', 400);
    }

    return prisma.tournament.create({
      data: {
        name: name.trim(),
        description: description?.trim() || null,
        sport: sport.trim(),
        skillLevel: skillLevel?.trim() || null,
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        maxParticipants: parseInt(maxParticipants),
        status: 'UPCOMING',
      },
    });
  }

  /**
   * Join tournament
   */
  static async joinTournament(tournamentId, playerId) {
    const tournament = await this.getById(tournamentId);

    if (tournament.status !== 'UPCOMING') {
      throw new AppError('Tournament is not accepting participants', 400);
    }

    if (tournament.currentParticipants >= tournament.maxParticipants) {
      throw new AppError('Tournament is full', 409);
    }

    // Check if already joined
    const existingParticipant = await prisma.tournamentParticipant.findUnique({
      where: {
        tournamentId_playerId: {
          tournamentId,
          playerId,
        },
      },
    });

    if (existingParticipant) {
      throw new AppError('You are already registered for this tournament', 409);
    }

    // Add participant
    await prisma.tournamentParticipant.create({
      data: {
        tournamentId,
        playerId,
      },
    });

    // Update participant count
    const updatedTournament = await prisma.tournament.update({
      where: { id: tournamentId },
      data: {
        currentParticipants: {
          increment: 1,
        },
      },
    });

    // Notify player
    await NotificationService.create({
      receiverId: playerId,
      type: 'TOURNAMENT_JOINED',
      title: 'Tournament Registration',
      message: `You have successfully joined ${tournament.name}`,
      data: { tournamentId },
    });

    return updatedTournament;
  }

  /**
   * Leave tournament
   */
  static async leaveTournament(tournamentId, playerId) {
    const participant = await prisma.tournamentParticipant.findUnique({
      where: {
        tournamentId_playerId: {
          tournamentId,
          playerId,
        },
      },
    });

    if (!participant) {
      throw new AppError('You are not registered for this tournament', 404);
    }

    await prisma.tournamentParticipant.delete({
      where: {
        tournamentId_playerId: {
          tournamentId,
          playerId,
        },
      },
    });

    // Update participant count
    return prisma.tournament.update({
      where: { id: tournamentId },
      data: {
        currentParticipants: {
          decrement: 1,
        },
      },
    });
  }

  /**
   * Update tournament (Admin only)
   */
  static async update(id, data) {
    const tournament = await this.getById(id);

    const updateData = {};
    if (data.name) updateData.name = data.name;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.sport) updateData.sport = data.sport;
    if (data.skillLevel) updateData.skillLevel = data.skillLevel;
    if (data.startDate) updateData.startDate = new Date(data.startDate);
    if (data.endDate) updateData.endDate = new Date(data.endDate);
    if (data.maxParticipants) updateData.maxParticipants = parseInt(data.maxParticipants);
    if (data.status) updateData.status = data.status;

    return prisma.tournament.update({
      where: { id },
      data: updateData,
    });
  }

  /**
   * Delete tournament (Admin only)
   */
  static async delete(id) {
    return prisma.tournament.delete({
      where: { id },
    });
  }
}

module.exports = TournamentService;

