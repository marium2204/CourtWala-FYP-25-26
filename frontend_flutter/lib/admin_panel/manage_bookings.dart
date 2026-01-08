import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Bookings',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          /// =========================
          /// Status Filter
          /// =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statuses.map((s) {
                  final selected = selectedStatus == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        s,
                        style: TextStyle(
                          color:
                              selected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppColors.primaryColor,
                      backgroundColor: AppColors.white,
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

          /// =========================
          /// Bookings List
          /// =========================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookings.isEmpty
                    ? Center(
                        child: Text(
                          'No bookings found',
                          style: AppTextStyles.subtitle,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookings.length,
                        itemBuilder: (_, i) {
                          final b = bookings[i];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Header
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        b.courtName,
                                        style: AppTextStyles.title,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(b.status)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        b.status,
                                        style: TextStyle(
                                          color: _statusColor(b.status),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),
                                Text(
                                  '${b.sport} • ${b.location}',
                                  style: AppTextStyles.subtitle,
                                ),

                                const Divider(height: 24),

                                Text(
                                  '📅 ${b.date}   ⏰ ${b.startTime} - ${b.endTime}',
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  '👤 Player: ${b.playerName}',
                                  style: AppTextStyles.subtitle
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  b.playerEmail,
                                  style: AppTextStyles.subtitle
                                      .copyWith(fontSize: 13),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  '🏟 Owner: ${b.ownerName}',
                                  style: AppTextStyles.subtitle
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${b.ownerEmail} • ${b.ownerPhone}',
                                  style: AppTextStyles.subtitle
                                      .copyWith(fontSize: 13),
                                ),
                              ],
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
