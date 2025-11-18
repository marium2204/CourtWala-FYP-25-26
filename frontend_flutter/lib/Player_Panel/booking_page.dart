import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'player_home.dart'; // for navigating back to home

class BookingPage extends StatefulWidget {
  final String courtName;
  final String location;
  final String sport;
  final String price;
  final String image;
  final Function(int)? onBookingComplete; // optional callback

  const BookingPage({
    super.key,
    required this.courtName,
    required this.location,
    required this.sport,
    required this.price,
    required this.image,
    this.onBookingComplete,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _selectedDate;
  String? _selectedSlot;
  bool _findOpponent = false;

  final List<String> _timeSlots = [
    "7:00 AM - 8:00 AM",
    "8:00 AM - 9:00 AM",
    "9:00 AM - 10:00 AM",
    "3:00 PM - 4:00 PM",
    "4:00 PM - 5:00 PM",
    "5:00 PM - 6:00 PM",
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year, now.month + 3),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _confirmBooking() {
    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date and time slot!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Booking confirmed for ${widget.courtName} "
          "on ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} "
          "at $_selectedSlot",
        ),
        backgroundColor: Colors.green,
      ),
    );

    int nextIndex = _findOpponent ? 3 : 0;

    Navigator.pop(context); // close BookingPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PlayerHomeScreen(),
      ),
    );

    widget.onBookingComplete?.call(nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          "Book Your Court",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Info Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: Colors.black26,
              color: AppColors.primaryColor, // green background
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(widget.image,
                          width: 100, height: 80, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.courtName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)), // white text
                          const SizedBox(height: 4),
                          Text("📍 ${widget.location}",
                              style: const TextStyle(color: Colors.white70)),
                          Text("💸 ${widget.price}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Booking Details Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: AppColors.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Picker
                    const Text("Pick a Day",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedDate == null
                                ? "Select a date"
                                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                            const Icon(Icons.calendar_today,
                                color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Slot Picker
                    const Text("Pick a Slot",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _timeSlots.map((slot) {
                        final isSelected = _selectedSlot == slot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedSlot = slot),
                          selectedColor: AppColors.accentColor,
                          labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.headingBlue),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Find Opponent Toggle
                    SwitchListTile(
                      value: _findOpponent,
                      onChanged: (v) => setState(() => _findOpponent = v),
                      title: const Text("Post match to find an opponent",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      activeColor: AppColors.accentColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Booking Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
