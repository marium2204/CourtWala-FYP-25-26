const express = require('express');
const router = express.Router();

const { authenticate, authorize } = require('../middleware/AuthMiddleware');
const { asyncHandler } = require('../utils/ErrorHandler');
const BaseController = require('../controllers/BaseController');

/* =========================
   CONTROLLERS (ALL AT TOP)
========================= */
const DashboardController = require('../controllers/Admin/DashboardController');
const AdminUserController = require('../controllers/Admin/UserController');
const AdminCourtController = require('../controllers/Admin/CourtController');
const AdminBookingController = require('../controllers/Admin/BookingController');
const ReportController = require('../controllers/Admin/ReportController');
const AnnouncementController = require('../controllers/Admin/AnnouncementController');
const AdminTournamentController = require('../controllers/Admin/AdminTournamentController');

/* =========================
   SERVICES
========================= */
const TournamentService = require('../services/TournamentService');

/* =========================
   VALIDATORS
========================= */
const {
  validateUpdateUserStatus,
  validateUpdateCourtStatus,
  validateCreateAnnouncement,
} = require('../validators/AdminValidator');

const {
  validateCreateTournament,
  validateUpdateTournament,
} = require('../validators/TournamentValidator');

/* =========================
   MIDDLEWARE
========================= */
router.use(authenticate);
router.use(authorize('ADMIN'));

/* =========================
   DASHBOARD
========================= */
router.get('/dashboard', DashboardController.getStats);

/* =========================
   USER MANAGEMENT
========================= */
router.get('/users', AdminUserController.getAll);
router.put(
  '/users/:id/status',
  validateUpdateUserStatus,
  AdminUserController.updateStatus
);
router.post('/owners/:id/approve', AdminUserController.approveOwner);
router.post('/owners/:id/reject', AdminUserController.rejectOwner);

/* =========================
   COURT MANAGEMENT
========================= */
router.get('/courts', AdminCourtController.getAll);
router.get('/courts/:id', AdminCourtController.getById);
router.put(
  '/courts/:id/status',
  validateUpdateCourtStatus,
  AdminCourtController.updateStatus
);

/* =========================
   BOOKING OVERSIGHT
========================= */
router.get('/bookings', AdminBookingController.getAll);
router.get('/bookings/:id', AdminBookingController.getById);

/* =========================
   REPORT MANAGEMENT
========================= */
router.get('/reports', ReportController.getAll);
router.post('/reports/:id/resolve', ReportController.resolve);

/* =========================
   ANNOUNCEMENTS
========================= */
router.post(
  '/announcements',
  validateCreateAnnouncement,
  AnnouncementController.create
);
router.get('/announcements', AnnouncementController.getAll);

/* =========================
   TOURNAMENT MANAGEMENT
========================= */
router.get('/tournaments', AdminTournamentController.getAll);

router.post(
  '/tournaments',
  validateCreateTournament,
  asyncHandler(async (req, res) => {
    const tournament = await TournamentService.create(req.body);
    return BaseController.success(
      res,
      tournament,
      'Tournament created successfully',
      201
    );
  })
);

router.put(
  '/tournaments/:id',
  validateUpdateTournament,
  asyncHandler(async (req, res) => {
    const tournament = await TournamentService.update(
      req.params.id,
      req.body
    );
    return BaseController.success(
      res,
      tournament,
      'Tournament updated successfully'
    );
  })
);

router.delete(
  '/tournaments/:id',
  asyncHandler(async (req, res) => {
    await TournamentService.delete(req.params.id);
    return BaseController.success(
      res,
      null,
      'Tournament deleted successfully'
    );
  })
);

module.exports = router;
