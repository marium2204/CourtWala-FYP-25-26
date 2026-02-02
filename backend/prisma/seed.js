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

  // =========================
  // COURT OWNERS (KARACHI)
  // =========================
  const ownerNames = [
    ['Ahmed', 'Khan'],
    ['Usman', 'Malik'],
    ['Faisal', 'Shaikh'],
    ['Bilal', 'Raza'],
    ['Hassan', 'Ali'],
  ];

  const owners = [];
  const ownerPassword = await bcrypt.hash('Owner@123!', 10);

  for (let i = 0; i < ownerNames.length; i++) {
    owners.push(
      await prisma.user.create({
        data: {
          email: `owner${i + 1}@courtwala.pk`,
          password: ownerPassword,
          firstName: ownerNames[i][0],
          lastName: ownerNames[i][1],
          role: 'COURT_OWNER',
          provider: 'EMAIL',
          emailVerified: true,
        },
      })
    );
  }

  console.log('✅ Court owners created');

  // =========================
  // PLAYERS (PAKISTANI USERS)
  // =========================
  const playerNames = [
    ['Ali', 'Hussain'],
    ['Farah', 'Haris'],
    ['Ayesha', 'Siddiqui'],
    ['Hamza', 'Javed'],
    ['Zainab', 'Iqbal'],
  ];

  const players = [];
  const playerPassword = await bcrypt.hash('Player@123', 10);

  for (let i = 0; i < playerNames.length; i++) {
    players.push(
      await prisma.user.create({
        data: {
          email: `player${i + 1}@demo.pk`,
          password: playerPassword,
          firstName: playerNames[i][0],
          lastName: playerNames[i][1],
          username: `player${i + 1}`,
          role: 'PLAYER',
          provider: 'EMAIL',
          emailVerified: true,
        },
      })
    );
  }

  console.log('✅ Players created');

  // =========================
  // PLAYER SPORTS
  // =========================
  await prisma.playerSport.createMany({
    data: [
      { playerId: players[0].id, sportId: sports.BADMINTON.id, skillLevel: 'ADVANCED' },
      { playerId: players[1].id, sportId: sports.BADMINTON.id, skillLevel: 'BEGINNER' },
      { playerId: players[2].id, sportId: sports.CRICKET.id, skillLevel: 'INTERMEDIATE' },
      { playerId: players[3].id, sportId: sports.FOOTBALL.id, skillLevel: 'ADVANCED' },
      { playerId: players[4].id, sportId: sports.TENNIS.id, skillLevel: 'BEGINNER' },
    ],
  });

  console.log('✅ Player sports created');

  // =========================
  // COURTS (REAL KARACHI)
  // =========================
  const courtData = [
    {
      name: 'PAF Sports Complex',
      address: 'Shahrah-e-Faisal',
      city: 'Karachi',
      mapUrl: 'https://maps.google.com/?q=PAF+Sports+Complex+Karachi',
    },
    {
      name: 'KMC Sports Complex',
      address: 'Gulshan-e-Iqbal',
      city: 'Karachi',
      mapUrl: 'https://maps.google.com/?q=KMC+Sports+Complex+Karachi',
    },
    {
      name: 'National Coaching Centre',
      address: 'Korangi',
      city: 'Karachi',
      mapUrl: 'https://maps.google.com/?q=National+Coaching+Centre+Karachi',
    },
    {
      name: 'Roshan Khan Squash Academy',
      address: 'North Nazimabad',
      city: 'Karachi',
      mapUrl: 'https://maps.google.com/?q=Roshan+Khan+Squash+Academy',
    },
    {
      name: 'Karachi Gymkhana',
      address: 'Club Road',
      city: 'Karachi',
      mapUrl: 'https://maps.google.com/?q=Karachi+Gymkhana',
    },
  ];

  const courts = [];

  for (let i = 0; i < courtData.length; i++) {
    const court = await prisma.court.create({
      data: {
        name: courtData[i].name,
        description: 'Premium sports facility in Karachi',
        address: courtData[i].address,
        city: courtData[i].city,
        location: `${courtData[i].address}, ${courtData[i].city}`,
        mapUrl: courtData[i].mapUrl,
        pricePerHour: 1500 + i * 200,
        price: 1500 + i * 200,
        ownerId: owners[i].id,
        status: 'ACTIVE',
      },
    });

    await prisma.courtSport.create({
      data: {
        courtId: court.id,
        sportId: sports[sportNames[i]].id,
      },
    });

    courts.push(court);
  }

  console.log('✅ Courts created');

  // =========================
  // COURT SLOTS
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
  // BOOKINGS
  // =========================
  for (let i = 0; i < players.length; i++) {
    const slot = await prisma.courtSlot.findFirst({
      where: { courtId: courts[i].id },
    });

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
    });
  }

  console.log('✅ Bookings created');

  // =========================
  // MATCH REQUESTS
  // =========================
  for (let i = 0; i < players.length - 1; i++) {
    await prisma.matchRequest.create({
      data: {
        senderId: players[i].id,
        receiverId: players[i + 1].id,
        sport: 'BADMINTON',
        skillLevel: 'INTERMEDIATE',
        message: 'Let’s play this weekend!',
        status: 'PENDING',
      },
    });
  }

  console.log('✅ Match requests created');

  // =========================
  // ADMIN ANNOUNCEMENT + NOTIFICATION
  // =========================
  const announcement = await prisma.announcement.create({
    data: {
      title: 'Welcome to CourtWala',
      message: 'Book verified courts across Karachi with ease.',
      createdBy: admin.id,
    },
  });

  for (const user of players) {
    await prisma.notification.create({
      data: {
        receiverId: user.id,
        type: 'ADMIN_ANNOUNCEMENT',
        title: announcement.title,
        message: announcement.message,
      },
    });
  }

  console.log('✅ Admin announcement created');

  console.log('\n🎉 DATABASE SEEDED SUCCESSFULLY');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
