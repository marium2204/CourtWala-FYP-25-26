const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/AuthMiddleware');

// Controllers
const BookingController = require('../controllers/Player/BookingController');
const MatchmakingController = require('../controllers/Player/MatchmakingController');
const TournamentController = require('../controllers/Player/TournamentController');
const ProfileController = require('../controllers/Player/ProfileController');
const ReportController = require('../controllers/Player/ReportController');

// Validators
const { validateUpdateProfile, validateChangePassword } = require('../validators/ProfileValidator');
const { validateSendMatchRequest } = require('../validators/MatchmakingValidator');

// Apply authentication middleware to all routes
router.use(authenticate);
router.use(authorize('PLAYER'));

// Profile routes
router.get('/profile', ProfileController.getProfile);
router.put('/profile', validateUpdateProfile, ProfileController.updateProfile);
router.post('/profile/change-password', validateChangePassword, ProfileController.changePassword);

// Booking routes
const { validateCreateBooking } = require('../validators/BookingValidator');
router.post('/bookings', validateCreateBooking, BookingController.create);
router.get('/bookings', BookingController.getMyBookings);
router.get('/bookings/:id', BookingController.getById);
router.post('/bookings/:id/cancel', BookingController.cancel);

// Matchmaking routes
router.get('/players/search', MatchmakingController.searchPlayers);
router.post('/match-requests', validateSendMatchRequest, MatchmakingController.sendMatchRequest);
router.get('/match-requests', MatchmakingController.getMatchRequests);
router.post('/match-requests/:id/accept', MatchmakingController.acceptMatchRequest);
router.post('/match-requests/:id/reject', MatchmakingController.rejectMatchRequest);

// Tournament routes
router.get('/tournaments', TournamentController.getAll);
router.get('/tournaments/:id', TournamentController.getById);
router.post('/tournaments/:id/join', TournamentController.join);
router.post('/tournaments/:id/leave', TournamentController.leave);

// Report routes
const { validateCreateReport } = require('../validators/ReportValidator');
router.post('/reports', validateCreateReport, ReportController.create);
router.get('/reports', ReportController.getMyReports);


module.exports = router;

