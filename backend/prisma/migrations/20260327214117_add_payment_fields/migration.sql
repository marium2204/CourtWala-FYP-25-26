/*
  Warnings:

  - Added the required column `advanceAmountPaid` to the `Booking` table without a default value. This is not possible if the table is not empty.
  - Added the required column `paymentScreenshot` to the `Booking` table without a default value. This is not possible if the table is not empty.
  - Added the required column `totalPrice` to the `Booking` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `Booking` ADD COLUMN `advanceAmountPaid` DOUBLE NOT NULL,
    ADD COLUMN `paymentScreenshot` VARCHAR(191) NOT NULL,
    ADD COLUMN `rejectionReason` VARCHAR(191) NULL,
    ADD COLUMN `totalPrice` DOUBLE NOT NULL,
    MODIFY `status` ENUM('PENDING', 'PENDING_APPROVAL', 'CONFIRMED', 'REJECTED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'PENDING_APPROVAL';
