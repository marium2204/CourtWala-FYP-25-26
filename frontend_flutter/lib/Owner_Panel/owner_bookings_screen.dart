import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class CourtOwnerBookingsScreen extends StatefulWidget {
  const CourtOwnerBookingsScreen({super.key});

  @override
  State<CourtOwnerBookingsScreen> createState() =>
      _CourtOwnerBookingsScreenState();
}

class _CourtOwnerBookingsScreenState extends State<CourtOwnerBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = true;
  final List<Map<String, dynamic>> _bookings = [];

  final List<String> tabs = [
    'ALL',
    'PENDING',
    'CONFIRMED',
    'COMPLETED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _fetchBookings();
  }

  // ================= FETCH OWNER BOOKINGS =================
  Future<void> _fetchBookings() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final res = await ApiService.get('/owner/bookings', token);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['data']?['bookings'] ?? [];

        setState(() {
          _bookings
            ..clear()
            ..addAll(List<Map<String, dynamic>>.from(list));
          _loading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Fetch owner bookings error: $e');
      setState(() => _loading = false);
    }
  }

  // ================= ACTION =================
  Future<void> _action(String bookingId, String endpoint) async {
    final token = await TokenService.getToken();
    if (token == null) return;

    await ApiService.post(endpoint, token, {});
    _fetchBookings();
  }

  // ================= FILTER =================
  List<Map<String, dynamic>> _filtered(String status) {
    if (status == 'ALL') return _bookings;
    return _bookings.where((b) => b['status'] == status).toList();
  }

  String _formatDate(String date) {
    final d = DateTime.parse(date);
    return "${d.day}/${d.month}/${d.year}";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primaryColor,
                    tabs: tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children:
                        tabs.map((t) => _bookingList(_filtered(t))).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _bookingList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No bookings found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final b = list[i];
        final status = b['status'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusChip(status),
                const SizedBox(height: 8),
                Text(
                  b['court']['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingBlue,
                  ),
                ),
                Text(
                  "Player: ${b['player']['firstName']} ${b['player']['lastName']}",
                ),
                Text("Date: ${_formatDate(b['date'])}"),
                Text("Time: ${b['startTime']} - ${b['endTime']}"),
                Text("Price: PKR ${b['court']['pricePerHour']}"),
                const SizedBox(height: 10),
                _actions(b),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= STATUS CHIP =================
  Widget _statusChip(String status) {
    Color c;
    switch (status) {
      case 'PENDING':
        c = Colors.orange;
        break;
      case 'CONFIRMED':
        c = Colors.green;
        break;
      case 'COMPLETED':
        c = Colors.blue;
        break;
      case 'CANCELLED':
      case 'REJECTED':
        c = Colors.red;
        break;
      default:
        c = Colors.grey;
    }

    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: c),
        const SizedBox(width: 6),
        Text(status, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ================= ACTION BUTTONS =================
  Widget _actions(Map<String, dynamic> b) {
    switch (b['status']) {
      case 'PENDING':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _action(b['id'], '/owner/bookings/${b['id']}/approve'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Approve',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _action(b['id'], '/owner/bookings/${b['id']}/reject'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text('Reject', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );

      case 'CONFIRMED':
        return ElevatedButton(
          onPressed: () => _action(b['id'], '/bookings/${b['id']}/cancel'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(
            'Cancel Booking',
            style: TextStyle(color: Colors.white),
          ),
        );

      default:
        return const Text(
          'No actions available',
          style: TextStyle(color: Colors.grey),
        );
    }
  }
}
