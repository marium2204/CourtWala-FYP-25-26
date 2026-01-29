const express = require('express');
const router = express.Router();

// Import the controller OBJECT
const SportController = require('../controllers/Admin/SportController');

// GET /api/sports
router.get('/', SportController.getActiveSports);

module.exports = router;
