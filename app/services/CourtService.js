const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');

class CourtService {
  /**
   * Get all courts with filters
   */
  static async getAll(filters = {}) {
    const {
      sport,
      location,
      minPrice,
      maxPrice,
      status = 'ACTIVE',
      ownerId,
      limit = 20,
      page = 1,
      search,
    } = filters;

    const skip = (page - 1) * limit;

    const where = {
      status,
      ...(sport && { sport }),
      ...(location && { location: { contains: location, mode: 'insensitive' } }),
      ...(minPrice && { price: { gte: minPrice } }),
      ...(maxPrice && { price: { lte: maxPrice } }),
      ...(ownerId && { ownerId }),
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { location: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };

    const [courts, total] = await Promise.all([
      prisma.court.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          owner: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
          _count: {
            select: {
              bookings: true,
              reviews: true,
            },
          },
        },
      }),
      prisma.court.count({ where }),
    ]);

    return {
      courts,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get court by ID
   */
  static async getById(id) {
    const court = await prisma.court.findUnique({
      where: { id },
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
        reviews: {
          include: {
            player: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                profilePicture: true,
              },
            },
          },
          orderBy: { createdAt: 'desc' },
          take: 10,
        },
        _count: {
          select: {
            bookings: true,
            reviews: true,
          },
        },
      },
    });

    if (!court) {
      throw new AppError('Court not found', 404);
    }

    return court;
  }

  /**
   * Create court
   */
  static async create(data, ownerId) {
    const {
      name,
      description,
      location,
      sport,
      price,
      facilities = [],
      images = [],
    } = data;

    return prisma.court.create({
      data: {
        name,
        description,
        location,
        sport,
        price: parseFloat(price),
        facilities,
        images,
        ownerId,
        status: 'PENDING_APPROVAL',
      },
    });
  }

  /**
   * Update court
   */
  static async update(id, data, ownerId) {
    const court = await prisma.court.findUnique({
      where: { id },
    });

    if (!court) {
      throw new AppError('Court not found', 404);
    }

    if (court.ownerId !== ownerId) {
      throw new AppError('You do not have permission to update this court', 403);
    }

    const updateData = {};
    if (data.name) updateData.name = data.name;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.location) updateData.location = data.location;
    if (data.sport) updateData.sport = data.sport;
    if (data.price) updateData.price = parseFloat(data.price);
    if (data.facilities) updateData.facilities = data.facilities;
    if (data.images) updateData.images = data.images;

    // If updating, set status back to pending if it was approved
    if (court.status === 'ACTIVE' && Object.keys(updateData).length > 0) {
      updateData.status = 'PENDING_APPROVAL';
    }

    return prisma.court.update({
      where: { id },
      data: updateData,
    });
  }

  /**
   * Delete court
   */
  static async delete(id, ownerId) {
    const court = await prisma.court.findUnique({
      where: { id },
    });

    if (!court) {
      throw new AppError('Court not found', 404);
    }

    if (court.ownerId !== ownerId) {
      throw new AppError('You do not have permission to delete this court', 403);
    }

    return prisma.court.delete({
      where: { id },
    });
  }

  /**
   * Get owner's courts
   */
  static async getOwnerCourts(ownerId, filters = {}) {
    const { status, limit = 20, page = 1 } = filters;
    const skip = (page - 1) * limit;

    const where = {
      ownerId,
      ...(status && { status }),
    };

    const [courts, total] = await Promise.all([
      prisma.court.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          _count: {
            select: {
              bookings: true,
              reviews: true,
            },
          },
        },
      }),
      prisma.court.count({ where }),
    ]);

    return {
      courts,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Approve/reject court (Admin only)
   */
  static async updateCourtStatus(id, status) {
    if (!['ACTIVE', 'INACTIVE', 'REJECTED'].includes(status)) {
      throw new AppError('Invalid status', 400);
    }

    return prisma.court.update({
      where: { id },
      data: { status },
    });
  }
}

module.exports = CourtService;

