const slotService = require('../services/SlotService');

exports.createSlots = async (req, res) => {
  try {
    const { courtId } = req.params;
    const { slots } = req.body;

    if (!Array.isArray(slots) || slots.length === 0) {
      return res.status(400).json({ message: 'Slots array is required' });
    }

    await slotService.createSlots(courtId, slots);

    return res.status(201).json({ message: 'Court slots created successfully' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

exports.getSlotsForDate = async (req, res) => {
  try {
    const { courtId } = req.params;
    const { date } = req.query;

    if (!date) {
      return res.status(400).json({ message: 'Date is required' });
    }

    const slots = await slotService.getAvailableSlots(courtId, date);
    return res.json({ courtId, date, slots });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

exports.getAllSlotsForCourt = async (req, res) => {
  try {
    const { courtId } = req.params;
    const slots = await slotService.getAllSlots(courtId);
    return res.json({ slots });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

exports.deleteSlot = async (req, res) => {
  try {
    const { slotId } = req.params;
    await slotService.deleteSlot(slotId);
    return res.json({ message: 'Slot deleted successfully' });
  } catch (error) {
    return res.status(400).json({ message: error.message });
  }
};
