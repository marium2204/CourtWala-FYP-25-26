const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/AuthMiddleware');

// Controllers
const DashboardController = require('../controllers/Admin/DashboardController');
const UserController = require('../controllers/Admin/UserController');
const CourtController = require('../controllers/Admin/CourtController');
const ReportController = require('../controllers/Admin/ReportController');
const AnnouncementController = require('../controllers/Admin/AnnouncementController');
const TournamentService = require('../services/TournamentService');
const BaseController = require('../controllers/BaseController');
const { asyncHandler } = require('../utils/ErrorHandler');

// Apply authentication middleware to all routes
router.use(authenticate);
router.use(authorize('ADMIN'));

// Dashboard routes
router.get('/dashboard', DashboardController.getStats);

// User management routes
router.get('/users', UserController.getAll);
router.put('/users/:id/status', UserController.updateStatus);
router.post('/owners/:id/approve', UserController.approveOwner);
router.post('/owners/:id/reject', UserController.rejectOwner);

// Court management routes
router.get('/courts', CourtController.getAll);
router.put('/courts/:id/status', CourtController.updateStatus);

// Report management routes
router.get('/reports', ReportController.getAll);
router.post('/reports/:id/resolve', ReportController.resolve);

// Announcement routes
router.post('/announcements', AnnouncementController.create);
router.get('/announcements', AnnouncementController.getAll);

// Tournament management routes
router.post('/tournaments', asyncHandler(async (req, res) => {
  const tournament = await TournamentService.create(req.body);
  return BaseController.success(res, tournament, 'Tournament created successfully', 201);
}));

router.put('/tournaments/:id', asyncHandler(async (req, res) => {
  const tournament = await TournamentService.update(req.params.id, req.body);
  return BaseController.success(res, tournament, 'Tournament updated successfully');
}));

router.delete('/tournaments/:id', asyncHandler(async (req, res) => {
  await TournamentService.delete(req.params.id);
  return BaseController.success(res, null, 'Tournament deleted successfully');
}));

module.exports = router;

