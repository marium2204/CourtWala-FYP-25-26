const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/AuthMiddleware');
const { asyncHandler } = require('../utils/ErrorHandler');

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
router.get('/courts/:id', CourtController.getById);
router.delete('/courts/:id', CourtController.delete);

// Booking routes
router.get('/bookings', BookingController.getMyBookings);
router.get('/bookings/stats', BookingController.getStats);
router.get('/bookings/:id', BookingController.getById);
router.post('/bookings/:id/approve', BookingController.approve);
router.post('/bookings/:id/reject', BookingController.reject);
router.post('/bookings/:id/cancel', BookingController.cancel);

// Profile routes
const OwnerProfileController = require('../controllers/Owner/OwnerProfileController');
router.get('/profile', OwnerProfileController.getProfile);
router.put('/profile', OwnerProfileController.updateProfile);


module.exports = router;

