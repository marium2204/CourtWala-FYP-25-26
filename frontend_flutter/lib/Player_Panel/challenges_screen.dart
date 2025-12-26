import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_service.dart';
import '../theme/colors.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  bool _loading = true;
  List<Map<String, dynamic>> _received = [];
  List<Map<String, dynamic>> _sent = [];

  @override
  void initState() {
    super.initState();

    // ✅ SAFE INITIALIZATION
    _tabController = TabController(length: 2, vsync: this);

    _fetchAll();
  }

  @override
  void dispose() {
    // ✅ PREVENT MEMORY LEAKS
    _tabController?.dispose();
    super.dispose();
  }

  // ================= FETCH BOTH =================
  Future<void> _fetchAll() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final receivedRes =
          await ApiService.get('/player/match-requests?type=received', token);
      final sentRes =
          await ApiService.get('/player/match-requests?type=sent', token);

      setState(() {
        _received = List<Map<String, dynamic>>.from(
            jsonDecode(receivedRes.body)['data'] ?? []);
        _sent = List<Map<String, dynamic>>.from(
            jsonDecode(sentRes.body)['data'] ?? []);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Fetch challenges error: $e');
      setState(() => _loading = false);
    }
  }

  // ================= ACCEPT WITH MESSAGE =================
  Future<void> _acceptWithMessage(Map<String, dynamic> request) async {
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Accept Challenge'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Optional message (suggest another time/day)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      await ApiService.post(
        '/player/match-requests/${request['id']}/accept',
        token,
        {'message': controller.text.trim()},
      );

      // ✅ OPTIMISTIC UPDATE
      setState(() {
        request['status'] = 'ACCEPTED';
        request['message'] = controller.text.trim();
      });
    } catch (e) {
      _error();
    }
  }

  // ================= REJECT =================
  Future<void> _reject(Map<String, dynamic> request) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      await ApiService.post(
        '/player/match-requests/${request['id']}/reject',
        token,
        {},
      );

      setState(() => request['status'] = 'REJECTED');
    } catch (e) {
      _error();
    }
  }

  void _error() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Action failed'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    // ✅ SAFETY GUARD
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController!,
          tabs: const [
            Tab(text: 'RECEIVED'),
            Tab(text: 'SENT'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController!,
              children: [
                _list(_received, received: true),
                _list(_sent, received: false),
              ],
            ),
    );
  }

  Widget _list(List<Map<String, dynamic>> list, {required bool received}) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No challenges', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final r = list[i];
        final status = r['status'];
        final other = received ? r['sender'] : r['receiver'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: _statusColor(status)),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: _statusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${other['firstName']} ${other['lastName']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Sport: ${r['sport']}'),
                if (r['message'] != null && r['message'].toString().isNotEmpty)
                  Text('Message: ${r['message']}'),
                const SizedBox(height: 10),
                if (received && status == 'PENDING')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _acceptWithMessage(r),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text('Accept',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _reject(r),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Reject',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
