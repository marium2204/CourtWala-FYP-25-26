import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
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
          SnackBar(content: Text('Court ${status.toLowerCase()} successfully')),
        );
        _fetchCourts(); // refresh list from DB
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
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          'Manage Courts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courts.isEmpty
              ? const Center(child: Text('No courts found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courts.length,
                  itemBuilder: (_, i) {
                    final c = courts[i];
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
                            // Court name
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.headingBlue,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Sport
                            Text(
                              'Sport: ${c.sport}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 10),

                            // Status + Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(c.status),
                                  backgroundColor:
                                      _statusColor(c.status).withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color: _statusColor(c.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_isPending(c.status))
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => _updateCourtStatus(
                                          c,
                                          'ACTIVE',
                                          reason:
                                              'Court meets approval criteria',
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                      TextButton(
                                        onPressed: () => _updateCourtStatus(
                                          c,
                                          'REJECTED',
                                          reason: 'Rejected by admin',
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ],
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
