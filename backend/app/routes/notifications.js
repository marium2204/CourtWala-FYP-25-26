const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/AuthMiddleware');
const NotificationController = require('../controllers/NotificationController');

// Apply authentication middleware to all routes
router.use(authenticate);

router.get('/', NotificationController.getAll);
router.get('/unread-count', NotificationController.getUnreadCount);
router.post('/:id/read', NotificationController.markAsRead);
router.post('/read-all', NotificationController.markAllAsRead);

module.exports = router;

