const express = require('express');
const router = express.Router();

const slotController = require('../controllers/SlotController');
const { authenticate, authorize } = require('../middleware/AuthMiddleware');

// COURT OWNER: create slots
router.post(
  '/owner/courts/:courtId/slots',
  authenticate,
  authorize('COURT_OWNER'),
  slotController.createSlots
);

// COURT OWNER: get all slots
router.get(
  '/owner/courts/:courtId/slots',
  authenticate,
  authorize('COURT_OWNER'),
  slotController.getAllSlotsForCourt
);

// PLAYER: get available slots (public)
router.get(
  '/courts/:courtId/slots',
  slotController.getSlotsForDate
);

// COURT OWNER: delete a slot
router.delete(
  '/owner/courts/:courtId/slots/:slotId',
  authenticate,
  authorize('COURT_OWNER'),
  slotController.deleteSlot
);

module.exports = router;
