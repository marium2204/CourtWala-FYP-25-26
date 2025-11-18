const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // Create admin user
  const adminPassword = await bcrypt.hash('admin123', 10);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@courtwala.com' },
    update: {},
    create: {
      email: 'admin@courtwala.com',
      password: adminPassword,
      firstName: 'Admin',
      lastName: 'User',
      role: 'ADMIN',
      status: 'ACTIVE',
    },
  });

  console.log('Admin user created:', admin.email);

  // Create sample court owner
  const ownerPassword = await bcrypt.hash('owner123', 10);
  const owner = await prisma.user.upsert({
    where: { email: 'owner@courtwala.com' },
    update: {},
    create: {
      email: 'owner@courtwala.com',
      password: ownerPassword,
      firstName: 'Court',
      lastName: 'Owner',
      role: 'COURT_OWNER',
      status: 'ACTIVE',
    },
  });

  console.log('Court owner created:', owner.email);

  // Create sample player
  const playerPassword = await bcrypt.hash('player123', 10);
  const player = await prisma.user.upsert({
    where: { email: 'player@courtwala.com' },
    update: {},
    create: {
      email: 'player@courtwala.com',
      password: playerPassword,
      firstName: 'Test',
      lastName: 'Player',
      role: 'PLAYER',
      status: 'ACTIVE',
      skillLevel: 'INTERMEDIATE',
      preferredSports: ['TENNIS', 'BADMINTON'],
    },
  });

  console.log('Player created:', player.email);

  console.log('Seeding completed!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

