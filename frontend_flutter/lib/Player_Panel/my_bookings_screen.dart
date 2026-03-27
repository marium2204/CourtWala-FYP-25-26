import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              'Yes, Cancel',
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

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<String?> _fetchCourtMapUrl(String courtId) async {
    final token = await TokenService.getToken();
    if (token == null) return null;

    final res = await ApiService.get('/courts/$courtId', token);
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body)['data'];
    return data['mapUrl'];
  }

  Future<void> _openMap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (_, i) {
                    final b = _bookings[i];
                    final status = b['status'] ?? 'UNKNOWN';
                    final court = b['court'] as Map<String, dynamic>?;

                    final String name = court?['name'] ?? 'Court deleted';
                    final String address =
                        court?['location'] ?? court?['address'] ?? 'N/A';
                    final String price =
                        court?['pricePerHour']?.toString() ?? '--';
                    final String? mapUrl = court?['mapUrl'] ??
                        court?['locationMapUrl'] ??
                        court?['googleMapUrl'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Court Name
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentColor,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Address
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: AppColors.primaryColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  address,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),

                          if (court?['id'] != null)
                            FutureBuilder<String?>(
                              future: _fetchCourtMapUrl(court!['id']),
                              builder: (_, snap) {
                                if (!snap.hasData || snap.data!.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: InkWell(
                                    onTap: () => _openMap(snap.data!),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.map,
                                            size: 18,
                                            color: AppColors.primaryColor),
                                        SizedBox(width: 6),
                                        Text(
                                          'Open in Google Maps',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 8),

                          // Sport
                          Row(
                            children: [
                              const Icon(Icons.sports_tennis,
                                  size: 16, color: AppColors.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                "Sport: ${b['sport'] ?? 'N/A'}",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

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

                          // Price
                          Text(
                            "Amount to be paid: PKR $price",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Status & Action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor(status),
                                  ),
                                ),
                              ),
                              if (status == 'CONFIRMED')
                                ElevatedButton.icon(
                                  onPressed: () => _cancelBooking(b['id']),
                                  icon: const Icon(Icons.cancel,
                                      size: 16, color: Colors.white),
                                  label: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC4461F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
