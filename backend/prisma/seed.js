const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const bcrypt = require('bcryptjs');

async function main() {
  console.log('🌱 Seeding CourtWala Production-like Database...\n');

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
  const adminPassword = await bcrypt.hash('Adm!n@CourtWala#2026', 12);

  const admin = await prisma.user.create({
    data: {
      email: 'admin@courtwala.pk',
      password: adminPassword,
      firstName: 'System',
      lastName: 'Administrator',
      role: 'ADMIN',
      provider: 'EMAIL',
      emailVerified: true,
    },
  });

  console.log('✅ Admin created');
}
main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
