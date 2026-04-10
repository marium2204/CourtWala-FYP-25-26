const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const bcrypt = require('bcryptjs');

async function main() {
  console.log('🌱 Seeding CourtWala Production-like Database...\n');

  if (process.env.NODE_ENV === 'production' && process.env.ALLOW_SEED !== 'true') {
  throw new Error('❌ Seeding blocked in production');
}

  // =========================
  // CLEAN DATABASE (ORDER MATTERS)
  // =========================
  await prisma.notification.deleteMany();
  await prisma.matchRequest.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.courtSlot.deleteMany();
  await prisma.courtSport.deleteMany();
  await prisma.courtReview.deleteMany();
  await prisma.tournamentParticipant.deleteMany();
  await prisma.tournament.deleteMany();
  await prisma.announcement.deleteMany();
  await prisma.report.deleteMany();
  await prisma.playerSport.deleteMany();
  await prisma.court.deleteMany();
  await prisma.user.deleteMany();
  await prisma.sport.deleteMany();

  // =========================
  // SPORTS (MASTER DATA)
  // =========================
  const sportNames = ['BADMINTON', 'FOOTBALL', 'CRICKET', 'TENNIS', 'PADEL'];
  const sports = {};

  for (const name of sportNames) {
    sports[name] = await prisma.sport.create({ data: { name } });
  }

  console.log('✅ Sports created');

  // =========================
  // ADMIN (STRONG CREDENTIALS)
  // =========================
  const systemPassword = await bcrypt.hash('CourtWala123', 10);

  const admin = await prisma.user.create({
    data: {
      email: 'admin@courtwala.pk',
      password: systemPassword,
      firstName: 'System',
      lastName: 'Administrator',
      role: 'ADMIN',
      provider: 'EMAIL',
      emailVerified: true,
    },
  });

  const owner = await prisma.user.create({
    data: {
      email: 'owner@courtwala.com',
      password: systemPassword,
      firstName: 'John',
      lastName: 'Owner',
      role: 'COURT_OWNER',
      provider: 'EMAIL',
      emailVerified: true,
      bankDetails: {
        create: [
          {
            provider: 'JazzCash',
            accountName: 'John Owner Court',
            accountNumber: '03001234567',
            isActive: true,
          },
          {
            provider: 'EasyPaisa',
            accountName: 'John Owner',
            accountNumber: '03451234567',
            isActive: true,
          }
        ]
      }
    },
  });

  const player = await prisma.user.create({
    data: {
      email: 'player@courtwala.com',
      password: systemPassword,
      firstName: 'Jane',
      lastName: 'Player',
      role: 'PLAYER',
      provider: 'EMAIL',
      emailVerified: true,
    },
  });

  console.log('✅ Users & Default Bank Details created');
}
main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
