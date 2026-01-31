/*
  Warnings:

  - You are about to drop the column `state` on the `Court` table. All the data in the column will be lost.
  - You are about to drop the column `zipCode` on the `Court` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX `Court_state_idx` ON `Court`;

-- AlterTable
ALTER TABLE `Court` DROP COLUMN `state`,
    DROP COLUMN `zipCode`;

-- AlterTable
ALTER TABLE `Notification` MODIFY `type` ENUM('BOOKING_REQUESTED', 'BOOKING_APPROVED', 'BOOKING_REJECTED', 'BOOKING_CANCELLED', 'MATCH_REQUEST', 'MATCH_ACCEPTED', 'MATCH_REJECTED', 'COURT_APPROVED', 'COURT_REJECTED', 'COURT_INACTIVATED', 'COURT_PENDING', 'OWNER_APPROVED', 'OWNER_REJECTED', 'ADMIN_ANNOUNCEMENT', 'TOURNAMENT_JOINED', 'REPORT_RESOLVED') NOT NULL;
