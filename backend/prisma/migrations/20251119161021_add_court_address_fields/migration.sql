-- AlterTable: Add new columns as nullable first
ALTER TABLE `Court` 
ADD COLUMN `address` VARCHAR(191) NULL,
ADD COLUMN `city` VARCHAR(191) NULL,
ADD COLUMN `state` VARCHAR(191) NULL,
ADD COLUMN `zipCode` VARCHAR(191) NULL,
ADD COLUMN `pricePerHour` DOUBLE NULL,
ADD COLUMN `amenities` JSON NULL;

-- Migrate existing data
-- Copy price to pricePerHour
UPDATE `Court` SET `pricePerHour` = `price` WHERE `pricePerHour` IS NULL;

-- Copy facilities to amenities
UPDATE `Court` SET `amenities` = `facilities` WHERE `amenities` IS NULL AND `facilities` IS NOT NULL;

-- For address fields, use location as address and set defaults for city/state/zipCode
-- This handles existing records that don't have separate address components
UPDATE `Court` 
SET 
  `address` = COALESCE(`location`, 'Address Not Specified'),
  `city` = COALESCE(`city`, 'City Not Specified'),
  `state` = COALESCE(`state`, 'State Not Specified'),
  `zipCode` = COALESCE(`zipCode`, '00000')
WHERE `address` IS NULL;

-- Make new fields NOT NULL after migrating data
ALTER TABLE `Court` 
MODIFY COLUMN `address` VARCHAR(191) NOT NULL,
MODIFY COLUMN `city` VARCHAR(191) NOT NULL,
MODIFY COLUMN `state` VARCHAR(191) NOT NULL,
MODIFY COLUMN `zipCode` VARCHAR(191) NOT NULL,
MODIFY COLUMN `pricePerHour` DOUBLE NOT NULL;

-- Add indexes for new fields
CREATE INDEX `Court_city_idx` ON `Court`(`city`);
CREATE INDEX `Court_state_idx` ON `Court`(`state`);

