import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';

class Court {
  final String id;
  final String name;
  final String sport;
  final String address;
  final double pricePerHour;
  final String status;

  Court({
    required this.id,
    required this.name,
    required this.sport,
    required this.address,
    required this.pricePerHour,
    required this.status,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unnamed Court').toString(),
      sport: (json['sport'] ?? 'N/A').toString(),

      // ✅ FIXED ADDRESS MAPPING
      address: (json['address'] ?? json['location'] ?? 'Address not provided')
          .toString(),

      pricePerHour: json['pricePerHour'] is num
          ? (json['pricePerHour'] as num).toDouble()
          : 0.0,

      status: (json['status'] ?? 'PENDING').toString(),
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
      final res = await ApiService.get('/courts', widget.adminToken);

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
        _fetchCourts();
      }
    } catch (e) {
      debugPrint('Update court status error: $e');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  bool _isPending(String status) =>
      status == 'PENDING' || status == 'PENDING_APPROVAL';

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
                          Text(c.name, style: AppTextStyles.title),
                          const SizedBox(height: 4),
                          Text('Sport: ${c.sport}',
                              style: AppTextStyles.subtitle),
                          Text('Address: ${c.address}',
                              style: AppTextStyles.subtitle),
                          Text(
                            'Price: PKR ${c.pricePerHour.toStringAsFixed(0)}/hour',
                            style: AppTextStyles.subtitle,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text(c.status),
                                backgroundColor:
                                    _statusColor(c.status).withOpacity(0.15),
                                labelStyle:
                                    TextStyle(color: _statusColor(c.status)),
                              ),
                              if (_isPending(c.status))
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          _updateCourtStatus(c, 'ACTIVE'),
                                      child: const Text('Approve'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          _updateCourtStatus(c, 'REJECTED'),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                )
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
