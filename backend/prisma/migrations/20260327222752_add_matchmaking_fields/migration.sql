-- AlterTable
ALTER TABLE `Booking` ADD COLUMN `matchType` ENUM('SINGLES', 'DOUBLES', 'TEAM') NULL,
    ADD COLUMN `playersPerSide` INTEGER NULL;
