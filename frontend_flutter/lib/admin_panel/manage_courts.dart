import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';

class Court {
  final String id;
  final String name;
  final String sport;
  String status;

  Court({
    required this.id,
    required this.name,
    required this.sport,
    required this.status,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'],
      name: json['name'],
      sport: json['sport'],
      status: json['status'],
    );
  }
}

class ManageCourtsScreen extends StatefulWidget {
  final String adminToken;

  const ManageCourtsScreen({super.key, required this.adminToken});

  @override
  State<ManageCourtsScreen> createState() => _ManageCourtsScreenState();
}

class _ManageCourtsScreenState extends State<ManageCourtsScreen> {
  List<Court> courts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourts();
  }

  Future<void> _fetchCourts() async {
    try {
      final res = await ApiService.get(
        '/admin/courts',
        widget.adminToken,
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List list = decoded['data']['courts'] ?? [];

        setState(() {
          courts = list.map((e) => Court.fromJson(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch courts error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateCourtStatus(
    Court court,
    String status, {
    String? reason,
  }) async {
    try {
      final res = await ApiService.put(
        '/admin/courts/${court.id}/status',
        widget.adminToken,
        {
          'status': status,
          if (reason != null) 'reason': reason,
        },
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Court ${status.toLowerCase()} successfully'),
          ),
        );
        _fetchCourts(); // refresh list
      }
    } catch (e) {
      debugPrint('Update court status error: $e');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING':
      case 'PENDING_APPROVAL':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _isPending(String status) {
    return status == 'PENDING' || status == 'PENDING_APPROVAL';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title:
            const Text('Manage Courts', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courts.isEmpty
              ? Center(
                  child: Text(
                    'No courts found',
                    style: AppTextStyles.subtitle,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courts.length,
                  itemBuilder: (_, i) {
                    final c = courts[i];

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
                          /// Court Info
                          /// =========================
                          Text(
                            c.name,
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sport: ${c.sport}',
                            style: AppTextStyles.subtitle,
                          ),

                          const SizedBox(height: 14),

                          /// =========================
                          /// Status & Actions
                          /// =========================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _statusColor(c.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  c.status,
                                  style: TextStyle(
                                    color: _statusColor(c.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (_isPending(c.status))
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _updateCourtStatus(
                                        c,
                                        'ACTIVE',
                                        reason: 'Court meets approval criteria',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () => _updateCourtStatus(
                                        c,
                                        'REJECTED',
                                        reason: 'Rejected by admin',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ],
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
