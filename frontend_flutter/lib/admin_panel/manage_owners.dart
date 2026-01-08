import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Manage Court Owners',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : owners.isEmpty
              ? Center(
                  child: Text(
                    'No court owners found',
                    style: AppTextStyles.subtitle,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: owners.length,
                  itemBuilder: (_, i) {
                    final o = owners[i];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// =========================
                          /// Name + Status
                          /// =========================
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  o.name,
                                  style: AppTextStyles.title,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _statusColor(o.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  o.status,
                                  style: TextStyle(
                                    color: _statusColor(o.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          /// =========================
                          /// Info
                          /// =========================
                          Text(
                            o.email,
                            style: AppTextStyles.subtitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Courts owned: ${o.courts}',
                            style:
                                AppTextStyles.subtitle.copyWith(fontSize: 13),
                          ),

                          const SizedBox(height: 14),

                          /// =========================
                          /// Actions
                          /// =========================
                          Row(
                            children: [
                              if (o.status != 'ACTIVE')
                                ElevatedButton(
                                  onPressed: () => _approveOwner(o),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text('Approve'),
                                ),
                              if (o.status != 'REJECTED') ...[
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => _rejectOwner(o),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ],
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
