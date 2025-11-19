const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/AuthMiddleware');

// Controllers
const DashboardController = require('../controllers/Owner/DashboardController');
const CourtController = require('../controllers/Owner/CourtController');
const BookingController = require('../controllers/Owner/BookingController');

// Apply authentication middleware to all routes
router.use(authenticate);
router.use(authorize('COURT_OWNER'));

// Dashboard routes
router.get('/dashboard', DashboardController.getStats);

// Court routes
const { validateCreateCourt, validateUpdateCourt } = require('../validators/CourtValidator');
router.get('/courts', CourtController.getMyCourts);
router.post('/courts', validateCreateCourt, CourtController.create);
router.get('/courts/:id', CourtController.getById);
router.put('/courts/:id', validateUpdateCourt, CourtController.update);
router.delete('/courts/:id', CourtController.delete);

// Booking routes
router.get('/bookings', BookingController.getMyBookings);
router.get('/bookings/stats', BookingController.getStats);
router.get('/bookings/:id', BookingController.getById);
router.post('/bookings/:id/approve', BookingController.approve);
router.post('/bookings/:id/reject', BookingController.reject);
router.post('/bookings/:id/cancel', BookingController.cancel);

module.exports = router;

