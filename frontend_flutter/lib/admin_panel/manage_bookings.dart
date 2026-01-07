import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';

class AdminBooking {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  final String courtName;
  final String sport;
  final String location;

  final String playerName;
  final String playerEmail;

  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;

  AdminBooking({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.courtName,
    required this.sport,
    required this.location,
    required this.playerName,
    required this.playerEmail,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    final court = json['court'];
    final player = json['player'];
    final owner = court != null ? court['owner'] : null;

    return AdminBooking(
      id: json['id'],
      date: json['date'].toString().split('T')[0],
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
      courtName: court?['name'] ?? 'N/A',
      sport: court?['sport'] ?? 'N/A',
      location: court?['location'] ?? 'N/A',
      playerName: player != null
          ? '${player['firstName']} ${player['lastName']}'
          : 'N/A',
      playerEmail: player?['email'] ?? 'N/A',
      ownerName:
          owner != null ? '${owner['firstName']} ${owner['lastName']}' : 'N/A',
      ownerEmail: owner?['email'] ?? 'N/A',
      ownerPhone: owner?['phone'] ?? 'N/A',
    );
  }
}

class ManageBookingsScreen extends StatefulWidget {
  final String adminToken;

  const ManageBookingsScreen({super.key, required this.adminToken});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  List<AdminBooking> bookings = [];
  bool isLoading = true;

  String selectedStatus = 'ALL';
  final List<String> statuses = [
    'ALL',
    'PENDING',
    'CONFIRMED',
    'REJECTED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => isLoading = true);

    try {
      final query = selectedStatus == 'ALL' ? '' : '?status=$selectedStatus';

      final res = await ApiService.get(
        '/admin/bookings$query',
        widget.adminToken,
      );

      if (res.statusCode != 200) {
        throw Exception(res.body);
      }

      final decoded = jsonDecode(res.body);
      final List list = decoded['data']['bookings'] ?? [];

      setState(() {
        bookings = list.map((e) => AdminBooking.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Admin bookings error: $e');
      setState(() => isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.redAccent;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          'Manage Bookings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔽 Status Filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statuses.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s),
                      selected: selectedStatus == s,
                      onSelected: (_) {
                        setState(() => selectedStatus = s);
                        _fetchBookings();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookings.isEmpty
                    ? const Center(child: Text('No bookings found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: bookings.length,
                        itemBuilder: (_, i) {
                          final b = bookings[i];

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          b.courtName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.headingBlue,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(b.status)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          b.status,
                                          style: TextStyle(
                                            color: _statusColor(b.status),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),
                                  Text('${b.sport} • ${b.location}'),

                                  const Divider(height: 20),

                                  Text(
                                    '📅 ${b.date}  |  ⏰ ${b.startTime} - ${b.endTime}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    '👤 Player: ${b.playerName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    b.playerEmail,
                                    style: const TextStyle(color: Colors.grey),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    '🏟 Owner: ${b.ownerName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${b.ownerEmail} • ${b.ownerPhone}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
