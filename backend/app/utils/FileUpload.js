const multer = require('multer');
const path = require('path');
const fs = require('fs');
const config = require('../../config/app');

// ✅ SINGLE uploads directory (ABSOLUTE PATH)
const uploadDir = path.join(__dirname, '../../uploads');

// Ensure upload directory exists
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(
      null,
      `${file.fieldname}-${uniqueSuffix}${path.extname(file.originalname)}`
    );
  },
});

// File filter
const fileFilter = (req, file, cb) => {
  if (config.upload.allowedImageTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only images are allowed.'), false);
  }
};

// Multer instance
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: config.upload.maxFileSize,
  },
});

/**
 * Upload single file middleware
 */
const uploadSingle = (fieldName = 'image') => {
  return upload.single(fieldName);
};

/**
 * Upload multiple files middleware
 */
const uploadMultiple = (fieldName = 'images', maxCount = 10) => {
  return upload.array(fieldName, maxCount);
};

/**
 * Build public file URL
 * DB should store ONLY filename
 */
const getFileUrl = (filename) => {
  if (!filename) return null;
  return `${config.app.url}/uploads/${filename}`;
};

module.exports = {
  uploadSingle,
  uploadMultiple,
  getFileUrl,
};
