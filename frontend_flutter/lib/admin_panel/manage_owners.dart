import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';

class CourtOwner {
  final String id;
  final String name;
  final String email;
  String status;
  final int courts;

  CourtOwner({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.courts,
  });

  factory CourtOwner.fromJson(Map<String, dynamic> json) {
    return CourtOwner(
      id: json['id'],
      name: '${json['firstName']} ${json['lastName']}',
      email: json['email'],
      status: json['status'].toString().toUpperCase(),
      courts: json['courtsCount'] ?? 0,
    );
  }
}

class ManageOwnersScreen extends StatefulWidget {
  final String adminToken;

  const ManageOwnersScreen({super.key, required this.adminToken});

  @override
  State<ManageOwnersScreen> createState() => _ManageOwnersScreenState();
}

class _ManageOwnersScreenState extends State<ManageOwnersScreen> {
  List<CourtOwner> owners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOwners();
  }

  /// GET /admin/users?role=COURT_OWNER
  Future<void> _fetchOwners() async {
    try {
      final res = await ApiService.get(
        '/admin/users?role=COURT_OWNER',
        widget.adminToken,
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List list = decoded['data']['users'] ?? [];

        setState(() {
          owners = list.map((e) => CourtOwner.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Fetch owners error: $e');
      setState(() => isLoading = false);
    }
  }

  /// PUT /admin/users/:id/status
  Future<void> _updateStatus(CourtOwner owner, String status) async {
    await ApiService.put(
      '/admin/users/${owner.id}/status',
      widget.adminToken,
      {'status': status},
    );

    setState(() => owner.status = status);
  }

  /// POST /admin/owners/:id/approve
  Future<void> _approveOwner(CourtOwner owner) async {
    await ApiService.post(
      '/admin/owners/${owner.id}/approve',
      widget.adminToken,
      {},
    );

    setState(() => owner.status = 'ACTIVE');
  }

  /// POST /admin/owners/:id/reject
  Future<void> _rejectOwner(CourtOwner owner) async {
    await ApiService.post(
      '/admin/owners/${owner.id}/reject',
      widget.adminToken,
      {'reason': 'Rejected by admin'},
    );

    setState(() => owner.status = 'REJECTED');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'BLOCKED':
        return Colors.red;
      case 'REJECTED':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Court Owners',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : owners.isEmpty
              ? const Center(child: Text('No court owners found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: owners.length,
                  itemBuilder: (_, i) {
                    final o = owners[i];

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + Status
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    o.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(o.status)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    o.status,
                                    style: TextStyle(
                                      color: _statusColor(o.status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                            Text(o.email),
                            const SizedBox(height: 4),
                            Text('Courts: ${o.courts}'),

                            const SizedBox(height: 12),

                            // ✅ ACTIONS (same philosophy as ManageUsersScreen)
                            Row(
                              children: [
                                if (o.status != 'ACTIVE')
                                  TextButton(
                                    onPressed: () => _approveOwner(o),
                                    child: const Text('Approve'),
                                  ),
                                if (o.status != 'REJECTED')
                                  TextButton(
                                    onPressed: () => _rejectOwner(o),
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                              ],
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
