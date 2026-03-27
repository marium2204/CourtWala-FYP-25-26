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
    'PENDING_APPROVAL',
    'CONFIRMED',
    'REJECTED',
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

  Future<void> _rejectBookingPrompt(String bookingId) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this booking:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g., Invalid Screenshot',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final token = await TokenService.getToken();
      if (token == null) return;
      await ApiService.post('/owner/bookings/$bookingId/reject', token, {'reason': reasonController.text});
      _fetchBookings();
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
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
      backgroundColor: const Color(0xFFF6F8FA),
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
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
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
        child: Text(
          'No bookings found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final b = list[i];
        final status = b['status'];

        final List images = b['court'] != null && b['court']['images'] is List
            ? b['court']['images']
            : [];

        final String? imageUrl =
            images.isNotEmpty && images.first.toString().isNotEmpty
                ? images.first
                : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              _statusBadge(status),
              const SizedBox(height: 10),
              Text(
                b['court']['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              _infoRow('Player',
                  "${b['player']['firstName']} ${b['player']['lastName']}"),
              _infoRow('Sport', b['sport']?.toString() ?? 'N/A'),
              _infoRow('Date', _formatDate(b['date'])),
              _infoRow('Time', '${b['startTime']} - ${b['endTime']}'),
              _infoRow('Price (per hr)', 'PKR ${b['court']['pricePerHour']}'),
              if (b['advanceAmountPaid'] != null)
                _infoRow('Advance Paid', 'PKR ${b['advanceAmountPaid']}'),
              if (b['totalPrice'] != null)
                _infoRow('Total Price', 'PKR ${b['totalPrice']}'),
              
              if (b['paymentScreenshot'] != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _showImageDialog(b['paymentScreenshot']),
                    icon: const Icon(Icons.receipt, size: 18),
                    label: const Text('View Payment Receipt'),
                  ),
                ),
              const SizedBox(height: 14),
              _actions(b),
            ],
          ),
        );
      },
    );
  }

  Widget _imagePlaceholder() => Container(
        height: 140,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 40),
        ),
      );

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(String status) {
    Color c;
    switch (status) {
      case 'PENDING_APPROVAL':
        c = Colors.orange;
        break;
      case 'CONFIRMED':
        c = Colors.green;
        break;
      case 'CANCELLED':
      case 'REJECTED':
        c = Colors.red;
        break;
      default:
        c = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ================= ACTION BUTTONS =================
  Widget _actions(Map<String, dynamic> b) {
    switch (b['status']) {
      case 'PENDING_APPROVAL':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _action(b['id'], '/owner/bookings/${b['id']}/approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Approve'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _rejectBookingPrompt(b['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reject'),
              ),
            ),
          ],
        );

      case 'CONFIRMED':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _action(
              b['id'],
              '/owner/bookings/${b['id']}/cancel',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel Booking'),
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
