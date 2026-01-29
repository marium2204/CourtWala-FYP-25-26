/*
  Warnings:

  - You are about to drop the column `sport` on the `Court` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX `Court_sport_idx` ON `Court`;

-- AlterTable
ALTER TABLE `Court` DROP COLUMN `sport`;

-- CreateTable
CREATE TABLE `CourtSport` (
    `id` VARCHAR(191) NOT NULL,
    `courtId` VARCHAR(191) NOT NULL,
    `sportId` VARCHAR(191) NOT NULL,

    INDEX `CourtSport_courtId_idx`(`courtId`),
    INDEX `CourtSport_sportId_idx`(`sportId`),
    UNIQUE INDEX `CourtSport_courtId_sportId_key`(`courtId`, `sportId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `CourtSport` ADD CONSTRAINT `CourtSport_courtId_fkey` FOREIGN KEY (`courtId`) REFERENCES `Court`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `CourtSport` ADD CONSTRAINT `CourtSport_sportId_fkey` FOREIGN KEY (`sportId`) REFERENCES `Sport`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
