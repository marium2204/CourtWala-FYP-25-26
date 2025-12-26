import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import 'player_home.dart';

class BookingPage extends StatefulWidget {
  final String courtid;
  final String courtName;
  final String location;
  final String sport;
  final String price;
  final String image;
  final Function(int)? onBookingComplete;

  const BookingPage({
    super.key,
    required this.courtid,
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
  Map<String, dynamic>? _selectedSlot;
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
        _selectedSlot = null;
      });
      _fetchSlots();
    }
  }

  // ================= FETCH SLOTS =================
  Future<void> _fetchSlots() async {
    if (_selectedDate == null) return;

    setState(() => _loadingSlots = true);

    try {
      final date = _selectedDate!.toIso8601String().split('T').first;

      final res = await ApiService.get(
        '/courts/${widget.courtid}/slots?date=$date',
        '',
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _slots
            ..clear()
            ..addAll(List<Map<String, dynamic>>.from(body['slots']));
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
    if (_selectedDate == null || _selectedSlot == null) {
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

      final res = await ApiService.post(
        '/Player/bookings',
        token,
        {
          'courtId': widget.courtid,
          'date': date,
          'startTime': _selectedSlot!['startTime'], // ✅ FIX
          'endTime': _selectedSlot!['endTime'], // ✅ FIX
          'findOpponent': _findOpponent,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PlayerHomeScreen()),
        );

        widget.onBookingComplete?.call(_findOpponent ? 3 : 0);
      } else {
        final body = jsonDecode(res.body);
        throw Exception(body['message'] ?? 'Booking failed');
      }
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
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Book Court", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // COURT INFO
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.courtName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Text("📍 ${widget.location}"),
                    Text("🏅 ${widget.sport}"),
                    const SizedBox(height: 8),
                    Text("PKR ${widget.price} / hr",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor)),
                  ]),
            ),
          ),

          const SizedBox(height: 24),

          // DATE
          const Text("Select Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // SLOTS
          const Text("Select Time Slot",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          if (_loadingSlots)
            const Center(child: CircularProgressIndicator())
          else if (_slots.isEmpty)
            const Text("No slots available for this date")
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _slots.map((slot) {
                final isAvailable = slot['available'] == true;
                final isSelected = _selectedSlot?['id'] == slot['id'];

                return ChoiceChip(
                  label: Text(_formatSlot(slot)),
                  selected: isSelected,
                  selectedColor: AppColors.primaryColor,
                  backgroundColor:
                      isAvailable ? Colors.white : Colors.red.shade300,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isAvailable
                            ? Colors.black
                            : Colors.white,
                  ),
                  onSelected: isAvailable
                      ? (_) => setState(() => _selectedSlot = slot)
                      : null,
                );
              }).toList(),
            ),

          const SizedBox(height: 20),

          SwitchListTile(
            value: _findOpponent,
            onChanged: (v) => setState(() => _findOpponent = v),
            title: const Text("Find an opponent",
                style: TextStyle(fontWeight: FontWeight.bold)),
            activeColor: AppColors.primaryColor,
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _creatingBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _creatingBooking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Confirm Booking",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}
