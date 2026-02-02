const prisma = require('../../config/database');
const { AppError } = require('../utils/ErrorHandler');

class CourtService {
  /* =========================
     STATUS NORMALIZATION
  ========================= */
  static normalizeStatus(status) {
    if (!status) return undefined;

    const statusMap = {
      PENDING: 'PENDING_APPROVAL',
      PENDING_APPROVAL: 'PENDING_APPROVAL',
      ACTIVE: 'ACTIVE',
      INACTIVE: 'INACTIVE',
      REJECTED: 'REJECTED',
      APPROVED: 'ACTIVE',
    };

    const normalized = statusMap[status.toUpperCase()];
    if (!normalized) {
      throw new AppError(
        `Invalid status: ${status}. Valid values are: PENDING_APPROVAL, ACTIVE, INACTIVE, REJECTED`,
        400
      );
    }
    return normalized;
  }

  /* =========================
     PLAYER / PUBLIC: GET ALL COURTS
  ========================= */
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
    const normalizedStatus = status ? this.normalizeStatus(status) : undefined;

    const where = {
      ...(normalizedStatus && { status: normalizedStatus }),
      ...(sport && {
        courtSports: {
          some: {
            sport: {
              name: sport,
            },
          },
        },
      }),
      ...(location && {
        OR: [
          { location: { contains: location } },
          { address: { contains: location } },
          { city: { contains: location } },
          { state: { contains: location } },
        ],
      }),
      ...(minPrice && { pricePerHour: { gte: minPrice } }),
      ...(maxPrice && { pricePerHour: { lte: maxPrice } }),
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
          courtSports: {
            include: {
              sport: { select: { id: true, name: true } },
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
      courts: courts.map(c => ({
        ...c,
        sports: c.courtSports.map(cs => cs.sport),
      })),
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /* =========================
     OWNER / PLAYER: GET COURT BY ID
  ========================= */
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
        courtSports: {
          include: {
            sport: { select: { id: true, name: true } },
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

    return {
      ...court,
      sports: court.courtSports.map(cs => cs.sport),
    };
  }
/* =========================
   ADMIN: GET COURT BY ID
========================= */
static async getAdminCourtById(id) {
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
      courtSports: {
        include: {
          sport: { select: { id: true, name: true } },
        },
      },
      slots: {
        orderBy: { startTime: 'asc' },
      },
      reviews: {
        include: {
          player: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
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

  return {
    ...court,
    sports: court.courtSports.map(cs => cs.sport),
  };
}

  /* =========================
     OWNER: CREATE COURT
  ========================= */
  static async create(data, ownerId) {
    const {
      name,
      description,
      address,
      city,

      mapUrl,
      pricePerHour,
      amenities = [],
      images = [],
      sports,
    } = data;

    if (!mapUrl || !mapUrl.trim()) {
      throw new AppError('Google Maps location URL is required', 400);
    }

    if (!sports || !Array.isArray(sports) || sports.length === 0) {
      throw new AppError('At least one sport is required', 400);
    }

    const location = `${address}, ${city}`;

    const court = await prisma.court.create({
      data: {
        name,
        description,
        address,
        city,
        location,
        mapUrl,
        pricePerHour: Number(pricePerHour),
        price: Number(pricePerHour),
        amenities,
        facilities: amenities,
        images,
        ownerId,
        status: 'PENDING_APPROVAL',
        courtSports: {
          create: sports.map(sportId => ({ sportId })),
        },
      },
      include: {
        courtSports: {
          include: {
            sport: { select: { id: true, name: true } },
          },
        },
      },
    });

    return {
      ...court,
      sports: court.courtSports.map(cs => cs.sport),
    };
  }

  /* =========================
     OWNER: UPDATE COURT
  ========================= */
static async update(id, data, ownerId) {
  const court = await prisma.court.findUnique({ where: { id } });

  if (!court) throw new AppError('Court not found', 404);
  if (court.ownerId !== ownerId)
    throw new AppError('You do not have permission to update this court', 403);

  const { sports, ...rest } = data;
  const updateData = {};

  if (rest.name) updateData.name = rest.name;
  if (rest.description !== undefined)
    updateData.description = rest.description;
  if (rest.address) updateData.address = rest.address;
  if (rest.city) updateData.city = rest.city;

  if (rest.mapUrl !== undefined) {
    if (!rest.mapUrl.trim()) {
      throw new AppError('Google Maps location URL cannot be empty', 400);
    }
    updateData.mapUrl = rest.mapUrl;
  }

  if (rest.pricePerHour !== undefined) {
    updateData.pricePerHour = Number(rest.pricePerHour);
    updateData.price = Number(rest.pricePerHour);
  }

  if (rest.amenities) {
    updateData.amenities = rest.amenities;
    updateData.facilities = rest.amenities;
  }

  // =========================
  // ✅ CLOUDINARY IMAGE LOGIC
  // =========================
  let finalImages = [];

  if (rest.existingImages) {
    if (Array.isArray(rest.existingImages)) {
      finalImages = rest.existingImages;
    } else if (typeof rest.existingImages === 'string') {
      try {
        finalImages = JSON.parse(rest.existingImages);
      } catch {
        throw new AppError('Invalid existingImages format', 400);
      }
    }
  }

  if (rest.images && Array.isArray(rest.images)) {
    finalImages = [...finalImages, ...rest.images];
  }

  updateData.images = finalImages;

  if (rest.address || rest.city) {
    updateData.location = `${rest.address || court.address}, ${
      rest.city || court.city
    }`;
  }

  if (court.status === 'ACTIVE') {
    updateData.status = 'PENDING_APPROVAL';
  }

  await prisma.$transaction([
    prisma.courtSport.deleteMany({ where: { courtId: id } }),
    prisma.court.update({
      where: { id },
      data: {
        ...updateData,
        courtSports: {
          create: (sports || []).map(sportId => ({ sportId })),
        },
      },
    }),
  ]);

  return true;
}


  /* =========================
     OWNER: DELETE COURT
  ========================= */
  static async delete(id, ownerId) {
    const court = await prisma.court.findUnique({ where: { id } });
    if (!court) throw new AppError('Court not found', 404);
    if (court.ownerId !== ownerId)
      throw new AppError('You do not have permission to delete this court', 403);

    return prisma.court.delete({ where: { id } });
  }

  /* =========================
     OWNER: GET MY COURTS
  ========================= */
  /* =========================
   OWNER: GET MY COURTS (FIXED)
========================= */
static async getOwnerCourts(ownerId, filters = {}) {
  const { status, limit = 20, page = 1 } = filters;
  const skip = (page - 1) * limit;
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
        courtSports: {
          include: {
            sport: { select: { id: true, name: true } },
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
    courts: courts.map(c => ({
      ...c,
      sports: c.courtSports.map(cs => cs.sport),
    })),
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    },
  };
}

  /* =========================
     ADMIN: UPDATE COURT STATUS
  ========================= */
  static async updateCourtStatus(id, status) {
    const normalizedStatus = this.normalizeStatus(status);
    if (!['ACTIVE', 'INACTIVE', 'REJECTED'].includes(normalizedStatus)) {
      throw new AppError('Invalid status update', 400);
    }
    return prisma.court.update({
      where: { id },
      data: { status: normalizedStatus },
    });
  }

  /* =========================
     ADMIN: GET ALL COURTS
  ========================= */
  static async getAllAdmin(filters = {}) {
    const { status, sport, limit = 20, page = 1 } = filters;
    const skip = (page - 1) * limit;

    const where = {
      ...(status && { status }),
      ...(sport && {
        courtSports: {
          some: {
            sport: {
              name: sport,
            },
          },
        },
      }),
    };

    const [courts, total] = await Promise.all([
      prisma.court.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          courtSports: {
            include: {
              sport: { select: { id: true, name: true } },
            },
          },
          owner: {
            select: {
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
      courts: courts.map(c => ({
        ...c,
        sports: c.courtSports.map(cs => cs.sport),
      })),
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}

module.exports = CourtService;
