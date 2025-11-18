const express = require('express');
const router = express.Router();
const CourtController = require('../controllers/CourtController');

// Public routes for browsing courts
router.get('/', CourtController.getAll);
router.get('/:id', CourtController.getById);

module.exports = router;

