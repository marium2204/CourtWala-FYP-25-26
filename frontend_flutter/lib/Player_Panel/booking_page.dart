import 'dart:convert';
import 'package:courtwala/player_Panel/my_bookings_screen.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class BookingPage extends StatefulWidget {
  final String courtid;
  final String courtName;
  final String description;
  final String location;
  final List<String> sports;
  final String price;
  final String? image;
  final Function(int)? onBookingComplete;

  const BookingPage({
    super.key,
    required this.courtid,
    required this.courtName,
    required this.description,
    required this.location,
    required this.sports,
    required this.price,
    this.image,
    this.onBookingComplete,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? _selectedSport;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _selectedSlots = [];
  bool _findOpponent = false;
  bool _loadingSlots = false;
  bool _creatingBooking = false;

  final List<Map<String, dynamic>> _slots = [];

  // ================= PICK DATE =================
  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year, now.month + 3),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlots.clear();
      });
      _fetchSlots();
    }
  }

  // ================= FETCH SLOTS =================
  Future<void> _fetchSlots() async {
    if (_selectedDate == null) return;

    setState(() => _loadingSlots = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final date = _selectedDate!.toIso8601String().split('T').first;

      final res = await ApiService.get(
        '/courts/${widget.courtid}/slots?date=$date',
        token,
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        setState(() {
          _slots
            ..clear()
            ..addAll(List<Map<String, dynamic>>.from(body['slots'] ?? []));
        });
      }
    } catch (e) {
      debugPrint('Fetch slots error: $e');
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  // ================= CREATE BOOKING =================
  Future<void> _confirmBooking() async {
    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a sport"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date and time slot"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _creatingBooking = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final date = _selectedDate!.toIso8601String().split('T').first;

      for (final slot in _selectedSlots) {
        final res = await ApiService.post(
          '/player/bookings',
          token,
          {
            'courtId': widget.courtid,
            'sport': _selectedSport,
            'date': date,
            'startTime': slot['startTime'],
            'endTime': slot['endTime'],
            'findOpponent': _findOpponent,
          },
        );

        if (res.statusCode != 200 && res.statusCode != 201) {
          final body = jsonDecode(res.body);
          throw Exception(body['message'] ?? 'Booking failed');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
      );

      widget.onBookingComplete?.call(_findOpponent ? 3 : 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _creatingBooking = false);
    }
  }

  String _formatSlot(Map<String, dynamic> slot) {
    return "${slot['startTime']} - ${slot['endTime']}";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Book Court",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= COURT SUMMARY =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.courtName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text("📍 ${widget.location}",
                      style: const TextStyle(color: Colors.grey)),
                  Text("🏅 ${widget.sports.join(', ')}",
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(
                    "PKR ${widget.price} / hr",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= SPORT =================
            const Text(
              "Select Sport",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.sports.map((sport) {
                final isSelected = _selectedSport == sport;
                return ChoiceChip(
                  label: Text(sport),
                  selected: isSelected,
                  selectedColor: AppColors.primaryColor,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedSport = sport;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ================= DATE =================
            const Text(
              "Select Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDate == null
                        ? "Choose a date"
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                    const Icon(Icons.calendar_today,
                        color: AppColors.primaryColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= SLOTS =================
            const Text(
              "Select Time Slot",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            if (_loadingSlots)
              const Center(child: CircularProgressIndicator())
            else if (_slots.isEmpty)
              const Text("No slots available",
                  style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _slots.map((slot) {
                  final isAvailable = slot['available'] == true;
                  final isSelected =
                      _selectedSlots.any((s) => s['id'] == slot['id']);

                  return ChoiceChip(
                    label: Text(
                      _formatSlot(slot),
                      style: TextStyle(
                        decoration:
                            isAvailable ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryColor,
                    backgroundColor:
                        isAvailable ? Colors.white : Colors.grey.shade300,
                    labelStyle: TextStyle(
                      color: isAvailable ? Colors.black : Colors.grey,
                    ),
                    onSelected: isAvailable
                        ? (_) {
                            setState(() {
                              if (isSelected) {
                                _selectedSlots
                                    .removeWhere((s) => s['id'] == slot['id']);
                              } else {
                                _selectedSlots.add(slot);
                              }
                            });
                          }
                        : null,
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // ================= CONFIRM =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _creatingBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _creatingBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Confirm Booking",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
