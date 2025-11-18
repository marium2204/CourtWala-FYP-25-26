-- CreateTable
CREATE TABLE `User` (
    `id` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `username` VARCHAR(191) NULL,
    `password` VARCHAR(191) NOT NULL,
    `firstName` VARCHAR(191) NOT NULL,
    `lastName` VARCHAR(191) NOT NULL,
    `phone` VARCHAR(191) NULL,
    `profilePicture` VARCHAR(191) NULL,
    `role` ENUM('PLAYER', 'COURT_OWNER', 'ADMIN') NOT NULL DEFAULT 'PLAYER',
    `status` ENUM('ACTIVE', 'BLOCKED', 'PENDING_APPROVAL', 'SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    `skillLevel` VARCHAR(191) NULL,
    `preferredSports` JSON NULL,
    `googleId` VARCHAR(191) NULL,
    `emailVerified` BOOLEAN NOT NULL DEFAULT false,
    `resetPasswordToken` VARCHAR(191) NULL,
    `resetPasswordExpires` DATETIME(3) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `User_email_key`(`email`),
    UNIQUE INDEX `User_username_key`(`username`),
    UNIQUE INDEX `User_googleId_key`(`googleId`),
    INDEX `User_email_idx`(`email`),
    INDEX `User_role_idx`(`role`),
    INDEX `User_status_idx`(`status`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Court` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `description` VARCHAR(191) NULL,
    `location` VARCHAR(191) NOT NULL,
    `sport` VARCHAR(191) NOT NULL,
    `price` DOUBLE NOT NULL,
    `facilities` JSON NULL,
    `images` JSON NULL,
    `status` ENUM('ACTIVE', 'INACTIVE', 'PENDING_APPROVAL', 'REJECTED') NOT NULL DEFAULT 'PENDING_APPROVAL',
    `rating` DOUBLE NOT NULL DEFAULT 0,
    `totalRatings` INTEGER NOT NULL DEFAULT 0,
    `ownerId` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `Court_ownerId_idx`(`ownerId`),
    INDEX `Court_sport_idx`(`sport`),
    INDEX `Court_status_idx`(`status`),
    INDEX `Court_location_idx`(`location`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Booking` (
    `id` VARCHAR(191) NOT NULL,
    `courtId` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `date` DATETIME(3) NOT NULL,
    `startTime` VARCHAR(191) NOT NULL,
    `endTime` VARCHAR(191) NOT NULL,
    `status` ENUM('PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
    `needsOpponent` BOOLEAN NOT NULL DEFAULT false,
    `opponentId` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `Booking_courtId_idx`(`courtId`),
    INDEX `Booking_playerId_idx`(`playerId`),
    INDEX `Booking_status_idx`(`status`),
    INDEX `Booking_date_idx`(`date`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `MatchRequest` (
    `id` VARCHAR(191) NOT NULL,
    `senderId` VARCHAR(191) NOT NULL,
    `receiverId` VARCHAR(191) NOT NULL,
    `bookingId` VARCHAR(191) NULL,
    `sport` VARCHAR(191) NOT NULL,
    `skillLevel` VARCHAR(191) NULL,
    `message` VARCHAR(191) NULL,
    `status` ENUM('PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `MatchRequest_senderId_idx`(`senderId`),
    INDEX `MatchRequest_receiverId_idx`(`receiverId`),
    INDEX `MatchRequest_status_idx`(`status`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Tournament` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `description` VARCHAR(191) NULL,
    `sport` VARCHAR(191) NOT NULL,
    `skillLevel` VARCHAR(191) NULL,
    `startDate` DATETIME(3) NOT NULL,
    `endDate` DATETIME(3) NOT NULL,
    `maxParticipants` INTEGER NOT NULL,
    `currentParticipants` INTEGER NOT NULL DEFAULT 0,
    `status` VARCHAR(191) NOT NULL DEFAULT 'UPCOMING',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `Tournament_sport_idx`(`sport`),
    INDEX `Tournament_status_idx`(`status`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `TournamentParticipant` (
    `id` VARCHAR(191) NOT NULL,
    `tournamentId` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `joinedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `TournamentParticipant_tournamentId_idx`(`tournamentId`),
    INDEX `TournamentParticipant_playerId_idx`(`playerId`),
    UNIQUE INDEX `TournamentParticipant_tournamentId_playerId_key`(`tournamentId`, `playerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `CourtReview` (
    `id` VARCHAR(191) NOT NULL,
    `courtId` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `rating` INTEGER NOT NULL,
    `comment` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `CourtReview_courtId_idx`(`courtId`),
    UNIQUE INDEX `CourtReview_courtId_playerId_key`(`courtId`, `playerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Notification` (
    `id` VARCHAR(191) NOT NULL,
    `receiverId` VARCHAR(191) NOT NULL,
    `senderId` VARCHAR(191) NULL,
    `type` ENUM('BOOKING_APPROVED', 'BOOKING_REJECTED', 'BOOKING_CANCELLED', 'MATCH_REQUEST', 'MATCH_ACCEPTED', 'MATCH_REJECTED', 'COURT_APPROVED', 'COURT_REJECTED', 'OWNER_APPROVED', 'OWNER_REJECTED', 'ADMIN_ANNOUNCEMENT', 'TOURNAMENT_JOINED', 'REPORT_RESOLVED') NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `message` VARCHAR(191) NOT NULL,
    `data` JSON NULL,
    `isRead` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Notification_receiverId_idx`(`receiverId`),
    INDEX `Notification_isRead_idx`(`isRead`),
    INDEX `Notification_type_idx`(`type`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Announcement` (
    `id` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `message` VARCHAR(191) NOT NULL,
    `targetAudience` JSON NULL,
    `scheduledAt` DATETIME(3) NULL,
    `isActive` BOOLEAN NOT NULL DEFAULT true,
    `createdBy` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `Announcement_isActive_idx`(`isActive`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Report` (
    `id` VARCHAR(191) NOT NULL,
    `reporterId` VARCHAR(191) NOT NULL,
    `reportedUserId` VARCHAR(191) NULL,
    `reportedCourtId` VARCHAR(191) NULL,
    `type` ENUM('USER', 'COURT', 'BOOKING', 'OTHER') NOT NULL,
    `message` VARCHAR(191) NOT NULL,
    `status` ENUM('PENDING', 'RESOLVED', 'DISMISSED') NOT NULL DEFAULT 'PENDING',
    `resolvedBy` VARCHAR(191) NULL,
    `resolvedAt` DATETIME(3) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `Report_reporterId_idx`(`reporterId`),
    INDEX `Report_status_idx`(`status`),
    INDEX `Report_type_idx`(`type`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `Court` ADD CONSTRAINT `Court_ownerId_fkey` FOREIGN KEY (`ownerId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Booking` ADD CONSTRAINT `Booking_courtId_fkey` FOREIGN KEY (`courtId`) REFERENCES `Court`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Booking` ADD CONSTRAINT `Booking_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Booking` ADD CONSTRAINT `Booking_opponentId_fkey` FOREIGN KEY (`opponentId`) REFERENCES `User`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `MatchRequest` ADD CONSTRAINT `MatchRequest_senderId_fkey` FOREIGN KEY (`senderId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `MatchRequest` ADD CONSTRAINT `MatchRequest_receiverId_fkey` FOREIGN KEY (`receiverId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `TournamentParticipant` ADD CONSTRAINT `TournamentParticipant_tournamentId_fkey` FOREIGN KEY (`tournamentId`) REFERENCES `Tournament`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `TournamentParticipant` ADD CONSTRAINT `TournamentParticipant_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `CourtReview` ADD CONSTRAINT `CourtReview_courtId_fkey` FOREIGN KEY (`courtId`) REFERENCES `Court`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `CourtReview` ADD CONSTRAINT `CourtReview_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Notification` ADD CONSTRAINT `Notification_receiverId_fkey` FOREIGN KEY (`receiverId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Notification` ADD CONSTRAINT `Notification_senderId_fkey` FOREIGN KEY (`senderId`) REFERENCES `User`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Report` ADD CONSTRAINT `Report_reporterId_fkey` FOREIGN KEY (`reporterId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Report` ADD CONSTRAINT `Report_reportedUserId_fkey` FOREIGN KEY (`reportedUserId`) REFERENCES `User`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;
