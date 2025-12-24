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
      status: json['status'],
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
      }
    } catch (e) {
      debugPrint('Fetch owners error: $e');
      setState(() => isLoading = false);
    }
  }

  /// 🔐 Generic status update
  Future<void> _updateStatus(CourtOwner owner, String status) async {
    await ApiService.put(
      '/admin/users/${owner.id}/status',
      widget.adminToken,
      {'status': status},
    );

    setState(() => owner.status = status);
  }

  /// ✅ APPROVE OWNER (makes login possible)
  Future<void> _approveOwner(CourtOwner owner) async {
    try {
      final res = await ApiService.post(
        '/admin/owners/${owner.id}/approve',
        widget.adminToken,
        {},
      );

      if (res.statusCode == 200) {
        setState(() => owner.status = 'ACTIVE');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner approved and activated')),
        );
      }
    } catch (e) {
      debugPrint('Approve owner error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve owner')),
      );
    }
  }

  /// ❌ REJECT OWNER
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
      case 'PENDING':
      case 'INACTIVE': // 🔥 important
        return Colors.orange;
      case 'SUSPENDED':
        return Colors.amber;
      case 'BLOCKED':
        return Colors.red;
      case 'REJECTED':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  bool _needsApproval(String status) {
    // 🔥 THIS is the critical fix
    return status == 'PENDING' || status == 'INACTIVE';
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
                  padding: const EdgeInsets.all(16),
                  itemCount: owners.length,
                  itemBuilder: (_, i) {
                    final o = owners[i];

                    return Card(
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
                                Chip(
                                  label: Text(o.status),
                                  backgroundColor:
                                      _statusColor(o.status).withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color: _statusColor(o.status),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),
                            Text(o.email),
                            const SizedBox(height: 4),
                            Text('Courts: ${o.courts}'),

                            const Divider(height: 20),

                            // 🎯 ACTIONS
                            Wrap(
                              spacing: 8,
                              children: [
                                // APPROVAL / ACTIVATION (PENDING or INACTIVE)
                                if (_needsApproval(o.status))
                                  TextButton(
                                    onPressed: () => _approveOwner(o),
                                    child: const Text('Approve'),
                                  ),

                                if (_needsApproval(o.status))
                                  TextButton(
                                    onPressed: () => _updateStatus(o, 'ACTIVE'),
                                    child: const Text('Activate'),
                                  ),

                                if (_needsApproval(o.status))
                                  TextButton(
                                    onPressed: () => _rejectOwner(o),
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),

                                // MODERATION (POST-APPROVAL)
                                if (o.status == 'ACTIVE')
                                  TextButton(
                                    onPressed: () =>
                                        _updateStatus(o, 'SUSPENDED'),
                                    child: const Text('Suspend'),
                                  ),

                                if (o.status == 'SUSPENDED')
                                  TextButton(
                                    onPressed: () => _updateStatus(o, 'ACTIVE'),
                                    child: const Text('Activate'),
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
