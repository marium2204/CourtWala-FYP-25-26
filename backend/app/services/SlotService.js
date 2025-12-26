const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Court Owner creates slots (once)
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
 * Player fetches slots for a specific date
 */
exports.getAvailableSlots = async (courtId, date) => {
  const allSlots = await prisma.courtSlot.findMany({
    where: {
      courtId,
      isActive: true,
    },
    orderBy: {
      startTime: 'asc',
    },
  });

  const bookings = await prisma.booking.findMany({
    where: {
      courtId,
      date: new Date(date),
      status: {
        in: ['PENDING', 'CONFIRMED'],
      },
    },
    select: {
      slotId: true,
    },
  });

  const bookedSlotIds = bookings.map((b) => b.slotId);

  return allSlots.map((slot) => ({
    id: slot.id,
    startTime: slot.startTime,
    endTime: slot.endTime,
    available: !bookedSlotIds.includes(slot.id),
  }));
};

exports.getAllSlots = async (courtId) => {
  return prisma.courtSlot.findMany({
    where: { courtId },
    orderBy: { startTime: 'asc' },
  });

};
exports.deleteSlot = async (slotId) => {
  // Check if slot has bookings
  const bookingCount = await prisma.booking.count({
    where: {
      slotId,
      status: {
        in: ['PENDING', 'CONFIRMED'],
      },
    },
  });

  if (bookingCount > 0) {
    throw new Error('Slot cannot be deleted because it has active bookings');
  }

  return prisma.courtSlot.delete({
    where: { id: slotId },
  });
};

