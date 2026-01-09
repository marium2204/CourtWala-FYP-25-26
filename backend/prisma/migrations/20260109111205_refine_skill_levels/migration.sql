/*
  Warnings:

  - You are about to alter the column `skillLevel` on the `MatchRequest` table. The data in that column could be lost. The data in that column will be cast from `VarChar(191)` to `Enum(EnumId(8))`.
  - You are about to alter the column `skillLevel` on the `Tournament` table. The data in that column could be lost. The data in that column will be cast from `VarChar(191)` to `Enum(EnumId(8))`.
  - You are about to drop the column `preferredSports` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `skillLevel` on the `User` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX `Notification_type_idx` ON `Notification`;

-- DropIndex
DROP INDEX `Report_type_idx` ON `Report`;

-- AlterTable
ALTER TABLE `MatchRequest` MODIFY `skillLevel` ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED') NULL;

-- AlterTable
ALTER TABLE `Tournament` MODIFY `skillLevel` ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED') NULL;

-- AlterTable
ALTER TABLE `User` DROP COLUMN `preferredSports`,
    DROP COLUMN `skillLevel`,
    ADD COLUMN `provider` ENUM('EMAIL', 'GOOGLE') NOT NULL DEFAULT 'EMAIL',
    MODIFY `password` VARCHAR(191) NULL,
    MODIFY `role` ENUM('PLAYER', 'COURT_OWNER', 'ADMIN') NULL;

-- CreateTable
CREATE TABLE `Sport` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `isActive` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `Sport_name_key`(`name`),
    INDEX `Sport_isActive_idx`(`isActive`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PlayerSport` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `sportId` VARCHAR(191) NOT NULL,
    `skillLevel` ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED') NOT NULL,

    INDEX `PlayerSport_playerId_idx`(`playerId`),
    INDEX `PlayerSport_sportId_idx`(`sportId`),
    UNIQUE INDEX `PlayerSport_playerId_sportId_key`(`playerId`, `sportId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `PlayerSport` ADD CONSTRAINT `PlayerSport_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PlayerSport` ADD CONSTRAINT `PlayerSport_sportId_fkey` FOREIGN KEY (`sportId`) REFERENCES `Sport`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
