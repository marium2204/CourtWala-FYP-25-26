import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';

class ReportItem {
  final String id;
  final String type;
  final String message;
  String status;
  final String reporterId;
  final String? reportedUserId;
  final String? reportedCourtId;
  final DateTime createdAt;

  ReportItem({
    required this.id,
    required this.type,
    required this.message,
    required this.status,
    required this.reporterId,
    this.reportedUserId,
    this.reportedCourtId,
    required this.createdAt,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      id: json['id'],
      type: json['type'],
      message: json['message'],
      status: json['status'],
      reporterId: json['reporterId'],
      reportedUserId: json['reportedUserId'],
      reportedCourtId: json['reportedCourtId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ReportsScreen extends StatefulWidget {
  final String adminToken;

  const ReportsScreen({super.key, required this.adminToken});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<ReportItem> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final res = await ApiService.get('/admin/reports', widget.adminToken);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List list = decoded['data']['reports'];

        setState(() {
          reports = list.map((e) => ReportItem.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Fetch reports error: $e');
      setState(() => isLoading = false);
    }
  }

  void _resolveReport(ReportItem report) {
    final actionCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resolve Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: actionCtrl,
              decoration: const InputDecoration(labelText: 'Action taken'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            onPressed: () async {
              if (actionCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action is required')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                final res = await ApiService.post(
                  '/admin/reports/${report.id}/resolve',
                  widget.adminToken,
                  {
                    'action': actionCtrl.text,
                    'notes': notesCtrl.text,
                  },
                );

                if (res.statusCode == 200) {
                  setState(() => report.status = 'RESOLVED');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report resolved')),
                  );
                }
              } catch (e) {
                debugPrint('Resolve report error: $e');
              }
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'RESOLVED':
        return Colors.green;
      case 'DISMISSED':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          'Reports & Complaints',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(child: Text('No reports found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = reports[i];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r.type} Report',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.headingBlue),
                            ),
                            const SizedBox(height: 4),
                            Text(r.message),
                            const SizedBox(height: 6),
                            if (r.reportedUserId != null)
                              Text('User ID: ${r.reportedUserId}',
                                  style: const TextStyle(color: Colors.grey)),
                            if (r.reportedCourtId != null)
                              Text('Court ID: ${r.reportedCourtId}',
                                  style: const TextStyle(color: Colors.grey)),
                            Text('Reporter: ${r.reporterId}',
                                style: const TextStyle(color: Colors.grey)),
                            Text(
                              'Created: ${r.createdAt.toLocal().toString().split('.')[0]}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(r.status),
                                  backgroundColor:
                                      _statusColor(r.status).withOpacity(0.15),
                                ),
                                if (r.status == 'PENDING')
                                  TextButton.icon(
                                    onPressed: () => _resolveReport(r),
                                    icon: const Icon(Icons.check_circle,
                                        size: 18),
                                    label: const Text('Resolve'),
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
