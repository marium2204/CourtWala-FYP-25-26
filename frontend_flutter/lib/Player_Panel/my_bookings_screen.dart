import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../Owner_Panel/reports.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _loading = true;
  final List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  // ================= FETCH MY BOOKINGS =================
  Future<void> _fetchBookings() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final res = await ApiService.get('/Player/bookings', token);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['data']?['bookings'] ?? [];

        setState(() {
          _bookings
            ..clear()
            ..addAll(List<Map<String, dynamic>>.from(list));
        });
      }
    } catch (e) {
      debugPrint('Fetch bookings error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= CANCEL BOOKING =================
  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final res = await ApiService.post(
        '/Player/bookings/$bookingId/cancel',
        token,
        {},
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled')),
        );
        _fetchBookings();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= HELPERS =================
  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    final d = DateTime.parse(isoDate);
    return "${d.day}/${d.month}/${d.year}";
  }

  String _formatTime(Map<String, dynamic> booking) {
    final start = booking['startTime'];
    final end = booking['endTime'];
    if (start == null || end == null) return 'N/A';
    return "$start - $end";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(
                  child: Text(
                    'No bookings yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _bookings.length,
                  itemBuilder: (_, i) {
                    final b = _bookings[i];
                    final status = b['status'] ?? 'UNKNOWN';
                    final isConfirmed = status == 'CONFIRMED';
                    final court = b['court'] as Map<String, dynamic>?;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Court name
                            Text(
                              court?['name'] ?? 'Court deleted',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.headingBlue,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Date & Time
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: AppColors.primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(b['date']),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time,
                                    size: 16, color: AppColors.primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  _formatTime(b),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Status + Cancel
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isConfirmed
                                        ? Colors.green.withOpacity(0.15)
                                        : Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isConfirmed
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                                if (isConfirmed)
                                  ElevatedButton.icon(
                                    onPressed: () => _cancelBooking(b['id']),
                                    icon: const Icon(Icons.cancel,
                                        size: 16, color: Colors.white),
                                    label: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC4461F),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.report,
                                    color: Colors.red, size: 18),
                                label: const Text(
                                  'Report',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportToAdminScreen(
                                        reportType: 'BOOKING',
                                        reportedBookingId: b['id'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
