const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');

class CourtService {
  /**
   * Normalize status value to match CourtStatus enum
   */
  static normalizeStatus(status) {
    if (!status) return undefined;
    
    const statusMap = {
      'PENDING': 'PENDING_APPROVAL',
      'PENDING_APPROVAL': 'PENDING_APPROVAL',
      'ACTIVE': 'ACTIVE',
      'INACTIVE': 'INACTIVE',
      'REJECTED': 'REJECTED',
      'APPROVED': 'ACTIVE', // Map APPROVED to ACTIVE for backward compatibility
    };

    const normalized = statusMap[status.toUpperCase()];
    if (!normalized) {
      throw new AppError(`Invalid status: ${status}. Valid values are: PENDING_APPROVAL, ACTIVE, INACTIVE, REJECTED`, 400);
    }
    return normalized;
  }

  /**
   * Get all courts with filters
   */
  static async getAll(filters = {}) {
    const {
      sport,
      location,
      minPrice,
      maxPrice,
      status,
      ownerId,
      limit = 20,
      page = 1,
      search,
    } = filters;

    const skip = (page - 1) * limit;

    // Normalize status only if provided (if not provided, fetch all courts)
    const normalizedStatus = status ? this.normalizeStatus(status) : undefined;

    const where = {
      ...(normalizedStatus && { status: normalizedStatus }),
      ...(sport && { sport }),
      ...(location && {
        OR: [
          { location: { contains: location } },
          { address: { contains: location } },
          { city: { contains: location } },
          { state: { contains: location } },
        ],
      }),
      ...(minPrice && {
        OR: [
          { pricePerHour: { gte: minPrice } },
          { price: { gte: minPrice } },
        ],
      }),
      ...(maxPrice && {
        OR: [
          { pricePerHour: { lte: maxPrice } },
          { price: { lte: maxPrice } },
        ],
      }),
      ...(ownerId && { ownerId }),
      ...(search && {
        OR: [
          { name: { contains: search } },
          { location: { contains: search } },
          { address: { contains: search } },
          { city: { contains: search } },
          { description: { contains: search } },
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
      address,
      city,
      state,
      zipCode,
      sport,
      pricePerHour,
      amenities = [],
      images = [],
    } = data;

    // Combine address fields into location for backward compatibility
    const location = `${address}, ${city}, ${state} ${zipCode}`;

    return prisma.court.create({
      data: {
        name,
        description,
        address,
        city,
        state,
        zipCode,
        location, // Generated from address fields
        sport,
        pricePerHour: parseFloat(pricePerHour),
        price: parseFloat(pricePerHour), // Keep for backward compatibility
        amenities,
        facilities: amenities, // Keep for backward compatibility
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
    if (data.address) updateData.address = data.address;
    if (data.city) updateData.city = data.city;
    if (data.state) updateData.state = data.state;
    if (data.zipCode) updateData.zipCode = data.zipCode;
    if (data.sport) updateData.sport = data.sport;
    if (data.pricePerHour !== undefined) {
      updateData.pricePerHour = parseFloat(data.pricePerHour);
      updateData.price = parseFloat(data.pricePerHour); // Keep for backward compatibility
    }
    if (data.amenities) {
      updateData.amenities = data.amenities;
      updateData.facilities = data.amenities; // Keep for backward compatibility
    }
    if (data.images) updateData.images = data.images;

    // Update location if any address field changed
    if (data.address || data.city || data.state || data.zipCode) {
      const newAddress = data.address || court.address;
      const newCity = data.city || court.city;
      const newState = data.state || court.state;
      const newZipCode = data.zipCode || court.zipCode;
      updateData.location = `${newAddress}, ${newCity}, ${newState} ${newZipCode}`;
    }

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

    // Normalize status if provided
    const normalizedStatus = status ? this.normalizeStatus(status) : undefined;

    const where = {
      ownerId,
      ...(normalizedStatus && { status: normalizedStatus }),
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
    // Normalize status (e.g., APPROVED -> ACTIVE, PENDING -> PENDING_APPROVAL)
    const normalizedStatus = this.normalizeStatus(status);
    
    // Only allow ACTIVE, INACTIVE, REJECTED for status updates (admin actions)
    if (!['ACTIVE', 'INACTIVE', 'REJECTED'].includes(normalizedStatus)) {
      throw new AppError(`Invalid status for update: ${status}. Valid values are: ACTIVE, INACTIVE, REJECTED`, 400);
    }

    return prisma.court.update({
      where: { id },
      data: { status: normalizedStatus },
    });
  }
}

module.exports = CourtService;

