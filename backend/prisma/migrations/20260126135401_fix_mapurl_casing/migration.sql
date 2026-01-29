/*
  Warnings:

  - Added the required column `mapUrl` to the `Court` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `Court` ADD COLUMN `mapUrl` VARCHAR(191) NOT NULL;
