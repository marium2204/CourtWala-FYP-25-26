const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * =============================
 * Court Owner creates slots
 * =============================
 */
exports.createSlots = async (courtId, slots) => {
  return prisma.courtSlot.createMany({
    data: slots.map((slot) => ({
      courtId,
      startTime: slot.startTime,
      endTime: slot.endTime,
    })),
    skipDuplicates: true,
  });
};


/**
 * =============================
 * Player fetches slots for a date
 * =============================
 */
exports.getAvailableSlots = async (courtId, date) => {

  // Get all slots for the court
  const allSlots = await prisma.courtSlot.findMany({
    where: {
      courtId,
      isActive: true,
    },
    orderBy: {
      startTime: 'asc',
    },
  });

  // Get bookings for that date
  const bookings = await prisma.booking.findMany({
    where: {
      courtId,
      date: new Date(date),
      status: {
        in: ['PENDING', 'CONFIRMED'],
      },
    },
    select: {
      startTime: true,
      endTime: true,
    },
  });

  // Mark slots as booked if times match
  return allSlots.map((slot) => {

    const isBooked = bookings.some(
      (b) =>
        b.startTime === slot.startTime &&
        b.endTime === slot.endTime
    );

    return {
      id: slot.id,
      startTime: slot.startTime,
      endTime: slot.endTime,
      available: !isBooked,
    };
  });
};


/**
 * =============================
 * Owner fetches all slots
 * =============================
 */
exports.getAllSlots = async (courtId) => {
  return prisma.courtSlot.findMany({
    where: { courtId },
    orderBy: { startTime: 'asc' },
  });
};


/**
 * =============================
 * Delete slot (only if unused)
 * =============================
 */
exports.deleteSlot = async (slotId) => {

  const activeBookingCount = await prisma.booking.count({
    where: {
      slotId,
      status: {
        in: ['PENDING', 'CONFIRMED'],
      },
    },
  });

  if (activeBookingCount > 0) {
    throw new Error(
      'Slot cannot be deleted because it has active bookings'
    );
  }

  return prisma.courtSlot.delete({
    where: { id: slotId },
  });
};