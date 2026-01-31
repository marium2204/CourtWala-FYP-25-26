const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const bcrypt = require('bcryptjs');

async function main() {
  console.log('🌱 Seeding full fake database...\n');
  console.log(Object.keys(prisma));

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
  await prisma.report.deleteMany();
  await prisma.playerSport.deleteMany();
  await prisma.court.deleteMany();
  await prisma.user.deleteMany();
  await prisma.sport.deleteMany();

  // =========================
  // SPORTS (MASTER DATA)
  // =========================
  const sportNames = ['BADMINTON', 'FOOTBALL', 'PADEL', 'CRICKET', 'TENNIS'];
  const sports = {};

  for (const name of sportNames) {
    sports[name] = await prisma.sport.create({ data: { name } });
  }

  console.log('✅ Sports created');

  // =========================
  // USERS
  // =========================
  const password = await bcrypt.hash('password', 10);

  await prisma.user.create({
    data: {
      email: 'admin@demo.com',
      password,
      firstName: 'Admin',
      lastName: 'User',
      role: 'ADMIN',
      status: 'ACTIVE',
      provider: 'EMAIL',
      emailVerified: true,
    },
  });

  const owners = [];
  for (let i = 1; i <= 5; i++) {
    owners.push(
      await prisma.user.create({
        data: {
          email: `owner${i}@demo.com`,
          password,
          firstName: 'Court',
          lastName: `Owner ${i}`,
          role: 'COURT_OWNER',
          status: 'ACTIVE',
          provider: 'EMAIL',
          emailVerified: true,
        },
      })
    );
  }

  const players = [];
  for (let i = 1; i <= 5; i++) {
    players.push(
      await prisma.user.create({
        data: {
          email: `player${i}@demo.com`,
          password,
          firstName: 'Player',
          lastName: `${i}`,
          username: `player${i}`,
          role: 'PLAYER',
          status: 'ACTIVE',
          provider: 'EMAIL',
          emailVerified: true,
        },
      })
    );
  }

  console.log('✅ Users created');

  // =========================
  // PLAYER SPORTS
  // =========================
  await prisma.playerSport.createMany({
    data: [
      { playerId: players[0].id, sportId: sports.BADMINTON.id, skillLevel: 'ADVANCED' },
      { playerId: players[0].id, sportId: sports.PADEL.id, skillLevel: 'BEGINNER' },

      { playerId: players[1].id, sportId: sports.FOOTBALL.id, skillLevel: 'ADVANCED' },
      { playerId: players[1].id, sportId: sports.CRICKET.id, skillLevel: 'INTERMEDIATE' },

      { playerId: players[2].id, sportId: sports.BADMINTON.id, skillLevel: 'INTERMEDIATE' },
      { playerId: players[2].id, sportId: sports.TENNIS.id, skillLevel: 'BEGINNER' },

      { playerId: players[3].id, sportId: sports.PADEL.id, skillLevel: 'ADVANCED' },
      { playerId: players[3].id, sportId: sports.BADMINTON.id, skillLevel: 'BEGINNER' },

      { playerId: players[4].id, sportId: sports.CRICKET.id, skillLevel: 'ADVANCED' },
      { playerId: players[4].id, sportId: sports.FOOTBALL.id, skillLevel: 'INTERMEDIATE' },
    ],
  });

  console.log('✅ Player sports created');

  // =========================
  // COURTS + COURT SPORTS
  // =========================
  const courts = [];

  for (let i = 1; i <= 5; i++) {
    const court = await prisma.court.create({
      data: {
        name: `Elite Court ${i}`,
        description: `Premium sports court number ${i}`,
        address: `Street ${i}, Block ${i}`,
        city: `City ${i}`,
        location: `Street ${i}, Block ${i}, City ${i}, State ${i} 1000${i}`,
        mapUrl: `https://maps.google.com/?q=City+${i}`,
        pricePerHour: 1200 + i * 100,
        price: 1200 + i * 100,
        ownerId: owners[i - 1].id,
        status: 'ACTIVE',
      },
    });

    await prisma.courtSport.create({
      data: {
        courtId: court.id,
        sportId: sports[sportNames[i % sportNames.length]].id,
      },
    });

    courts.push(court);
  }

  console.log('✅ Courts created');

  // =========================
  // COURT SLOTS (MUST BE BEFORE BOOKINGS)
  // =========================
  for (const court of courts) {
    for (let h = 9; h <= 13; h++) {
      await prisma.courtSlot.create({
        data: {
          courtId: court.id,
          startTime: `${h}:00`,
          endTime: `${h + 1}:00`,
        },
      });
    }
  }

  console.log('✅ Court slots created');

  // =========================
  // BOOKINGS (NULL-SAFE)
  // =========================
  const bookings = [];

  for (let i = 0; i < 5; i++) {
    const slot = await prisma.courtSlot.findFirst({
      where: { courtId: courts[i].id },
      orderBy: { startTime: 'asc' },
    });

    if (!slot) {
      console.warn(`⚠️ No slot found for court ${courts[i].id}, skipping booking`);
      continue;
    }

    bookings.push(
      await prisma.booking.create({
        data: {
          playerId: players[i].id,
          courtId: courts[i].id,
          date: new Date(Date.now() + i * 86400000),
          startTime: slot.startTime,
          endTime: slot.endTime,
          slotId: slot.id,
          status: 'CONFIRMED',
        },
      })
    );
  }

  console.log('✅ Bookings created');

  // =========================
  // MATCH REQUESTS
  // =========================
  for (let i = 0; i < 5; i++) {
    await prisma.matchRequest.create({
      data: {
        senderId: players[i].id,
        receiverId: players[(i + 1) % 5].id,
        sport: 'BADMINTON',
        skillLevel: 'INTERMEDIATE',
        message: 'Let’s play this weekend!',
        status: 'PENDING',
      },
    });
  }

  console.log('✅ Match requests created');

  // =========================
  // TOURNAMENTS
  // =========================
  const tournaments = [];

  for (let i = 1; i <= 5; i++) {
    tournaments.push(
      await prisma.tournament.create({
        data: {
          name: `Open Tournament ${i}`,
          sport: sportNames[i % sportNames.length],
          startDate: new Date(Date.now() + i * 86400000),
          endDate: new Date(Date.now() + (i + 2) * 86400000),
          maxParticipants: 16,
        },
      })
    );
  }

  console.log('✅ Tournaments created');

  // =========================
  // TOURNAMENT PARTICIPANTS
  // =========================
  for (const tournament of tournaments) {
    for (const player of players) {
      await prisma.tournamentParticipant.create({
        data: {
          tournamentId: tournament.id,
          playerId: player.id,
        },
      });
    }
  }

  console.log('✅ Tournament participants created');

  // =========================
  // NOTIFICATIONS
  // =========================
  for (let i = 0; i < 5; i++) {
    await prisma.notification.create({
      data: {
        senderId: players[i].id,
        receiverId: players[(i + 1) % 5].id,
        type: 'MATCH_REQUEST',
        title: 'New Match Request',
        message: 'You have been challenged!',
      },
    });
  }

  console.log('✅ Notifications created');

  // =========================
  // REPORTS
  // =========================
  for (let i = 0; i < 5; i++) {
    await prisma.report.create({
      data: {
        reporterId: players[i].id,
        reportedUserId: players[(i + 1) % 5].id,
        type: 'USER',
        message: 'Player did not arrive on time.',
      },
    });
  }

  console.log('\n🎉 FULL DATABASE SEEDED SUCCESSFULLY');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
